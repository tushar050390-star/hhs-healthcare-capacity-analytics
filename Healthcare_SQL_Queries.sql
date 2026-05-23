USE healthcare_capacity_analytics;

SELECT * 
FROM healthcare_cleaned_data;

-- Average total system load --
-- Calculate average healthcare system load
SELECT 
AVG(`Children in CBP custody` + `Children in HHS Care`)
AS avg_total_system_load
FROM healthcare_cleaned_data;

-- Find peak HHS healthcare burden

SELECT 
MAX(`Children in HHS Care`)
AS peak_hhs_care_load
FROM healthcare_cleaned_data;

-- Identify highest operational pressure periods

SELECT
clean_report_date,
(`Children in CBP custody`+`Children in HHS Care`)
AS total_system_load,
RANK() OVER (ORDER BY
(`Children in CBP custody`+`Children in HHS Care`)DESC)
AS pressure_rank
FROM healthcare_cleaned_data
LIMIT 10;

-- Compare monthly transfers vs discharges
SELECT
DATE_FORMAT(
clean_report_date,
'%Y-%m') AS month_year,
AVG(`Children transferred out of CBP custody`)
AS avg_transfers,
AVG(`Children discharged from HHS Care`)
AS avg_discharges,
(AVG(`Children transferred out of CBP custody`)
-AVG(`Children discharged from HHS Care`))
AS sustainability_gap
FROM healthcare_cleaned_data
GROUP BY month_year
ORDER BY month_year;

-- Calculate rolling operational trend
SELECT
clean_report_date,
(`Children in CBP custody`+`Children in HHS Care`)
AS total_system_load,
AVG(
(`Children in CBP custody`+`Children in HHS Care`
))
OVER (
ORDER BY clean_report_date
ROWS BETWEEN 6 PRECEDING
AND CURRENT ROW)
AS rolling_7_day_avg
FROM healthcare_cleaned_data;

-- Analyze operational pressure distribution
SELECT
CASE
WHEN
(`Children transferred out of CBP custody`-`Children discharged from HHS Care`) > 0
THEN 'Increasing Pressure'
ELSE 'Stable/Reducing'
END
AS backlog_indicator,
COUNT(*) AS total_days
FROM healthcare_cleaned_data
GROUP BY backlog_indicator;

