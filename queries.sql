-- Healthcare Patient Flow Quality Measures
-- Dataset: dbo.patient_flow_data
-- Author: Adedamola Ojo

-- Query 1: Previewing the data
SELECT TOP 10 *
FROM dbo.patient_flow_data;

-- Query 2: Total number of visits (row count)
SELECT COUNT(*) AS TotalVisits
FROM dbo.patient_flow_data;


-- Query 3: Missing data check (data quality)
SELECT
  SUM(CASE WHEN Patient_Admission_Date IS NULL THEN 1 ELSE 0 END) AS MissingAdmissionDate,
  SUM(CASE WHEN Patient_Waittime IS NULL THEN 1 ELSE 0 END) AS MissingWaitTime,
  SUM(CASE WHEN Patient_Satisfaction_Score IS NULL THEN 1 ELSE 0 END) AS MissingSatisfaction,
  COUNT(*) AS TotalRows
FROM dbo.patient_flow_data;

-- Query 4: The Average Wait Time (minutes)
SELECT
  AVG(CAST(Patient_Waittime AS float)) AS AvgWaitTimeMinutes
FROM dbo.patient_flow_data
WHERE Patient_Waittime IS NOT NULL;

-- Query 5: Wait time min/max/avg (validating the thresholds)
SELECT
  MIN(Patient_Waittime) AS MinWaitTime,
  MAX(Patient_Waittime) AS MaxWaitTime,
  AVG(CAST(Patient_Waittime AS float)) AS AvgWaitTimeMinutes
FROM dbo.patient_flow_data
WHERE Patient_Waittime IS NOT NULL;

-- Query 6: Overall wait-time rates (% over 30 and % over 60)
SELECT
  ROUND(100.0 * SUM(CASE WHEN Patient_Waittime > 30 THEN 1 ELSE 0 END) / COUNT(*), 2) AS PctTimeOver30,
  ROUND(100.0 * SUM(CASE WHEN Patient_Waittime > 60 THEN 1 ELSE 0 END) / COUNT(*), 2) AS PctTimeOver60
FROM dbo.patient_flow_data
WHERE Patient_Waittime IS NOT NULL;

-- Query 7: KPI(Department) table
SELECT
  Department_Referral,
  COUNT(*) AS Visits,
  ROUND(AVG(CAST(Patient_Waittime AS float)), 2) AS AvgWaitTimeMinutes,
  ROUND(100.0 * SUM(CASE WHEN Patient_Waittime > 30 THEN 1 ELSE 0 END) / COUNT(*), 2) AS PctWaitOver30,
  ROUND(AVG(CAST(Patient_Satisfaction_Score AS float)), 2) AS AvgSatisfactionScore
FROM dbo.patient_flow_data
WHERE Department_Referral IS NOT NULL
GROUP BY Department_Referral
ORDER BY AvgWaitTimeMinutes DESC;

-- Query 8: Top 10 bottleneck departments (highest avg wait)
SELECT TOP 10
  Department_Referral,
  COUNT(*) AS Visits,
  ROUND(AVG(CAST(Patient_Waittime AS float)), 2) AS AvgWaitTimeMinutes
FROM dbo.patient_flow_data
WHERE Department_Referral IS NOT NULL
GROUP BY Department_Referral
ORDER BY AvgWaitTimeMinutes DESC;

-- Query 9: Satisfaction vs wait-time
SELECT
  CASE
    WHEN Patient_Waittime <= 15 THEN '0-15'
    WHEN Patient_Waittime <= 30 THEN '16-30'
    WHEN Patient_Waittime <= 60 THEN '31-60'
    ELSE '60+'
  END AS WaitTimeBucket,
  COUNT(*) AS Visits,
  ROUND(AVG(CAST(Patient_Satisfaction_Score AS float)), 2) AS AvgSatisfactionScore
FROM dbo.patient_flow_data
WHERE Patient_Waittime IS NOT NULL
  AND Patient_Satisfaction_Score IS NOT NULL
GROUP BY
  CASE
    WHEN Patient_Waittime <= 15 THEN '0-15'
    WHEN Patient_Waittime <= 30 THEN '16-30'
    WHEN Patient_Waittime <= 60 THEN '31-60'
    ELSE '60+'
  END
ORDER BY WaitTimeBucket;

-- Query 10: Admission rate by department
SELECT
  Department_Referral,
  COUNT(*) AS Visits,
  ROUND(100.0 * SUM(CASE WHEN Patient_Admission_Flag = 'Admission' THEN 1 ELSE 0 END) / COUNT(*), 2) AS AdmissionRate
FROM dbo.patient_flow_data
WHERE Department_Referral IS NOT NULL
GROUP BY Department_Referral
ORDER BY AdmissionRate DESC;