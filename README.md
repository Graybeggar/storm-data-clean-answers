# Storm Data, Clean Answers

A SQL data cleaning and analysis project built on **real** public data: every storm event NOAA recorded in **Iowa and Pennsylvania from 2021 through 2024** — 15,100 events, taken from the NOAA/NCEI Storm Events Database exactly as published, mess and all.

The companion to [Messy Data, Clean Answers](https://github.com/Graybeggar/messy-data-clean-answers), which practiced the same discipline on a fictional dataset. This one does it on data nobody tidied up first.

## Why these two states

Iowa is home right now. Pennsylvania is where I am house hunting. The analysis ends with a spotlight on the two counties that matter most to me: **Pocahontas County, Iowa** (where I live) and **Susquehanna County, Pennsylvania** (where I hope to).

## The data

- Source: NOAA/NCEI Storm Events Database, "details" files for 2021, 2022, 2023, 2024
  (https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/)
- `data/storm_events_ia_pa_raw.csv` is the extract filtered to Iowa and Pennsylvania: 15,100 rows, all 51 original columns, all TEXT, unedited.
- One row is one event **segment** in one county or forecast zone, which is how NOAA publishes it. A tornado crossing three counties is three rows. County rankings use county rows only.

## What the raw data actually looks like

- Dates arrive as text like `14-JUL-21 18:10:00`.
- Damage arrives as text with suffixes: `10.00K` means $10,000, `1.50M` means $1,500,000.
- 5,092 of the 15,100 rows are **forecast zones, not counties** (drought and winter weather are reported by zone). Any county ranking that ignores this is wrong.
- 3,041 rows have **no property damage estimate at all**. Blank means unknown, not zero.

## Cleaning rules (sql/02_clean_data.sql)

1. Dates rebuilt as ISO `YYYY-MM-DD HH:MM:SS` strings. Verified after the build: 0 unparseable, and the rebuilt year and month match NOAA's own YEAR and MONTH_NAME columns on all 15,100 rows.
2. Damage suffixes converted to plain dollar amounts. Blank damage stays NULL (unknown) and is logged — never silently turned into $0.
3. Zone rows stay in the table, flagged. County queries filter to county rows.
4. Nothing is deleted. Every problem found is written to a `data_quality_issues` table with the event id and an explanation.

## Findings (full tables in results/query_results.md)

- **Iowa: 7,718 events. Pennsylvania: 7,382.** Reported property damage totals $389.0M in Iowa and $487.8M in Pennsylvania across the four years (reported estimates only).
- The severe four split very differently: Iowa had **441 tornadoes** to Pennsylvania's 107, while Pennsylvania had **3,951 thunderstorm wind events** and 655 flash floods to Iowa's 146.
- **Pocahontas County, Iowa ranks #3 in the state for tornadoes** (14 in four years), behind only Pottawattamie and Webster counties.
- **Susquehanna County, Pennsylvania makes the statewide top 10** for severe events (136), driven by 97 thunderstorm wind events and 32 flash floods, with just 2 tornadoes.
- The costliest single events are real ones: the March 2022 Iowa tornado outbreak ($75M in both Polk and Madison counties; the Madison County storm was an EF4), the September 2021 Hurricane Ida flash floods in Pennsylvania ($60M in Philadelphia), and the May 2024 Adair County, Iowa EF4 ($30M).
- Seasonality is not the same in both states: Iowa peaks in July (1,075) but also spikes in January and December on winter storms and drought zone reports; Pennsylvania peaks hard in July (1,471) and stays stormy through August.

## Files

| File | What it is |
|---|---|
| `data/storm_events_ia_pa_raw.csv` | The raw NOAA extract (all TEXT, unedited) |
| `sql/01_create_raw_table.sql` | Raw landing table |
| `sql/02_clean_data.sql` | Cleaning: typed table + data quality log |
| `sql/03_analysis_queries.sql` | Nine analysis queries |
| `scripts/build.py` | Loads the CSV, runs the SQL, writes results and charts |
| `results/query_results.md` | Every query, answered |
| `results/events_by_month.png` | Chart: events by month, both states |
| `results/top_counties_severe.png` | Chart: top 10 counties for severe events |

## Run it yourself

```bash
python3 scripts/build.py
```

That builds `storm_data.db` (SQLite), prints the row counts and the data quality summary, writes `results/query_results.md`, and renders the two charts (charts need `matplotlib`; everything else needs only the Python standard library).

## Skills demonstrated

SQL (DDL, CASE-based parsing and unit conversion, NULL discipline, GROUP BY aggregation, conditional aggregation, joins not needed here — the honesty is the point), data quality logging, working with real government data including its quirks, Python + SQLite + matplotlib, and documenting every judgment call instead of hiding it.
