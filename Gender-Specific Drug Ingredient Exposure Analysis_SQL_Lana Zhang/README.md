# 💊 DrugExTrack: Gender-Specific Drug Ingredient Exposure Analysis  
**SQL Windowing + R Statistical Testing | OMOP CDM v5.2 | CMS Synthetic Data**

---

## 📌 Objective  
This project analyzes **gender-based differences** in **distinct drug ingredient exposure** using CMS synthetic data under the **OMOP Common Data Model (v5.2)**.

> **Research Question**  
Do **female patients** tend to be exposed to more **distinct drug ingredients** than male patients?

> **Hypothesis**  
Women are more likely to be exposed to **multiple drug ingredients** due to higher engagement in **chronic disease management** and **preventive healthcare**.

---

## 🗂️ Dataset Overview

| Table Name     | Description                               |
|----------------|-------------------------------------------|
| `drug_era_1m`  | Patient-level drug exposure records        |
| `concept`      | Drug ingredient metadata                  |
| `person`       | Patient demographic information (gender)  |

---

## 🛠️ Methodology  

### 1. **Data Extraction Using SQL**
- Identified **Top 10 most-used drug ingredients**
- Retrieved all patients exposed to these ingredients
- Counted **distinct drug ingredients** per patient
- Used **SQL window functions** to compute **average exposures by gender**

<details>
<summary>📄 Sample SQL Query</summary>

```sql
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
),
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
```
</details>

---

### 2. **Hypothesis Testing Using R**
Conducted a **one-tailed independent t-test** to determine if female patients are significantly more exposed to distinct drug ingredients than males.

```r
# Load and clean data
data <- read.csv("data.csv")
data$patients_gender <- as.factor(data$patients_gender)
data$ingredients_num <- as.numeric(data$ingredients_num)

# Subset groups
female_data <- subset(data, patients_gender == "Female")$ingredients_num
male_data <- subset(data, patients_gender == "Male")$ingredients_num

# One-tailed t-test
t_test_result <- t.test(female_data, male_data, alternative = "greater")
print(t_test_result)

if (t_test_result$p.value < 0.05) {
  print("✅ Reject the null hypothesis: Female patients have significantly higher drug exposure.")
} else {
  print("❌ Fail to reject the null hypothesis: No significant difference found.")
}
```

---

## 📊 SQL Result Summary

| Gender | Avg. # of Drug Ingredients |
|--------|-----------------------------|
| **Female** | **1.8112** |
| **Male**   | **1.7609** |

📝 *Female patients show a slightly higher average exposure to drug ingredients.*

---

## 🧪 R Result Summary

```
Result: p-value < 0.05  
✅ Reject the null hypothesis  
Female patients have significantly higher drug exposure than males.
```

---

## 📈 Tools & Technologies

- **SQL (PostgreSQL / OMOP CDM v5.2)**
- **Window Functions**
- **R (t.test)**
- **CMS Synthetic Patient Dataset**
- **ETL querying & patient-level exposure statistics**

---

## 🔍 Key Takeaways
- Demonstrated **CDM-based querying logic** in real-world patient datasets.
- Integrated **cross-platform analysis** using SQL + R.
- Verified statistical differences in drug exposure by gender.
- Illustrated **data science workflow** in **clinical informatics** context.

---

## 👩‍⚕️ Author

**Lana (Yingchen) Zhang**  
M.S. in Biostatistics and Data Science @ Cornell University  
Behavioral Health Research Intern @ Neuropath Healthcare Solutions  
GCP Certified | R • SAS • SQL • Python  
[LinkedIn](https://www.linkedin.com/in/lana-zhang-891430327/) |lanazhangny023@gmail.com

Report Date: **March 30, 2025**
