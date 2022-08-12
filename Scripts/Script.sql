--1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 
      
SELECT p2.npi, 
       SUM(total_claim_count) AS claim_count
FROM prescription AS p1
LEFT JOIN prescriber AS p2
     ON p1.npi = p2.npi
GROUP BY p2.npi
ORDER BY claim_count DESC
LIMIT 5;

--ANSWER-- 1881634483 has 99,707

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.


SELECT p2.nppes_provider_first_name AS first_name,
       p2.nppes_provider_last_org_name AS last_name,
       p2.specialty_description AS specialty,
       SUM(total_claim_count) AS claim_count
FROM prescription AS p1
LEFT JOIN prescriber AS p2
    ON p1.npi = p2.npi
GROUP BY first_name, last_name, specialty
ORDER BY claim_count DESC
LIMIT 5;

--ANSWER-- Bruce Pendley, Family Practice has 99,707

--2. a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description AS specialty, 
       SUM(p2.total_claim_count) AS total_claims 
FROM prescriber AS p1
LEFT JOIN prescription AS p2
    ON p1.npi = p2.npi
WHERE total_claim_count IS NOT NULL
GROUP BY specialty
ORDER BY total_claims DESC;

--ANSWER-- Family Practice has 9,752,347

--   b. Which specialty had the most total number of claims for opioids?

SELECT specialty_description AS specialty, 
       SUM(p2.total_claim_count) AS total_claims
FROM prescriber AS p1
LEFT JOIN prescription AS p2
    ON p1.npi = p2.npi
LEFT JOIN drug AS d1
    ON p2.drug_name = d1.drug_name
WHERE total_claim_count IS NOT NULL
    AND opioid_drug_flag = 'Y'
    OR long_acting_opioid_drug_flag = 'Y'
GROUP BY specialty
ORDER BY total_claims DESC;

--ANSWER-- Nurse Practitioner with 90,0845




--   c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--   d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for            opioids. Which specialties have a high percentage of opioids?




--3. a. Which drug (generic_name) had the highest total drug cost?

SELECT d1.generic_name AS name,
    ROUND(MAX(p1.total_drug_cost), 2) AS cost
FROM drug AS d1
LEFT JOIN prescription AS p1
    ON d1.drug_name = p1.drug_name
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY cost DESC
LIMIT 5;

--ANSWER-- Pirfenidone



--   b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

SELECT d1.generic_name AS name,
    ROUND(MAX(p1.total_day_supply), 2) AS daily_cost
FROM drug AS d1
LEFT JOIN prescription AS p1
    ON d1.drug_name = p1.drug_name
WHERE total_day_supply IS NOT NULL
GROUP BY generic_name
ORDER BY daily_cost DESC
LIMIT 5;

--ANSWER-- Levothyroxine Sodium costs $115,546.00