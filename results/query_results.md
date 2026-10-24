# Query Results: NOAA Storm Events, Iowa and Pennsylvania, 2021-2024

Raw extract: 15,100 rows. Clean table: 15,100 rows. Blank damage values are treated as unknown (NULL), never zero, so damage totals are totals of reported estimates only.

## Data quality issues found

| issue_type | count |
|---|---|
| zone_not_county | 5092 |
| missing_property_damage | 3041 |
| missing_crop_damage | 2878 |

## Q1. How many events of each type, per state? (top event types overall)

| state | event_type | events |
|---|---|---|
| IOWA | Thunderstorm Wind | 1656 |
| IOWA | Hail | 1439 |
| IOWA | Drought | 1275 |
| IOWA | Winter Storm | 517 |
| IOWA | Heavy Rain | 449 |
| IOWA | Tornado | 441 |
| IOWA | Flood | 253 |
| IOWA | Extreme Cold/Wind Chill | 251 |
| IOWA | Winter Weather | 249 |
| IOWA | High Wind | 212 |
| IOWA | Blizzard | 178 |
| IOWA | Flash Flood | 146 |
| IOWA | Funnel Cloud | 133 |
| IOWA | Excessive Heat | 120 |
| IOWA | Cold/Wind Chill | 110 |
| IOWA | Heavy Snow | 100 |
| IOWA | Strong Wind | 72 |
| IOWA | Ice Storm | 66 |
| IOWA | Heat | 29 |
| IOWA | Lightning | 15 |
| IOWA | Wildfire | 3 |
| IOWA | Dense Fog | 3 |
| IOWA | Freezing Fog | 1 |
| PENNSYLVANIA | Thunderstorm Wind | 3951 |
| PENNSYLVANIA | Winter Weather | 825 |
| PENNSYLVANIA | Flash Flood | 655 |
| PENNSYLVANIA | Hail | 544 |
| PENNSYLVANIA | Winter Storm | 324 |
| PENNSYLVANIA | Dense Fog | 167 |
| PENNSYLVANIA | Flood | 120 |
| PENNSYLVANIA | Tornado | 107 |
| PENNSYLVANIA | Heavy Snow | 104 |
| PENNSYLVANIA | Strong Wind | 96 |
| PENNSYLVANIA | High Wind | 80 |
| PENNSYLVANIA | Excessive Heat | 63 |
| PENNSYLVANIA | Drought | 55 |
| PENNSYLVANIA | Lake-Effect Snow | 52 |
| PENNSYLVANIA | Heavy Rain | 49 |
| PENNSYLVANIA | Ice Storm | 35 |
| PENNSYLVANIA | Lightning | 33 |
| PENNSYLVANIA | Coastal Flood | 32 |
| PENNSYLVANIA | Extreme Cold/Wind Chill | 31 |
| PENNSYLVANIA | Cold/Wind Chill | 31 |
| PENNSYLVANIA | Funnel Cloud | 15 |
| PENNSYLVANIA | Wildfire | 7 |
| PENNSYLVANIA | Freezing Fog | 3 |
| PENNSYLVANIA | Heat | 1 |
| PENNSYLVANIA | Frost/Freeze | 1 |
| PENNSYLVANIA | Blizzard | 1 |

## Q2. The severe four: tornado, thunderstorm wind, flash flood, hail.

| state | tornadoes | thunderstorm_wind | flash_floods | hail |
|---|---|---|---|---|
| IOWA | 441 | 1656 | 146 | 1439 |
| PENNSYLVANIA | 107 | 3951 | 655 | 544 |

## Q3. Top 10 counties for tornadoes (county rows only).

| state | county_name | tornadoes |
|---|---|---|
| IOWA | POTTAWATTAMIE | 15 |
| IOWA | WEBSTER | 15 |
| IOWA | POCAHONTAS | 14 |
| IOWA | BENTON | 11 |
| IOWA | POLK | 11 |
| IOWA | HARRISON | 10 |
| PENNSYLVANIA | ALLEGHENY | 10 |
| IOWA | CALHOUN | 9 |
| IOWA | CASS | 9 |
| IOWA | FLOYD | 9 |

## Q4. Top 10 counties for the severe four combined (county rows only).

| state | county_name | severe_events |
|---|---|---|
| PENNSYLVANIA | ALLEGHENY | 454 |
| PENNSYLVANIA | CHESTER | 250 |
| PENNSYLVANIA | WESTMORELAND | 245 |
| PENNSYLVANIA | BERKS | 198 |
| PENNSYLVANIA | MONTGOMERY | 181 |
| PENNSYLVANIA | WASHINGTON | 173 |
| PENNSYLVANIA | BUTLER | 164 |
| IOWA | POLK | 153 |
| PENNSYLVANIA | BUCKS | 146 |
| PENNSYLVANIA | SUSQUEHANNA | 136 |

## Q5. Seasonality: events by month, both states.

| event_month | month_name | state | events |
|---|---|---|---|
| 1 | January | IOWA | 897 |
| 1 | January | PENNSYLVANIA | 535 |
| 2 | February | IOWA | 417 |
| 2 | February | PENNSYLVANIA | 489 |
| 3 | March | IOWA | 421 |
| 3 | March | PENNSYLVANIA | 461 |
| 4 | April | IOWA | 782 |
| 4 | April | PENNSYLVANIA | 522 |
| 5 | May | IOWA | 1012 |
| 5 | May | PENNSYLVANIA | 422 |
| 6 | June | IOWA | 951 |
| 6 | June | PENNSYLVANIA | 1130 |
| 7 | July | IOWA | 1075 |
| 7 | July | PENNSYLVANIA | 1471 |
| 8 | August | IOWA | 653 |
| 8 | August | PENNSYLVANIA | 1100 |
| 9 | September | IOWA | 259 |
| 9 | September | PENNSYLVANIA | 462 |
| 10 | October | IOWA | 266 |
| 10 | October | PENNSYLVANIA | 165 |
| 11 | November | IOWA | 230 |
| 11 | November | PENNSYLVANIA | 215 |
| 12 | December | IOWA | 755 |
| 12 | December | PENNSYLVANIA | 410 |

## Q6. Reported property damage by state and year (reported estimates only).

| state | event_year | events_with_estimates | reported_property_damage_usd |
|---|---|---|---|
| IOWA | 2021 | 1416 | 22,302,500 |
| IOWA | 2022 | 1029 | 226,819,000 |
| IOWA | 2023 | 1293 | 5,637,750 |
| IOWA | 2024 | 1934 | 134,224,700 |
| PENNSYLVANIA | 2021 | 2140 | 394,512,950 |
| PENNSYLVANIA | 2022 | 1368 | 8,029,150 |
| PENNSYLVANIA | 2023 | 1261 | 27,221,200 |
| PENNSYLVANIA | 2024 | 1618 | 58,004,150 |

## Q7. Spotlight counties: Pocahontas County IA and Susquehanna County PA.

| state | county_name | event_type | events |
|---|---|---|---|
| IOWA | POCAHONTAS | Tornado | 14 |
| IOWA | POCAHONTAS | Hail | 11 |
| IOWA | POCAHONTAS | Heavy Rain | 9 |
| IOWA | POCAHONTAS | Funnel Cloud | 5 |
| IOWA | POCAHONTAS | Thunderstorm Wind | 3 |
| IOWA | POCAHONTAS | Flash Flood | 1 |
| PENNSYLVANIA | SUSQUEHANNA | Thunderstorm Wind | 97 |
| PENNSYLVANIA | SUSQUEHANNA | Flash Flood | 32 |
| PENNSYLVANIA | SUSQUEHANNA | Hail | 5 |
| PENNSYLVANIA | SUSQUEHANNA | Tornado | 2 |
| PENNSYLVANIA | SUSQUEHANNA | Flood | 1 |
| PENNSYLVANIA | SUSQUEHANNA | Lightning | 1 |

## Q8. The costliest single events in each state (reported estimates only).

| state | county_name | event_type | event_year | month_name | property_damage_usd | tor_f_scale |
|---|---|---|---|---|---|---|
| IOWA | POLK | Tornado | 2022 | March | 75,000,000 | EF2 |
| IOWA | MADISON | Tornado | 2022 | March | 75,000,000 | EF4 |
| PENNSYLVANIA | PHILADELPHIA | Flash Flood | 2021 | September | 60,000,000 |  |
| IOWA | JASPER | Tornado | 2022 | March | 50,000,000 | EF2 |
| PENNSYLVANIA | CHESTER | Flash Flood | 2021 | September | 40,000,000 |  |
| PENNSYLVANIA | PHILADELPHIA | Flash Flood | 2021 | September | 40,000,000 |  |
| IOWA | ADAIR | Tornado | 2024 | May | 30,000,000 | EF4 |
| IOWA | CLAY | Flood | 2024 | June | 25,590,000 |  |
| PENNSYLVANIA | NORTHAMPTON | Flash Flood | 2021 | September | 25,000,000 |  |
| PENNSYLVANIA | NORTHAMPTON | Flash Flood | 2021 | September | 25,000,000 |  |

## Q9. Tornado strength: how the Iowa and Pennsylvania tornadoes rate.

| state | tor_f_scale | tornadoes |
|---|---|---|
| IOWA | EF0 | 119 |
| IOWA | EF1 | 135 |
| IOWA | EF2 | 58 |
| IOWA | EF3 | 10 |
| IOWA | EF4 | 3 |
| IOWA | EFU | 116 |
| PENNSYLVANIA | EF0 | 38 |
| PENNSYLVANIA | EF1 | 56 |
| PENNSYLVANIA | EF2 | 9 |
| PENNSYLVANIA | EF3 | 2 |
| PENNSYLVANIA | EFU | 2 |
