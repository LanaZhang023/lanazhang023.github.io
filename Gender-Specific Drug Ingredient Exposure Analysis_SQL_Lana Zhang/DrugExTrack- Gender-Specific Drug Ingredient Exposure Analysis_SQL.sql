USE Lab1;

/* 
=======================================================================
     DrugExTrack: Gender-Specific Drug Ingredient Exposure Analysis
	   SQL Windowing + R Statistical Testing | OMOP CDM v5.2
=======================================================================
Objective:
----------
This project aims to analyze the differences in drug ingredient exposure 
between male and female patients based on the CMS synthetic patient dataset 
in the OMOP Common Data Model v5.2.

Research Question:
------------------
"Do female patients tend to be exposed to more distinct drug ingredients 
than male patients?"

Hypothesis:
-----------
We hypothesize that female patients are more likely to be exposed to multiple 
drug ingredients due to a higher tendency to seek medical care and manage chronic 
diseases compared to male patients.

Methodology:
------------
1. **Data Extraction using SQL**:  
   - Identify the top 10 most commonly used drug ingredients.  
   - Extract all patients who have been exposed to at least one of these top 10 drugs.  
   - Count the number of distinct drug ingredients each patient was exposed to.  
   - Calculate the average exposure per gender using window function.

2. **Hypothesis Testing using R**:  
   - Perform an independent one-tailed t-test to determine whether the difference 
     in drug exposure between male and female patients is statistically significant.

Dataset Overview:
-----------------
- `drug_era_1m` : Contains patient-level drug exposure records.
  - `person_id`: Unique identifier for each patient.
  - `drug_concept_id`: The drug concept each patient was exposed to.
  - `drug_exposure_count`: Number of times a patient was exposed to a specific drug.

- `concept`: Contains drug ingredient details.
  - `concept_id`: Unique identifier for each drug concept.
  - `concept_name`: The name of the drug ingredient.

- `person`: Contains patient demographic data.
  - `person_id`: Unique identifier for each patient.
  - `gender_source_value`: Encodes gender (1 = Male, 2 = Female).
=======================================================================
*/

-- Step 1: Summarize the top 10 drug ingredients patients were exposed to
WITH table_1 AS (
    SELECT a.drug_concept_id,
           b.concept_name AS ingredient_name,
           SUM(a.drug_exposure_count) AS drug_exposure_count
	FROM drug_era_1m a
    JOIN concept b ON a.drug_concept_id = b.concept_id
    GROUP BY a.drug_concept_id, ingredient_name
    ORDER BY drug_exposure_count DESC
    LIMIT 10
), 
-- Step 2: Summarize the patients who exposed to the top 10 drug ingredients
table_2 AS (
    SELECT DISTINCT person_id
    FROM drug_era_1m
    WHERE drug_concept_id IN (SELECT drug_concept_id FROM table_1)
), 
-- Step 3: Count the number of distinct drug ingredients each patient was exposed to
table_3 AS (
    SELECT person_id,
		   COUNT(DISTINCT drug_concept_id) AS ingredients_num
	FROM drug_era_1m
	WHERE person_id IN (SELECT person_id FROM table_2)
	GROUP BY person_id
),
-- Step 4: Calculate the average number of distinct drug ingredients exposure per gender
exposure_with_avg AS (
  SELECT 
    CASE c.gender_source_value
      WHEN '1' THEN 'Male'
      WHEN '2' THEN 'Female'
      ELSE 'Other'
    END AS patients_gender,
    AVG(d.ingredients_num) OVER (PARTITION BY c.gender_source_value) AS avg_exposure_by_gender
  FROM person c
  JOIN table_3 d ON c.person_id = d.person_id
)
SELECT DISTINCT patients_gender, avg_exposure_by_gender
FROM exposure_with_avg
ORDER BY avg_exposure_by_gender DESC;

/*
=======================================================================
                      SQL Result: Summary Statistics
=======================================================================
patients_gender, ingredients_average
'Female'       ,'1.8112'
'Male'         ,'1.7609'
=======================================================================
Comment:
---------
Female patients were exposed to slightly more drug ingredients on average (1.8112) 
compared to male patients (1.7609), suggesting that women may have a higher tendency 
to seek medical care with multiple medications and drug ingredients. However, this 
difference is relatively small, indicating that gender alone may not be a strong 
determinant of drug exposure. Other factors, such as age or healthcare access, could 
play a significant role.

Research Hypothesis:
--------------------
Female patients are more likely to be exposed to multiple drug ingredients due to higher 
engagement in chronic disease management compared to male patients.
=======================================================================
*/

-- Step 5: Retrieve individual patient data for statistical testing in R
WITH table_1 AS (
    SELECT a.drug_concept_id,
           b.concept_name AS ingredient_name,
           SUM(a.drug_exposure_count) AS drug_exposure_count
	FROM drug_era_1m a
    JOIN concept b ON a.drug_concept_id = b.concept_id
    GROUP BY a.drug_concept_id, ingredient_name
    ORDER BY drug_exposure_count DESC
    LIMIT 10
),
table_2 AS (
    SELECT DISTINCT person_id
    FROM drug_era_1m
    WHERE drug_concept_id IN (SELECT drug_concept_id FROM table_1)
),
table_3 AS (
    SELECT person_id,
		   COUNT(DISTINCT drug_concept_id) AS ingredients_num
	FROM drug_era_1m
	WHERE person_id IN (SELECT person_id FROM table_2)
	GROUP BY person_id
)
SELECT 
    CASE c.gender_source_value
        WHEN '1' THEN 'Male'
        WHEN '2' THEN 'Female'
        ELSE 'Other'
    END AS patients_gender,
        d.ingredients_num
    FROM person c
    JOIN table_3 d ON c.person_id = d.person_id
    ORDER BY d.ingredients_num DESC;

/*
=======================================================================
                      Hypothesis Testing in R
=======================================================================
# Data cleaning
data <- read.csv("data.csv")
data$patients_gender <- as.factor(data$patients_gender)
data$ingredients_num <- as.numeric(data$ingredients_num)
male_data <- subset(data, patients_gender == "Male")$ingredients_num
female_data <- subset(data, patients_gender == "Female")$ingredients_num

# Conduct one-tailed t-test
t_test_result <- t.test(female_data, male_data, alternative = "greater")

# Print the result
print(t_test_result)
if (t_test_result$p.value < 0.05) {
  print("Reject the null hypothesis: Female patients have significantly higher drug exposure than males.")
} else {
  print("Fail to reject the null hypothesis: No significant difference in drug exposure between genders.")
}
=======================================================================
                      R Output: Hypothesis Testing
=======================================================================
Result:
[1] "Reject the null hypothesis: Female patients have significantly higher drug exposure than males."

Conclusion:
-----------
The statistical test confirms that female patients are exposed to significantly more 
drug ingredients than male patients, supporting our hypothesis. This result suggests 
that women may engage more frequently in chronic disease management or preventive 
healthcare, leading to higher drug exposure. Further research is needed to determine 
if this trend is influenced by specific conditions, medication adherence, or 
socioeconomic factors.
=======================================================================
*/