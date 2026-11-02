SELECT * FROM insurancedb.insurancedata;
use insurancedb;
show tables;

describe insurancedata;
USE insurancedb;
DESCRIBE insurancedata;

ALTER TABLE insurancedata
RENAME COLUMN `ï»¿PolicyNumber` TO PolicyNumber;

-- 1. Total rows
SELECT COUNT(*) AS total_rows FROM insurancedata;

-- 2. Duplicate policies
SELECT PolicyNumber, COUNT(*) AS cnt
FROM insurancedata
GROUP BY PolicyNumber
HAVING COUNT(*) > 1;

-- 3. ClaimDate me NULL kaisa hai
SELECT
  SUM(ClaimDate IS NULL) AS real_null,
  SUM(ClaimDate = 'NULL') AS text_null,
  SUM(ClaimDate = '') AS blank
FROM insurancedata;



CREATE TABLE insurance_clean AS
SELECT DISTINCT
    PolicyNumber,
    CustomerID,
    Gender,
    Age,
    PolicyType,
    STR_TO_DATE(PolicyStartDate, '%d-%m-%Y') AS PolicyStartDate,
    STR_TO_DATE(PolicyEndDate,   '%d-%m-%Y') AS PolicyEndDate,
    PremiumAmount,
    CoverageAmount,
    ClaimNumber,
    STR_TO_DATE(ClaimDate,       '%d-%m-%Y') AS ClaimDate,
    ClaimAmount,
    ClaimStatus
FROM insurancedata;
SELECT COUNT(*) AS total_rows FROM insurance_clean;

SELECT COUNT(DISTINCT PolicyNumber) AS unique_policies FROM insurance_clean;
DESCRIBE insurance_clean;

SELECT COUNT(*) AS bad_start_dates
FROM insurance_clean
WHERE PolicyStartDate IS NULL;

---- date range check
SELECT MIN(PolicyStartDate), MAX(PolicyStartDate),
       MIN(ClaimDate), MAX(ClaimDate)
FROM insurance_clean;

-- rows should be 4354
SELECT COUNT(*) AS rows_without_claim_date
FROM insurance_clean
WHERE ClaimDate IS NULL;

SELECT COUNT(*) AS total_policies,
       SUM(PremiumAmount) AS total_premium,
       AVG(PremiumAmount) AS avg_premium
FROM insurance_clean;


SELECT PolicyType,
       COUNT(*) AS total_policies,
       SUM(PremiumAmount) AS total_premium
FROM insurance_clean
GROUP BY PolicyType
ORDER BY total_premium DESC;

SELECT ClaimStatus,
       COUNT(*) AS total_claims
FROM insurance_clean
GROUP BY ClaimStatus;

#--- settled claims based on policy types..
SELECT PolicyType,
       COUNT(*) AS settled_claims,
       SUM(ClaimAmount) AS settled_amount
FROM insurance_clean
WHERE ClaimStatus = 'Settled'
GROUP BY PolicyType
ORDER BY settled_amount DESC;

# Gender based policy claims 
SELECT Gender,
       COUNT(*) AS total_policies,
       AVG(PremiumAmount) AS avg_premium
FROM insurance_clean
GROUP BY Gender;