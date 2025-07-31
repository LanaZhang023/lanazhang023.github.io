# 🧪 Clinical Trial Data Validationa and Reporting Automation using SAS Macros and CDISC-Compliant Workflow

A CDISC-compliant SAS workflow for clinical trial data preprocessing, statistical reporting, and automated visualization.

---

## 📋 Project Summary

This project simulates a **Phase II clinical trial** with over **11,000 patient records**, automating the full pipeline from raw Electronic Data Capture (EDC) data to a polished **regulatory-grade PDF report** using **SAS macro programming**. The workflow strictly adheres to **CDISC SDTM/ADaM** standards and replicates real-world data cleaning, safety analysis, and baseline comparability assessments in clinical trials.

---

## ⚙️ Key Features

### 📊 Macros Development

This project features two key reusable SAS macros designed to streamline clinical trial data standardization and baseline reporting in compliance with CDISC practices:

1.`%standardization_macro`: cleans and derives analysis-ready variables
 * **Sex** normalization (e.g., 'fem' → 'F')
 * **Treatment arm** recoding ('DRUG A' → 'Drug A')
 * **Age** from birthdate and enrollment date
 * **BMI** and **BMI categories** (Underweight, Normal, etc.)
 * **Average Cost** calculations (mean of 3 cost fields, rounded)
 * Imputes **missing Study_end_Date** to trial cutoff (01OCT2024)
 * Replaces **missing values** with 'NA', standardizes label
 * Keeps only **CWIDs** containing 'yiz4018' for simulated inclusion criteria

2. `%tablen` macro: auto-generate formatted baseline comparison tables

 * **Kruskal-Wallis** and **Chi-square** tests for group difference
 * **P-value annotations** with descriptive footnotes
 * Supports both **continuous** and **categorical** variables
 * Built-in **total column** and **footnotes** for clinical readability

### 🔧 Data Cleaning & Standardization

* Standardized clinical trial variables using `%standardization_macro`
* Removed **duplicate records** and handled **missing values** using `PROC SORT`

### 📦 CDISC-Compliant Dataset Construction

All datasets followed **CDISC variable naming conventions** and metadata standards

* Built **SDTM DM domain** for demographic metadata
* Created **ADaM ADSL** dataset by merging treatment, demographic, and derived variables
* Constructed **ADaM ADAE** dataset with simulated AE terms (e.g., *Headache*, *Nausea*) and treatment mapping

### 📈 Data Visualizations

* Created Baseline Characteristics Table by Treatment Group using `%tablen` macro
* Generated Adverse Events Summary by Treatment Group using `PROC FREQ`
* Used `PROC TTEST` to produce summary panels and Q–Q plots for **Age distribution** by treatment group
* Created grouped **boxplots for BMI** (stratified by **Sex × Treatment**) via `PROC SGPLOT`
* Applied `STYLEATTRS` and `ATTRIBUTE MAPS` to control marker display and improve interpretability

### 📋 Automated Report Generation

* Generated fully formatted **PDF report** using `ODS PDF` and `PROC ODSTEXT`
* Report includes:
  * **Executive summary**, study metadata, and CDISC context
  * Descriptive captions for all tables and figures
  * Automated statistical interpretations with clinical insight
* Mimics **CRO deliverables** used in sponsor-facing documentation

---

## 📊 Output Summary

### **Tables**

| Table       | Description                                                       |
| ----------- | ----------------------------------------------------------------- |
| **Table 1** | Snapshot of Cleaned Patient Data (first 100 records)              |
| **Table 2** | Baseline Characteristics Comparison by Treatment Group            |
| **Table 3** | Adverse Event Frequencies Summary by Treatment Group              |

### **Figures**

| Figure       | Description                                                |
| ------------ | ---------------------------------------------------------- |
| **Figure 1** | Age Distribution by Treatment Group (Histogram + Q–Q Plot) |
| **Figure 2** | Boxplot of BMI by Sex and Treatment Group                  |

---

## 🧠 Clinical Insights

* ✅ Age, BMI, and cost were **balanced at baseline** across all arms
* ✅ **No significant difference** in AE frequencies (P > 0.7)
* ✅ Report supports **randomization validity** and **safety comparability**
* ✅ Demonstrates **real-world application of SAS macros** and CDISC structuring
* ✅ Ready for inclusion in **regulatory filing or stakeholder presentation**

---

## 🧰 Tech Stack

| Tool                         | Role                                                |
| ---------------------------- | --------------------------------------------------- |
| **SAS Base + PROC SQL**      | Data cleaning, transformation, merging              |
| **%tablen Macro**            | Flexible table automation with statistical tests    |
| **PROC TTEST / PROC SGPLOT** | Visualization with stratification and boxplots      |
| **ODS PDF + ODSTEXT**        | PDF formatting, inline reporting and interpretation |
| **CDISC SDTM / ADaM**        | Data structure standards for clinical reporting     |

---

## 👩‍⚕️ Author

**Lana (Yingchen) Zhang**  
M.S. in Biostatistics and Data Science @ Cornell University  
Behavioral Health Research Intern @ Neuropath Healthcare Solutions  
GCP Certified | R • SAS • SQL • Python  
[LinkedIn](https://www.linkedin.com/in/lana-zhang-891430327/) |lanazhangny023@gmail.com

Report Date: **July 30, 2025**
