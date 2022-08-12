--1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 
      
SELECT p2.npi, MAX(total_claim_count) AS claim_count
FROM prescription AS p1
LEFT JOIN prescriber AS p2
    ON p1.npi = p2.npi
GROUP BY p2.npi
ORDER BY claim_count DESC
LIMIT 5;

--ANSWER-- 1912011792 has 4538

-- b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.


SELECT p2.nppes_provider_first_name AS first_name,
       p2.nppes_provider_last_org_name AS last_name,
       p2.specialty_description AS specialty,
       MAX(total_claim_count) AS claim_count
FROM prescription AS p1
LEFT JOIN prescriber AS p2
    ON p1.npi = p2.npi
GROUP BY first_name, last_name, specialty
ORDER BY claim_count DESC
LIMIT 5;

--ANSWER-- David Coffey, Family Practice has 4538