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
       COUNT(p2.total_claim_count) AS total_claims
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

--ANSWER-- Nurse Practitioner with 9,551


--   c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--   d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for            opioids. Which specialties have a high percentage of opioids?




--3. a. Which drug (generic_name) had the highest total drug cost?

SELECT d1.generic_name AS name,
    ROUND(SUM(p1.total_drug_cost), 2) AS cost
FROM drug AS d1
LEFT JOIN prescription AS p1
    ON d1.drug_name = p1.drug_name
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY cost DESC
LIMIT 5;

--ANSWER-- INSULIN GLARGINE,HUM.REC.ANLOG @ 104,264,066.35



--   b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

SELECT d1.generic_name AS name,
    ROUND(SUM(p1.total_drug_cost) / 365, 2) AS daily_cost
FROM drug AS d1
LEFT JOIN prescription AS p1
    ON d1.drug_name = p1.drug_name
WHERE total_day_supply IS NOT NULL
GROUP BY generic_name
ORDER BY daily_cost DESC
LIMIT 5;

--ANSWER-- INSULIN GLARGINE,HUM.REC.ANLOG costs $285,654.98


/* 4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.*/

SELECT d.drug_name,
	   CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	        WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		    ELSE 'neither'
			END AS drug_type
FROM drug AS d
GROUP BY d.drug_name, drug_type;



/* b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision. */

SELECT d1.drug_name,
	   p1.total_drug_cost AS drug_cost,
	   CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	        WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		    ELSE 'neither'
			END AS drug_type
FROM drug AS d1
LEFT JOIN prescription AS p1
	ON d1.drug_name = p1.drug_name
GROUP BY d1.drug_name, drug_type, drug_cost
ORDER BY drug_type;



/*5. a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee. */

/*SELECT cbsaname 
FROM cbsa
WHERE cbsaname LIKE '%TN'; */


SELECT DISTINCT cbsa
FROM fips_county AS f1
LEFT JOIN cbsa AS c1
	ON c1.fipscounty = f1.fipscounty
WHERE state = 'TN' AND cbsa IS NOT NULL;

--ANSWER-- 10 in TN

/* b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.*/

SELECT cbsa,
	   MAX(p1.population) AS population
FROM cbsa
LEFT JOIN population as p1
	ON cbsa.fipscounty = p1.fipscounty
WHERE population IS NOT NULL 
GROUP BY cbsa
ORDER BY population DESC;

SELECT cbsa,
	   MIN(p1.population) AS population
FROM cbsa
LEFT JOIN population as p1
	ON cbsa.fipscounty = p1.fipscounty
WHERE population IS NOT NULL 
GROUP BY cbsa
ORDER BY population;

--ANSWER-- 32820 has the most @ 937847. 16860 has the least @ 14654
 

/* c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.*/

SELECT f1.county AS county,
	   p1.population
FROM population AS p1
LEFT JOIN fips_county AS f1
	ON p1.fipscounty = f1.fipscounty
LEFT JOIN cbsa AS c1
	ON p1.fipscounty = c1.fipscounty
WHERE cbsa IS NULL
ORDER BY population DESC;

--ANSWER-- the largest is Sevier Co with 95,523



/*6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.*/

SELECT drug_name,
	   total_claim_count AS total_claims
FROM prescription
WHERE total_claim_count >= 3000;
	   

/*b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.*/

SELECT p1.drug_name,
	   p1.total_claim_count AS total_claims,
	   CASE WHEN opioid_drug_flag = 'Y' THEN 'Y'
	   	    WHEN long_acting_opioid_drug_flag = 'Y' THEN 'Y'
			ELSE 'N' 
			END AS is_an_opioid
FROM prescription AS p1
LEFT JOIN drug AS d1
	ON p1.drug_name = d1.drug_name
WHERE p1.total_claim_count >= 3000;

/*c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.*/

SELECT p1.drug_name,
	   p1.total_claim_count AS total_claims,
	   CASE WHEN opioid_drug_flag = 'Y' THEN 'Y'
	   	    WHEN long_acting_opioid_drug_flag = 'Y' THEN 'Y'
			ELSE 'N' 
			END AS is_an_opioid,
	   CONCAT(nppes_provider_last_org_name, ', ', nppes_provider_first_name) AS 			provider			
FROM prescription AS p1
LEFT JOIN drug AS d1
	ON p1.drug_name = d1.drug_name
LEFT JOIN prescriber AS p2
	ON p1.npi = p2.npi
WHERE p1.total_claim_count >= 3000;

/*7. AThe goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet. */

SELECT p1.npi,
	   d1.drug_name
FROM prescriber AS p1
LEFT JOIN prescription AS p2
	ON p1.npi = p2.npi
LEFT JOIN drug AS d1
	ON p2.drug_name = d1.drug_name
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';

/*b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).*/

SELECT p1.npi,
	   d1.drug_name,
	   p2.total_claim_count AS number_of_claims
FROM prescriber AS p1
LEFT JOIN prescription AS p2
	ON p1.npi = p2.npi
LEFT JOIN drug AS d1
	ON p2.drug_name = d1.drug_name
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
GROUP BY p1.npi, d1.drug_name, number_of_claims;

/*c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.*/
