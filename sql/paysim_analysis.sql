-- =====================================================
-- Project: Mobile Money Transaction & Fraud Analysis
-- Dataset: PaySim Financial Transactions
-- Analyst: Lerato Makutu
-- Role: Data Analyst
-- Goal: Analyze transaction behavior and detect fraud risk
-- =====================================================

-- =====================================================
-- SECTION 1: DATA SETUP
-- Creating a working staging table from the dataset
-- =====================================================

CREATE TABLE paysim_staging LIKE paysim_200k;

INSERT INTO paysim_staging
SELECT * FROM paysim_200k;

-- =====================================================
-- SECTION 2: DATA PREPARATION
-- Creating a unique identifier for each transaction
-- =====================================================

-- Add a unique transaction identifier and move column to the first position

ALTER TABLE paysim_staging
ADD COLUMN transaction_id INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE paysim_staging
MODIFY COLUMN transaction_id INT AUTO_INCREMENT FIRST;

-- Verify the table structure and data types

DESCRIBE paysim_staging;

-- Check for duplicates

SELECT nameOrig, nameDest, amount, type,
COUNT(*) AS occurrences
FROM paysim_staging
GROUP BY nameOrig, nameDest, amount, type
HAVING COUNT(*) > 1;

-- =====================================================
-- SECTION 3: TRANSACTION OVERVIEW
-- Understanding the scale of financial activity on the platform
-- =====================================================

-- Question: How many transactions exist in the dataset?
-- Question: What is the total value of all transactions?
-- Question: What is the average transaction value?
-- Question: What are the smallest and largest transactions?

SELECT COUNT(*) AS total_transactions, 
ROUND(SUM(amount),2) AS total_transaction_value, 
ROUND(AVG(amount),2) AS avgerage_transaction_value,
MIN(amount) AS smallest_transaction, 
MAX(amount) AS largest_transaction
FROM paysim_staging;

-- =====================================================
-- SECTION 4: TRANSACTION BEHAVIOUR
-- Understanding how users interact with the platform.
-- =====================================================

-- Question: Which transaction types are most common?

SELECT type, COUNT(*) AS total_transactions
FROM paysim_staging
GROUP BY type
ORDER BY total_transactions DESC;

-- Question: Which transaction types move the most money?

SELECT type, COUNT(*) AS total_transactions, ROUND(SUM(amount),2) AS total_value
FROM paysim_staging
GROUP BY type
ORDER BY total_value DESC;

-- Question: What are the largest transactions in the system?

SELECT nameOrig, nameDest, amount
FROM paysim_staging
ORDER BY amount DESC
LIMIT 10;

-- =====================================================
-- SECTION 5: FRAUD RISK ANALYSIS
-- Identifying fraud patterns
-- =====================================================

-- Question: What percentage of transactions are fraudulent by transaction type?

SELECT *
FROM paysim_staging
WHERE isFraud > 0;

SELECT type, COUNT(*) AS total_transactions, SUM(isFraud) AS fraud_transactions,
ROUND((SUM(isFraud) * 100.0 / COUNT(*)),2) AS fraud_rate_percentage
FROM paysim_staging
GROUP BY type
ORDER BY fraud_rate_percentage DESC;

-- Question: Which transaction types are the most associated with fraud?

SELECT type, COUNT(*) AS fraud_cases
FROM paysim_staging
WHERE isFraud > 0
GROUP BY type
ORDER BY fraud_cases DESC;

-- Question: How much money is lost to fraud?

SELECT isFraud, COUNT(*) AS total_transactions,
ROUND(SUM(amount),2) AS total_amount,
ROUND(AVG(amount),2) AS average_amount
FROM paysim_staging
GROUP BY isFraud;

-- =====================================================
-- SECTION 6: USER ACTIVITY ANALYSIS
-- Understanding user behaviour and potential risk accounts
-- =====================================================

-- Question: Which users send the most money?

SELECT nameOrig, SUM(amount) AS total_sent
FROM paysim_staging
GROUP BY nameOrig
ORDER BY total_sent DESC
LIMIT 10;

-- Question: Which users receive the most money?

SELECT nameDest, ROUND(SUM(amount),2) AS total_received
FROM paysim_staging
GROUP BY nameDest
ORDER BY total_received DESC
LIMIT 10;

-- Question: Which accounts are involved in fraud transactions?

SELECT nameOrig, COUNT(*) AS fraud_transactions
FROM paysim_staging
WHERE isFraud = 1
GROUP BY nameOrig
ORDER BY fraud_transactions DESC;

























