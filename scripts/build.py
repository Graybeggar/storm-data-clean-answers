#!/usr/bin/env python3
"""Storm Data, Clean Answers: build script.

Loads data/storm_events_ia_pa_raw.csv into SQLite, runs the SQL files in
sql/, writes results/query_results.md, and renders two charts.

Usage:  python3 scripts/build.py
Requires: Python 3.10+, matplotlib (charts only; the build still completes
without it and simply skips the PNG files).
"""
import csv
import re
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DB_PATH = ROOT / "storm_data.db"
RAW_CSV = ROOT / "data" / "storm_events_ia_pa_raw.csv"
RESULTS_MD = ROOT / "results" / "query_results.md"


def run_sql_file(cur, path):
    cur.executescript(path.read_text())


def parse_queries(path):
    """Split 03_analysis_queries.sql into (title, sql) pairs using the
    '-- Qn.' comment line above each query."""
    text = path.read_text()
    blocks = re.findall(r"-- (Q\d+\..*?)\n(SELECT.*?);", text, re.S)
    return [(title.strip(), sql.strip()) for title, sql in blocks]


def md_table(headers, rows):
    out = ["| " + " | ".join(headers) + " |",
           "|" + "|".join("---" for _ in headers) + "|"]
    for row in rows:
        cells = ["" if v is None else (f"{v:,.0f}" if isinstance(v, float) else str(v))
                 for v in row]
        out.append("| " + " | ".join(cells) + " |")
    return "\n".join(out)


def main():
    if DB_PATH.exists():
        DB_PATH.unlink()
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()

    run_sql_file(cur, ROOT / "sql" / "01_create_raw_table.sql")

    with open(RAW_CSV, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        rows = [r for r in reader if len(r) == len(header)]
    placeholders = ",".join("?" for _ in header)
    cur.executemany(f"INSERT INTO storm_events_raw VALUES ({placeholders})", rows)
    con.commit()
    raw_count = cur.execute("SELECT COUNT(*) FROM storm_events_raw").fetchone()[0]
    print(f"raw rows loaded: {raw_count}")

    run_sql_file(cur, ROOT / "sql" / "02_clean_data.sql")
    con.commit()
    clean_count = cur.execute("SELECT COUNT(*) FROM storm_events_clean").fetchone()[0]
    distinct_ids = cur.execute(
        "SELECT COUNT(DISTINCT event_id) FROM storm_events_clean").fetchone()[0]
    print(f"clean rows: {clean_count}  distinct event ids: {distinct_ids}")

    issue_rows = cur.execute(
        "SELECT issue_type, COUNT(*) FROM data_quality_issues "
        "GROUP BY issue_type ORDER BY COUNT(*) DESC").fetchall()
    print("data quality issues:", issue_rows)

    # ---- results page ---------------------------------------------------
    queries = parse_queries(ROOT / "sql" / "03_analysis_queries.sql")
    parts = ["# Query Results: NOAA Storm Events, Iowa and Pennsylvania, 2021-2024",
             "",
             f"Raw extract: {raw_count:,} rows. Clean table: {clean_count:,} rows. "
             "Blank damage values are treated as unknown (NULL), never zero, so "
             "damage totals are totals of reported estimates only.",
             "",
             "## Data quality issues found",
             "",
             md_table(["issue_type", "count"], issue_rows),
             ""]
    results = {}
    for title, sql in queries:
        qrows = cur.execute(sql).fetchall()
        headers = [d[0] for d in cur.description]
        results[title] = (headers, qrows)
        parts += [f"## {title}", "", md_table(headers, qrows), ""]
    RESULTS_MD.write_text("\n".join(parts))
    print(f"wrote {RESULTS_MD}")

    # ---- charts ----------------------------------------------------------
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt

        months = cur.execute(
            "SELECT event_month, state, COUNT(*) FROM storm_events_clean "
            "GROUP BY event_month, state ORDER BY event_month").fetchall()
        ia = [0] * 12
        pa = [0] * 12
        for m, state, n in months:
            (ia if state == "IOWA" else pa)[m - 1] = n
        labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        x = range(12)
        fig, ax = plt.subplots(figsize=(9, 4.2))
        ax.bar([i - 0.2 for i in x], ia, width=0.4, label="Iowa")
        ax.bar([i + 0.2 for i in x], pa, width=0.4, label="Pennsylvania")
        ax.set_xticks(list(x))
        ax.set_xticklabels(labels)
        ax.set_ylabel("Events")
        ax.set_title("Storm events by month, 2021-2024")
        ax.legend()
        fig.tight_layout()
        fig.savefig(ROOT / "results" / "events_by_month.png", dpi=150)
        plt.close(fig)

        top = cur.execute(
            "SELECT county_name || ', ' || CASE state WHEN 'IOWA' THEN 'IA' ELSE 'PA' END, "
            "COUNT(*) FROM storm_events_clean WHERE cz_type='C' AND event_type IN "
            "('Tornado','Thunderstorm Wind','Flash Flood','Hail') "
            "GROUP BY state, county_name ORDER BY COUNT(*) DESC LIMIT 10").fetchall()
        top = top[::-1]
        fig, ax = plt.subplots(figsize=(9, 4.6))
        ax.barh([t[0] for t in top], [t[1] for t in top])
        ax.set_xlabel("Severe events (tornado, thunderstorm wind, flash flood, hail)")
        ax.set_title("Top 10 counties for severe events, 2021-2024")
        fig.tight_layout()
        fig.savefig(ROOT / "results" / "top_counties_severe.png", dpi=150)
        plt.close(fig)
        print("charts written")
    except ImportError:
        print("matplotlib not available; charts skipped", file=sys.stderr)

    con.close()
    print("done")


if __name__ == "__main__":
    main()
