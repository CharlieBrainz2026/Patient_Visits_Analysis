SELECT * FROM patient_visits;
USE patient_visits_analysis;


-- 1. Total Number of Visits --
SELECT
	count(*) as total_visits
FROM patient_visits;

-- 2. Total Number of Patients --
SELECT
	count(distinct patient_id) as total_patients
FROM patient_visits;

-- 3 Youngest Patients --
SELECT
	min(patient_age) as youngest_patient
FROM patient_visits;


-- 4 Oldest Patient --
SELECT
	max(patient_age) as oldest_patient
FROM patient_visits;

-- 5  Gender Distribution by Visits --
SELECT
	patient_sex as gender,
    count(*) as no_of_visits
FROM patient_visits
GROUP by gender;


-- 6 Age Distribution By Visits --
-- age group | no of visits --

SELECT
	CASE
		when patient_age between 0 and 17 then '0-17'
		when patient_age between 18 and 39 then '18-39'
        when patient_age between 40 and 64 then '40-64'
        else '65+'
        end as age_group,
		COUNT(*) as no_of_visits
	FROM patient_visits
    GROUP BY age_group
    ORDER BY age_group;
    


-- 7 Top 10 Diagnosis --
-- ICD_Code | No of visits --
SELECT
	icd_code,
    count(*) as diagnostic_count
FROM patient_visits
GROUP BY icd_code
ORDER BY diagnostic_count desc
limit 10;
 
-- 8  Top Diagnosis by age group Part 1--
-- diagnosis by age group --
-- age group | icd code | disgnosis count --
SELECT
	CASE
		when patient_age between 0 and 17 then '0-17'
		when patient_age between 18 and 39 then '18-39'
        when patient_age between 40 and 64 then '40-64'
        else '65+'
        end as age_group,
	icd_code,
	COUNT(*) as diagnosis_count,
	ROW_NUMBER()over(partition by 
									CASE
										when patient_age between 0 and 17 then '0-17'
										when patient_age between 18 and 39 then '18-39'
										when patient_age between 40 and 64 then '40-64'
										else '65+'
										end
									order by COUNT(*) desc) rn
	FROM patient_visits
    GROUP BY age_group, icd_code
    ORDER BY age_group, diagnosis_count desc;
    
-- 8  Top Diagnosis by age group Part 2--
-- Now we want to extract the top diagnosis where rn = 1 number them by age groups--
-- copy the above results from part 1 and put it into brackets --

SELECT
	age_group,
    icd_code,
    diagnosis_count
FROM
(SELECT
	CASE
		when patient_age between 0 and 17 then '0-17'
		when patient_age between 18 and 39 then '18-39'
        when patient_age between 40 and 64 then '40-64'
        else '65+'
        end as age_group,
	icd_code,
	COUNT(*) as diagnosis_count,
	ROW_NUMBER()over(partition by 
									CASE
										when patient_age between 0 and 17 then '0-17'
										when patient_age between 18 and 39 then '18-39'
										when patient_age between 40 and 64 then '40-64'
										else '65+'
										end
									order by COUNT(*) desc) rn
	FROM patient_visits
    GROUP BY age_group, icd_code
    ORDER BY age_group, diagnosis_count desc) as ranked
WHERE rn = 1;

    
-- 9  Top Diagnosis by gender --
-- Gender | ICD Code | | Diagnosis Count -- 
SELECT
	gender,
    icd_code,
    diagnosis_count,
    rn
FROM
(SELECT
	patient_sex as gender,
    icd_code,
    count(*) as diagnosis_count,
    ROW_NUMBER() over(partition by patient_sex order by count(*) desc) as rn
FROM patient_visits
GROUP by gender, icd_code
ORDER by gender, diagnosis_count desc) as ranked
WHERE rn = 1;


-- 10 Top 10 CPT Codes --

SELECT
	cpt_code,
    count(*) as diagnostic_count
FROM patient_visits
GROUP BY cpt_code
ORDER BY diagnostic_count desc
limit 10;


-- From here we export our results and move on to PowerBI --