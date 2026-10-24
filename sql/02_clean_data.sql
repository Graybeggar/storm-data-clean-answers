-- Storm Data, Clean Answers
-- Step 2: build the cleaned, typed table and the data quality log.
--
-- Cleaning decisions (all deliberate, all logged):
--  * BEGIN_DATE_TIME arrives as text like '01-JAN-24 12:00:00' (DD-MON-YY).
--    It is rebuilt as an ISO 'YYYY-MM-DD HH:MM:SS' string.
--  * DAMAGE_PROPERTY / DAMAGE_CROPS arrive as text with suffixes:
--    '10.00K' = $10,000, '1.50M' = $1,500,000, '0.00K' = $0.
--    They are converted to plain dollar amounts (REAL).
--    A BLANK damage field means NOAA recorded no estimate. Blank is
--    treated as UNKNOWN (NULL), never as zero, and every blank is logged.
--  * CZ_TYPE 'C' rows are counties. 'Z' rows are forecast zones, not
--    counties; they stay in the clean table but are flagged, and every
--    county ranking filters to CZ_TYPE = 'C'.
--  * Nothing is deleted. Problem rows are kept and logged.

DROP TABLE IF EXISTS storm_events_clean;
DROP TABLE IF EXISTS data_quality_issues;

CREATE TABLE storm_events_clean (
    event_id            INTEGER,
    episode_id          INTEGER,
    state               TEXT,
    state_fips          INTEGER,
    event_year          INTEGER,
    event_month         INTEGER,
    month_name          TEXT,
    event_type          TEXT,
    cz_type             TEXT,
    county_name         TEXT,
    wfo                 TEXT,
    begin_datetime      TEXT,
    end_datetime        TEXT,
    injuries_direct     INTEGER,
    injuries_indirect   INTEGER,
    deaths_direct       INTEGER,
    deaths_indirect     INTEGER,
    damage_property_usd REAL,
    damage_crops_usd    REAL,
    source              TEXT,
    magnitude           REAL,
    magnitude_type      TEXT,
    tor_f_scale         TEXT,
    tor_length_miles    REAL,
    tor_width_yards     REAL,
    begin_lat           REAL,
    begin_lon           REAL
);

CREATE TABLE data_quality_issues (
    issue_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id   INTEGER,
    issue_type TEXT,
    detail     TEXT
);

-- Helper expressions are inlined below (SQLite has no local variables).
INSERT INTO storm_events_clean
SELECT
    CAST(EVENT_ID AS INTEGER),
    CAST(EPISODE_ID AS INTEGER),
    STATE,
    CAST(STATE_FIPS AS INTEGER),
    CAST(YEAR AS INTEGER),
    CASE MONTH_NAME
        WHEN 'January' THEN 1 WHEN 'February' THEN 2 WHEN 'March' THEN 3
        WHEN 'April' THEN 4 WHEN 'May' THEN 5 WHEN 'June' THEN 6
        WHEN 'July' THEN 7 WHEN 'August' THEN 8 WHEN 'September' THEN 9
        WHEN 'October' THEN 10 WHEN 'November' THEN 11 WHEN 'December' THEN 12
    END,
    MONTH_NAME,
    EVENT_TYPE,
    CZ_TYPE,
    CZ_NAME,
    WFO,
    -- ISO begin datetime from 'DD-MON-YY HH:MM:SS'
    '20' || substr(BEGIN_DATE_TIME, 8, 2) || '-' ||
    CASE substr(BEGIN_DATE_TIME, 4, 3)
        WHEN 'JAN' THEN '01' WHEN 'FEB' THEN '02' WHEN 'MAR' THEN '03'
        WHEN 'APR' THEN '04' WHEN 'MAY' THEN '05' WHEN 'JUN' THEN '06'
        WHEN 'JUL' THEN '07' WHEN 'AUG' THEN '08' WHEN 'SEP' THEN '09'
        WHEN 'OCT' THEN '10' WHEN 'NOV' THEN '11' WHEN 'DEC' THEN '12'
    END || '-' || substr(BEGIN_DATE_TIME, 1, 2) || ' ' || substr(BEGIN_DATE_TIME, 11, 8),
    '20' || substr(END_DATE_TIME, 8, 2) || '-' ||
    CASE substr(END_DATE_TIME, 4, 3)
        WHEN 'JAN' THEN '01' WHEN 'FEB' THEN '02' WHEN 'MAR' THEN '03'
        WHEN 'APR' THEN '04' WHEN 'MAY' THEN '05' WHEN 'JUN' THEN '06'
        WHEN 'JUL' THEN '07' WHEN 'AUG' THEN '08' WHEN 'SEP' THEN '09'
        WHEN 'OCT' THEN '10' WHEN 'NOV' THEN '11' WHEN 'DEC' THEN '12'
    END || '-' || substr(END_DATE_TIME, 1, 2) || ' ' || substr(END_DATE_TIME, 11, 8),
    CAST(INJURIES_DIRECT AS INTEGER),
    CAST(INJURIES_INDIRECT AS INTEGER),
    CAST(DEATHS_DIRECT AS INTEGER),
    CAST(DEATHS_INDIRECT AS INTEGER),
    CASE
        WHEN DAMAGE_PROPERTY IS NULL OR TRIM(DAMAGE_PROPERTY) = '' THEN NULL
        WHEN DAMAGE_PROPERTY LIKE '%K' THEN CAST(REPLACE(REPLACE(DAMAGE_PROPERTY, 'K', ''), '$', '') AS REAL) * 1000
        WHEN DAMAGE_PROPERTY LIKE '%M' THEN CAST(REPLACE(REPLACE(DAMAGE_PROPERTY, 'M', ''), '$', '') AS REAL) * 1000000
        WHEN DAMAGE_PROPERTY LIKE '%B' THEN CAST(REPLACE(REPLACE(DAMAGE_PROPERTY, 'B', ''), '$', '') AS REAL) * 1000000000
        ELSE CAST(REPLACE(DAMAGE_PROPERTY, '$', '') AS REAL)
    END,
    CASE
        WHEN DAMAGE_CROPS IS NULL OR TRIM(DAMAGE_CROPS) = '' THEN NULL
        WHEN DAMAGE_CROPS LIKE '%K' THEN CAST(REPLACE(REPLACE(DAMAGE_CROPS, 'K', ''), '$', '') AS REAL) * 1000
        WHEN DAMAGE_CROPS LIKE '%M' THEN CAST(REPLACE(REPLACE(DAMAGE_CROPS, 'M', ''), '$', '') AS REAL) * 1000000
        WHEN DAMAGE_CROPS LIKE '%B' THEN CAST(REPLACE(REPLACE(DAMAGE_CROPS, 'B', ''), '$', '') AS REAL) * 1000000000
        ELSE CAST(REPLACE(DAMAGE_CROPS, '$', '') AS REAL)
    END,
    SOURCE,
    CAST(NULLIF(MAGNITUDE, '') AS REAL),
    MAGNITUDE_TYPE,
    TOR_F_SCALE,
    CAST(NULLIF(TOR_LENGTH, '') AS REAL),
    CAST(NULLIF(TOR_WIDTH, '') AS REAL),
    CAST(NULLIF(BEGIN_LAT, '') AS REAL),
    CAST(NULLIF(BEGIN_LON, '') AS REAL)
FROM storm_events_raw;

-- Data quality log -------------------------------------------------------

-- Blank property damage: NOAA gave no estimate. Kept as NULL (unknown).
INSERT INTO data_quality_issues (event_id, issue_type, detail)
SELECT CAST(EVENT_ID AS INTEGER), 'missing_property_damage',
       'DAMAGE_PROPERTY was blank in the raw file; treated as unknown, not zero.'
FROM storm_events_raw
WHERE DAMAGE_PROPERTY IS NULL OR TRIM(DAMAGE_PROPERTY) = '';

-- Blank crop damage.
INSERT INTO data_quality_issues (event_id, issue_type, detail)
SELECT CAST(EVENT_ID AS INTEGER), 'missing_crop_damage',
       'DAMAGE_CROPS was blank in the raw file; treated as unknown, not zero.'
FROM storm_events_raw
WHERE DAMAGE_CROPS IS NULL OR TRIM(DAMAGE_CROPS) = '';

-- Forecast-zone rows are not counties.
INSERT INTO data_quality_issues (event_id, issue_type, detail)
SELECT CAST(EVENT_ID AS INTEGER), 'zone_not_county',
       'CZ_TYPE = Z: this row describes a forecast zone, not a county. Excluded from county rankings.'
FROM storm_events_raw
WHERE CZ_TYPE = 'Z';

-- Missing county/zone name.
INSERT INTO data_quality_issues (event_id, issue_type, detail)
SELECT CAST(EVENT_ID AS INTEGER), 'missing_cz_name',
       'CZ_NAME was blank in the raw file.'
FROM storm_events_raw
WHERE CZ_NAME IS NULL OR TRIM(CZ_NAME) = '';

-- Duplicate event ids (should not happen in NOAA details files; checked anyway).
INSERT INTO data_quality_issues (event_id, issue_type, detail)
SELECT CAST(EVENT_ID AS INTEGER), 'duplicate_event_id',
       'This EVENT_ID appears more than once in the raw extract.'
FROM storm_events_raw
GROUP BY EVENT_ID
HAVING COUNT(*) > 1;
