USE HEALTH;
SELECT * FROM healthcare_records;

-- 1.Which hospital is overcharging?
CREATE TABLE hospital_avg (
  Hospital VARCHAR(255),
  Billing_Per_Day DECIMAL(10, 2)
);
-- 1.Which hospital is overcharging?
INSERT INTO hospital_avg (Hospital, Billing_Per_Day)
SELECT Hospital, ROUND(AVG(Billing_Per_Day), 2) as Average_bill FROM healthcare_records
GROUP BY Hospital 
ORDER BY Average_Bill DESC;


SELECT * FROM hospital_avg;


-- 2.Are emergency cases costlier per day?
CREATE TABLE admission_type_summary (
    Admission_Type VARCHAR(50),
    Total_Patients INT,
    Avg_cost DECIMAL(10, 2),
    total_percentage DECIMAL(5, 2)
);

-- 2.Are emergency cases costlier per day?
INSERT INTO admission_type_summary (Admission_Type, Total_Patients, Avg_cost, total_percentage)
SELECT 
  Admission_Type, 
  COUNT(NAME) Total_Patients,
  ROUND(AVG(Billing_Per_Day), 1) AS Avg_cost,
  ROUND((COUNT(NAME) * 100.0 / (SELECT COUNT(*) FROM healthcare_records)), 2) AS total_percentage
FROM 
  healthcare_records
GROUP BY 
  Admission_Type
ORDER BY 
  Avg_cost DESC;
SELECT * FROM admission_type_summary;

-- 3.Which month has highest average billing?
CREATE TABLE monthly_billing_summary (
    Month_number INT,
    Month_Name VARCHAR(20),
    AVG_bill DECIMAL(10, 2)
);

INSERT INTO monthly_billing_summary (Month_number, Month_Name, AVG_bill)
SELECT
CASE WHEN Month_name = "January" THEN 1
     WHEN Month_name = "February" THEN 2
     WHEN Month_name = "March" THEN 3
     WHEN Month_name = "April" THEN 4
     WHEN Month_name = "May" THEN 5
     WHEN Month_name = "June" THEN  6
     WHEN Month_name = "July" THEN 7
     WHEN Month_name = "August" THEN 8
     WHEN Month_name = "September" THEN 9
     WHEN Month_name = "October" THEN 10
     WHEN Month_name = "November" THEN 11
     WHEN Month_name = "December" THEN 12
     END AS Month_number, Month_Name,
     ROUND(AVG(BILLING_AMOUNT), 2) AS AVG_bill  FROM healthcare_records
     GROUP BY Month_nAME
	 ORDER BY Month_number;
	
SELECT * FROM monthly_billing_summary;

-- 4.Are weekend admissions staying longer?
CREATE TABLE weekly_stay_summary (
    WEEK_DAY VARCHAR(20),
    AVG_STAYS DECIMAL(5, 1)
);

INSERT INTO weekly_stay_summary (WEEK_DAY, AVG_STAYS)
	SELECT WEEK_DAY, ROUND(AVG(STAY_DAYS),1) AS AVG_STAYS FROM healthcare_records
	GROUP BY WEEK_DAY
	ORDER BY WEEK_DAY;
SELECT * FROM weekly_stay_summary;
-- 5.How many patients were treated by each doctor?

CREATE TABLE top_doctor_patient_summary (
    DOCTOR VARCHAR(100),
    TOTAL_PATIENTS INT
);

INSERT INTO top_doctor_patient_summary (DOCTOR, TOTAL_PATIENTS)
SELECT DOCTOR, COUNT(NAME) AS TOTAL_PATIENTS FROM healthcare_records
GROUP BY DOCTOR
ORDER BY TOTAL_PATIENTS DESC
Limit 10;

-- 7.Which hospitals consistently bill significantly higher than others for the same medical condition?
CREATE TABLE cancer_billing_summary (
    HOSPITAL VARCHAR(100),
    MEDICAL_CONDITION VARCHAR(100),
    AVG_BILL DECIMAL(10, 2)
);

INSERT INTO cancer_billing_summary (HOSPITAL, MEDICAL_CONDITION, AVG_BILL)
SELECT DISTINCT HOSPITAL, MEDICAL_CONDITION, ROUND(AVG(Billing_Amount)) as AVG_BILL FROM healthcare_records
WHERE Medical_Condition = "CANCER"
GROUP BY HOSPITAL, MEDICAL_CONDITION
HAVING AVG(Billing_Amount) > 51000
ORDER BY avg_bill DESC;

-- Step 1: Create a temporary view with avg billing per condition
-- Step 1: Create a temporary view with avg billing per condition
CREATE TABLE hospital_billing_deviation_summary (
    Hospital VARCHAR(100),
    Medical_Condition VARCHAR(100),
    Hospital_Avg DECIMAL(10, 2),
    Overall_Avg DECIMAL(10, 2),
    Deviation_Percentage DECIMAL(6, 2)
);

INSERT INTO hospital_billing_deviation_summary (Hospital, Medical_Condition, Hospital_Avg, Overall_Avg, Deviation_Percentage)
WITH condition_avg AS (
    SELECT 
       
 Medical_Condition,
        AVG(Billing_Amount) AS Overall_Avg
    FROM healthcare_records
    GROUP BY Medical_Condition
)

-- Step 2: Compare hospital billing against this benchmark
SELECT 
    h.Hospital,
    h.Medical_Condition,
    ROUND(AVG(h.Billing_Amount), 2) AS Hospital_Avg,
    ROUND(c.Overall_Avg, 2) AS Overall_Avg,
    ROUND((AVG(h.Billing_Amount) - c.Overall_Avg) / c.Overall_Avg * 100, 2) AS Deviation_Percentage
FROM healthcare_records h
JOIN condition_avg c
  ON h.Medical_Condition = c.Medical_Condition
GROUP BY 
    h.Hospital, h.Medical_Condition
HAVING 
    Deviation_Percentage > 30
ORDER BY 
    Deviation_Percentage DESC;
    
    
CREATE TABLE yearly_patient_summary (
    YEARS INT,
    TOTAL INT,
    YOY_CHANGE DECIMAL(5, 1)
);


INSERT INTO yearly_patient_summary (YEARS, TOTAL, YOY_CHANGE)
    SELECT YEAR(DATE_OF_ADMISSION) AS YEARS, COUNT(*) AS TOTAL,
       ROUND((((COUNT(NAME)  - LAG(COUNT(NAME),1) OVER(ORDER BY YEAR(Date_of_Admission))) / LAG(COUNT(NAME),1) OVER(ORDER BY YEAR(Date_of_Admission))) * 100),1) AS YOY_CHANGE
       FROM healthcare_records
       GROUP BY YEARS
       ORDER BY YEARS ;



CREATE TABLE monthly_patient_trend (
    MONTHS INT,
    TOTAL INT,
    MOM_CHANGE DECIMAL(5, 1)
);

INSERT INTO monthly_patient_trend (MONTHS, TOTAL, MOM_CHANGE)
SELECT MONTH(DATE_OF_ADMISSION) AS MONTHS, COUNT(*) AS TOTAL,
       ROUND((((COUNT(NAME)  - LAG(COUNT(NAME),1) OVER(ORDER BY MONTH(Date_of_Admission))) / 
       LAG(COUNT(NAME),1) OVER(ORDER BY MONTH(Date_of_Admission))) * 100),1) AS MOM_CHANGE
       FROM healthcare_records
       GROUP BY MONTHS
       ORDER BY MONTHS ;


CREATE TABLE weekday_patient_trend (
    WEEK_DAY INT,
    TOTAL INT,
    WOW_CHANGE DECIMAL(5, 1)
);

INSERT INTO weekday_patient_trend (WEEK_DAY, TOTAL, WOW_CHANGE)
SELECT 
  WEEKDAY(DATE_OF_ADMISSION) AS WEEK_DAY, 
  COUNT(*) AS TOTAL,
  ROUND((((COUNT(NAME)  - LAG(COUNT(NAME),1) OVER(ORDER BY WEEKDAY(DATE_OF_ADMISSION))) / 
    LAG(COUNT(NAME),1) OVER(ORDER BY WEEKDAY(DATE_OF_ADMISSION))) * 100),1) AS WOW_CHANGE
FROM 
  healthcare_records
GROUP BY 
  WEEKDAY(DATE_OF_ADMISSION)
ORDER BY 
  WEEKDAY(DATE_OF_ADMISSION);
  
  
CREATE TABLE yearly_billing_trend (
    YEARS INT,
    AVG_BILL DECIMAL(10, 2),
    YOY_CHANGE DECIMAL(5, 1)
);

INSERT INTO yearly_billing_trend (YEARS, AVG_BILL, YOY_CHANGE)
SELECT YEAR(DATE_OF_ADMISSION) AS YEARS, ROUND(AVG(Billing_Amount),2) AS AVG_BILL,
       ROUND((((AVG(BILLING_AMOUNT)  - LAG(AVG(BILLING_AMOUNT),1) OVER(ORDER BY YEAR(Date_of_Admission))) / LAG(AVG(BILLING_AMOUNT),1) OVER(ORDER BY YEAR(Date_of_Admission))) * 100),1) AS YOY_CHANGE
       FROM healthcare_records
       GROUP BY YEARS
       ORDER BY YEARS ;
       



CREATE TABLE monthly_billing_trend (
    MONTHS INT,
    Month_Name VARCHAR(20),
    avg_bill DECIMAL(10, 2),
    MOM_CHANGE DECIMAL(5, 1)
);

INSERT INTO monthly_billing_trend (MONTHS, Month_Name, avg_bill, MOM_CHANGE)
SELECT 
  MONTH(DATE_OF_ADMISSION) AS MONTHS, 
  Month_Name, 
  ROUND(AVG(Billing_Amount), 2) AS Avg_bill,
  ROUND((((AVG(BILLING_AMOUNT)  - LAG(AVG(BILLING_AMOUNT),1) OVER(ORDER BY MONTH(DATE_OF_ADMISSION))) / 
    LAG(AVG(BILLING_AMOUNT),1) OVER(ORDER BY MONTH(DATE_OF_ADMISSION))) * 100),1) AS MOM_CHANGE
FROM 
  healthcare_records
GROUP BY 
  MONTH(DATE_OF_ADMISSION), Month_Name
ORDER BY 
  MONTH(DATE_OF_ADMISSION);
  
  
SELECT * FROM monthly_billing_trend;