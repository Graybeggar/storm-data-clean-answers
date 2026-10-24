-- Storm Data, Clean Answers
-- Step 3: analysis queries against storm_events_clean.
-- Blank damage values are NULL (unknown) in the clean table, so every
-- damage total below is a total of REPORTED estimates only.

-- Q1. How many events of each type, per state? (top event types overall)
SELECT state, event_type, COUNT(*) AS events
FROM storm_events_clean
GROUP BY state, event_type
ORDER BY state, events DESC;

-- Q2. The severe four: tornado, thunderstorm wind, flash flood, hail.
SELECT state,
       SUM(CASE WHEN event_type = 'Tornado' THEN 1 ELSE 0 END)           AS tornadoes,
       SUM(CASE WHEN event_type = 'Thunderstorm Wind' THEN 1 ELSE 0 END) AS thunderstorm_wind,
       SUM(CASE WHEN event_type = 'Flash Flood' THEN 1 ELSE 0 END)       AS flash_floods,
       SUM(CASE WHEN event_type = 'Hail' THEN 1 ELSE 0 END)              AS hail
FROM storm_events_clean
GROUP BY state;

-- Q3. Top 10 counties for tornadoes (county rows only).
SELECT state, county_name, COUNT(*) AS tornadoes
FROM storm_events_clean
WHERE cz_type = 'C' AND event_type = 'Tornado'
GROUP BY state, county_name
ORDER BY tornadoes DESC, state, county_name
LIMIT 10;

-- Q4. Top 10 counties for the severe four combined (county rows only).
SELECT state, county_name, COUNT(*) AS severe_events
FROM storm_events_clean
WHERE cz_type = 'C'
  AND event_type IN ('Tornado', 'Thunderstorm Wind', 'Flash Flood', 'Hail')
GROUP BY state, county_name
ORDER BY severe_events DESC, state, county_name
LIMIT 10;

-- Q5. Seasonality: events by month, both states.
SELECT event_month, month_name, state, COUNT(*) AS events
FROM storm_events_clean
GROUP BY event_month, month_name, state
ORDER BY event_month, state;

-- Q6. Reported property damage by state and year (reported estimates only).
SELECT state, event_year,
       COUNT(damage_property_usd) AS events_with_estimates,
       ROUND(SUM(damage_property_usd)) AS reported_property_damage_usd
FROM storm_events_clean
GROUP BY state, event_year
ORDER BY state, event_year;

-- Q7. Spotlight counties: Pocahontas County IA and Susquehanna County PA.
SELECT state, county_name, event_type, COUNT(*) AS events
FROM storm_events_clean
WHERE cz_type = 'C'
  AND ((state = 'IOWA' AND county_name = 'POCAHONTAS')
    OR (state = 'PENNSYLVANIA' AND county_name = 'SUSQUEHANNA'))
GROUP BY state, county_name, event_type
ORDER BY state, events DESC;

-- Q8. The costliest single events in each state (reported estimates only).
SELECT state, county_name, event_type, event_year, month_name,
       ROUND(damage_property_usd) AS property_damage_usd, tor_f_scale
FROM storm_events_clean
WHERE damage_property_usd IS NOT NULL
ORDER BY damage_property_usd DESC
LIMIT 10;

-- Q9. Tornado strength: how the Iowa and Pennsylvania tornadoes rate.
SELECT state, tor_f_scale, COUNT(*) AS tornadoes
FROM storm_events_clean
WHERE event_type = 'Tornado'
GROUP BY state, tor_f_scale
ORDER BY state, tor_f_scale;
