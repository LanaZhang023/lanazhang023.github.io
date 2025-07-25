Clinical Trial Reporting Automation using SAS Macros and CDISC-Compliant Workflow
Cleaned, validated, and analyzed over 11,000 patient-level records from a simulated Phase II clinical trial using SAS Base, PROC SQL, and macro programming, strictly following CDISC SDTM/ADaM standards. Developed an end-to-end clinical reporting pipeline that automated:

Data cleaning and derivation (standardizing ARMCD, BMI, Age, AvgCost, Lab Result; resolving missingness and duplicates),
Construction of SDTM DM and ADaM ADSL/ADAE domains, enabling downstream analysis with CDISC-compliant structure,
Exploratory safety and baseline summaries using custom-built macros like %tablen and %report_section for dynamic stratification and statistical testing across treatment arms.
Utilized advanced SAS techniques to:

Generate publication-ready statistical summary tables comparing baseline age, BMI, weight categories, and cost variables by treatment group, with appropriate Kruskal-Wallis and Chi-square tests and custom footnotes and p-value annotations.
Build stratified figures using PROC TTEST and PROC SGPLOT to visualize age distributions and subgroup BMI comparisons (by sex and arm), implementing attribute maps to resolve marker overlaps and ensure clarity in stakeholder presentations.
Simulate adverse event (AE) data and automate AE frequency summary tables using PROC FREQ and inferential outputs, including Chi-square, Fisher’s Exact, and effect size statistics (Cramer’s V, Phi).
The final deliverable was a comprehensive PDF clinical report, fully auto-generated via ODS PDF and PROC ODSTEXT, summarizing patient characteristics, safety findings, and visual insights. Results confirmed strong baseline balance and no significant treatment-emergent AE signals, enabling confident go/no-go decisions for trial progression.

Impact:
This project demonstrates practical, publication-ready use of SAS macro automation and CDISC data standards to produce regulatory-grade clinical summaries, mirroring workflows in CROs and pharmaceutical trial settings. Significantly reduced manual reporting time while improving transparency, reproducibility, and interpretability for clinical stakeholders.
