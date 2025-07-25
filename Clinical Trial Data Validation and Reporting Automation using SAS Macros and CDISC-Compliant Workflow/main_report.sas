/* 
===========================================================
CLINICAL STUDY REPORT: EXECUTIVE SUMMARY
===========================================================

Study Title   : Evaluation of Baseline Comparability and Adverse Event Patterns 
Study ID      : CT-001
Trial Phase   : Phase II (Simulated)
Report Date   : July 25, 2025
Author        : Lana Zhang, M.S.
Department    : Biostatistics and Data Science, Weill Cornell Graduate School

Background
----------
This report documents a simulated Phase II randomized controlled trial (RCT) designed to assess 
baseline demographic comparability and adverse event distribution between Drug B and Placebo groups. 
The analysis adheres to CDISC (Clinical Data Interchange Standards Consortium) standards, including 
the SDTM (Study Data Tabulation Model) and ADaM (Analysis Data Model) structures.

Objective
---------
The primary objective is to validate randomization balance and evaluate potential safety signals. 
The study focuses on:
 - Standardizing raw patient data;
 - Building regulatory-compliant SDTM and ADaM datasets;
 - Performing exploratory statistical summaries and visualizations.

Data Source
-----------
The patient-level dataset was simulated and imported from the Excel file: 'patients_raw_data.xlsx'  
It includes de-identified subject-level records with information on:
 - Demographics (sex, age, BMI)
 - Treatment assignment (ARMCD)
 - Enrollment & end dates
 - Safety outcomes (lab data, adverse events)
 - Derived variables (e.g., cost, BMI categories)

Programming Standards
---------------------
All data cleaning, derivation, and reporting follow:
 - CDISC SDTM/ADaM standards;
 - FDA submission readiness principles;
 - SAS 9.4 programming environment;
 - Best practices in clinical programming and exploratory analysis.

Report Components
-----------------
This report includes three major analytical components:

1. **Raw Data Cleaning and Variable Derivation** 
 
1.1 **Standardization of Key Variables**
    - Recoding and formatting of SEX and ARMCD variables.
    - Calculation of derived variables such as BMI and Average Cost.
    - Age computed based on birth date and reference date.
    
1.2 **Data Quality Assurance**
    - Identification and removal of duplicate patient records.
    - Imputation flags and documentation of missing values.
    
2. **CDISC-Compliant Dataset Construction**

2.1 **SDTM DM Domain (Demographics)**
    - Extraction and transformation of subject-level demographic data.
    - Mapping of source variables to CDISC SDTM-compliant DM structure.

2.2 **ADaM ADSL Domain (Subject-Level Analysis Dataset)**
    - Merging of demographic, treatment, and derived variables.
    - Creation of analysis-ready ADSL dataset with required ADaM metadata.
    
2.3 **ADaM ADAE Domain (Adverse Events Analysis Dataset)**
    - Simulated construction of the ADAE domain to support adverse event analysis.
    - AE terms were programmatically assigned in an alternating pattern between "Headache" and "Nausea" to create a mock dataset.
    - Treatment group variable (`TRT01P`) was mapped from the original treatment code (`ARMCD`) for each subject.

3. **Exploratory Safety Summary and Data Visualization**

3.1 **Table1: Patient Snapshot After Preprocessing**
    - Displays the first 100 cleaned patient records.
    - Validates deduplication, variable standardization, and structural readiness.

3.2 **Table2: Baseline Characteristics Comparison**
    - Summary statistics of key demographic and clinical variables.
    - Between-group comparison using nonparametric and categorical tests.
    - P-values from Kruskal-Wallis and Chi-Square tests included.

3.3 **Table3: Adverse Event Frequency Summary**
    - Counts and proportions of major adverse events (Headache, Nausea).
    - Chi-Square and Fisher’s Exact tests for treatment group comparisons.

3.4 **Figure 1: Age Distribution by Treatment Group**
    - Histogram and Q-Q plots from PROC TTEST to evaluate distributional differences.
    - Assess symmetry and comparability of age distributions.

3.5 **Figure 2: BMI Distribution by Sex and Treatment Group**
    - Stratified boxplots visualizing BMI patterns across treatment arms and sex.
    - Highlights potential outliers and evaluates baseline BMI balance.

Key Results Summary
-------------------
 - A total of **11,878 patients** were analyzed after preprocessing.
 - **Baseline demographics** (age, BMI, cost) were well-balanced across treatment groups.
 - **Adverse events** (Headache and Nausea) showed no statistically significant difference between Drug B and Placebo (P > 0.70).
 - Visualizations further confirmed demographic and safety comparability.

Conclusion
----------
The study confirms successful baseline balance through randomization and suggests no initial safety concerns 
between Drug B and Placebo arms based on reported adverse events. The analytical pipeline demonstrates 
standard-compliant, auditable clinical data processing.

===========================================================
*/

Libname yiz4018 xlsx '/home/u64016874/SAS/Clinical_Trial_Project/patients_raw_data.xlsx';
%include "/home/u64016874/SAS/Clinical_Trial_Project/standardization_macro.sas";
%include "/home/u64016874/SAS/Clinical_Trial_Project/tablen_macro.sas"; 

/* ------ 1. Raw Data Cleaning and Variable Derivation ------ */
/* 1.1 Sex/ARMCD/BMI/Age/AvgCost Variable Standardization */
%standardization_macro(in=yiz4018.DM_Raw, out=Baseline);

/* 1.2 Handling Missing & Duplicate Records */
proc sort data=Baseline out=Final noduprecs dupout=Duplicated;
	by _all_;
run;

/* ----- 2. Construction of SDTM DM and ADaM ADSL Domains ----- */
/* 2.1 Construct SDTM DM Domain */
libname sdtm '/home/u64016874/SAS/Clinical_Trial_Project';
data sdtm.stdm_dm;
    set Final;
    STUDYID = "CT-001";                       /* Unique study identifier */
    DOMAIN = "DM";                            /* Domain Name: Demographics */
    USUBJID = USUBJID;                        /* Unique Subject Identifier */
    SUBJID = scan(USUBJID, -1, "-");          /* Extract Subject ID from USUBJID (e.g., from 'CT-001-101' get '101') */
    RFSTDTC = put(EnrollDate, yymmdd10.);     /* Convert enrollment and end dates to ISO 8601 format (yyyy-mm-dd) */
    RFENDTC = put(Study_end_Date, yymmdd10.);
    SEX = sex;
    ARMCD = ARMCD;
    AGE = age;
run;

/* 2.2 Construct ADaM ADSL Domian */
libname adam '/home/u64016874/SAS/Clinical_Trial_Project';
data adam.adam_adsl;
    set sdtm.stdm_dm;
    ADSLSEQ = _N_; /* Sequential record ID */
   
    /* Treatment assignment and dates */
    TRT01A = ARMCD;           /* Actual treatment received */
    TRTSDT = EnrollDate;      /* Treatment start date */
    TRTEDT = Study_end_Date;  /* Treatment end date */
    
    /* Create an age group variable for stratified analysis */
    AGEGR1 = ifc(age < 40, "<40", ifc(age <= 60, "40-60", ">60"));
    
    BMI_CAT = cWeight;
    
    keep STUDYID USUBJID TRT01A TRTSDT TRTEDT AGE AGEGR1 BMI BMI_CAT;
run;

/* 2.3 Construct Mock ADaM ADAE Dataset */
data adam.adam_adae;
	set Final;
	length AETERM $50 TRT01P $10;
	
    /* Assign AE term: alternate between 'Headache' and 'Nausea' */
	AETERM = "Headache";
	if mod(_N_, 2) = 0 then AETERM = "Nausea"; /* Even-numbered records get 'Nausea' */
	
	TRT01P = ARMCD; /* Assign treatment group for the AE term (from ARMCD) */
run;

/* ----- 3. Exploratory Safety Summary and Data Visualization ------ */
ods pdf file="/home/u64016874/SAS/Clinical_Trial_Project/clinical_study_report.pdf" 
    notoc 
    dpi=300 
    style=journal;
%let dsid = %sysfunc(open(Final));
%let nobs = %sysfunc(attrn(&dsid, NOBS));
%let rc = %sysfunc(close(&dsid));
title " ";
title2 "(*ESC*)S={just=center font=('arial', 14pt, bold) textdecoration=underline}CLINICAL STUDY REPORT SUMMARY";
title3 " ";
title4 "(*ESC*)S={just=center font=('arial', 10pt)}Study ID: CT-001 | Trial Phase: II | %sysfunc(today(), worddate.)";
title5 "(*ESC*)S={just=center font=('arial', 10pt)}Prepared by: Lana Zhang | Department of Biostatistics and Data Science";
title6 " ";
title7 " ";
ods pdf startpage=no;

proc odstext;
  p " " / style=[font_size=10pt];

  p "Study Summary" / style=[font_size=11pt font_weight=bold];
  p " ";
  p "This clinical study report summarizes a simulated Phase II randomized controlled trial evaluating the baseline comparability and safety profile of Drug B versus Placebo." / style=[font_size=10pt];
  p " ";
  p "The dataset consists of 11,878 patient-level records drawn from a synthetic Excel file ('patients_raw_data.xlsx'), representing demographic, cost, and adverse event data from a real-world-inspired clinical scenario. Data were cleaned, standardized, and mapped according to CDISC conventions to produce compliant SDTM and ADaM domains." / style=[font_size=10pt];
  p " ";
  p "Key deliverables in this report include:" / style=[font_size=10pt];
  p "- Table 1: Snapshot of cleaned patient data for verification." / style=[font_size=10pt];
  p "- Table 2: Baseline demographic and clinical characteristics by treatment group, with statistical comparison." / style=[font_size=10pt];
  p "- Table 3: Frequency and distribution of common adverse events by treatment group." / style=[font_size=10pt];
  p "- Figure 1: Distribution and statistical comparison of patient age across treatment arms." / style=[font_size=10pt];
  p "- Figure 2: Stratified boxplot of BMI by sex and treatment group." / style=[font_size=10pt];
  p " ";
  p "All results support the quality and balance of randomization, and no significant safety signals were observed." / style=[font_size=10pt];

  p " " / style=[font_size=10pt];
run;

title;

/* 3.1 Table-1: Patient Characteristics Snapshot After Cleaning */
Proc sort data=Final out=table_1;
	by USUBJID; /* sorted by ID in ascending order */
run;

title7 " ";
title8 "Table-1: Patient Characteristics Snapshot After Cleaning ";

Proc print data=table_1(obs=100) label;
	var USUBJID Sex Age ARMCD EnrollDate Study_end_date BMI cWeight AvgCost LBRES;
	label USUBJID='Unique Subject ID' Sex='Sex' ARMCD='Treatment Group' 
		EnrollDate='Enroll Date' Study_end_date='Study End Date' 
		cWeight='Weight Status' LBRES='Lab test result' AvgCost='Average Cost'; /* label the variables*/
	format AvgCost dollar8.2;
	informat EnrollDate Study_end_date date9.;
	format EnrollDate Study_end_date mmddyy10.; /* format the date */
run;

title;

proc odstext;
    p "Table 1. Patient Characteristics Snapshot After Cleaning" / style=[font_weight=bold font_size=10pt];
    p "This table lists the first 100 observations from the cleaned dataset. It includes key variables such as subject ID, sex, age, treatment group, enrollment dates, BMI, weight status, lab results, and cost information." / style=[font_size=10pt];
    p "The data provides a quick validation of the standardization and deduplication steps performed during the preprocessing phase." / style=[font_size=10pt];
run;

/* 3.2 Table-2: Baseline Characteristics by Treatment Group */
title "(*ESC*)S={just=center font=('arial', 12pt, bold)}Table-2: Baseline Characteristics by Treatment Group";
%tablen_macro(
    data=Final, 
    var=Age BMI cWeight AvgCost, 
    type=1 1 2 1, /* variable type */
	by=ARMCD, 
	bylabel=Treatment Group, 
	contdisplay=n_nmiss mean_sd median_range, 
	dis_display=n_pct,
	pvals=1, 
	pfoot=1, 
	showtotal=1, /* Show the total column */
	showpval=1 /* Show the p-value column */
	);
title;

proc odstext;
    p " " / style=[font_size=10pt];

    p "★ Table 2. Baseline Characteristics by Treatment Group" / style=[font_weight=bold font_size=10pt];
    p "This table compares key baseline characteristics across three treatment groups: Missing (N=112), Drug B (N=5905), and Placebo (N=5973). A total of 11,878 patients were included in the analysis. Age was approximately balanced across groups, with a mean of 41.2 years in the Drug B group and 41.7 years in the Placebo group. The Kruskal-Wallis test showed no statistically significant difference in age (P=0.2732). BMI was also similar among groups, with a mean of 21.3 kg/m² across both Drug B and Placebo. No significant difference was observed (P=0.6165). In terms of BMI categories (cWeight), nearly half of the participants fell into the 'Normal weight' group across all arms (49.1%), and about 28% were classified as 'Underweight'. The proportion of 'Obese' and 'Morbidly Obese' subjects was low (<5%). Chi-square testing indicated no significant group difference (P=0.8479). The average cost variable was normally distributed with similar means across groups: 64.4 in Drug B and 64.3 in Placebo. There was no significant difference (P=0.5427). Overall, the randomization process appears to have achieved baseline balance across treatment groups, supporting the validity of downstream comparative analyses." / style=[font_size=10pt];
run;
 
/* 3.3 Table-3: Adverse Events Summary by Treatment Group */
title " ";
title "Table-3: Adverse Events Summary by Treatment Group";

proc freq data=adam.adam_adae; /* Two-way frequency table */
	tables AETERM*TRT01P / chisq nocol nopercent; /* request Chi-square test and suppress column percentage */
run;

title;

proc odstext;
    p " " / style=[font_size=14pt];

    p "★ Table 3. Adverse Events Summary by Treatment Group" / style=[font_weight=bold font_size=10pt];
    p "This table summarizes the frequency of two common adverse events (AEs) — Headache and Nausea — across the Drug B and Placebo treatment groups. A total of 11,878 observations were included (112 records had missing AE information). Headache was reported in 49.55% of Drug B and 50.45% of Placebo participants. Nausea occurred in 49.88% and 50.12% of participants in the respective groups. AE frequencies were nearly identical between groups. The Chi-square test yielded a non-significant result (χ²=0.1343, df=1, P=0.7140), indicating no statistically significant difference in adverse event distribution between treatment groups. Other tests, including the likelihood ratio and Fisher’s exact test, corroborated this conclusion (two-sided P=0.7273). The effect size measures (Phi coefficient, Cramer’s V) were close to zero, reinforcing the interpretation that the observed differences are minimal and likely due to chance. Overall, no evidence was found of an association between treatment group and the occurrence of reported adverse events." / style=[font_size=10pt];
run;


/* 3.4 Figure-1: Distribution of Patient Age Stratified by Treatment Group */
title "(*ESC*)S={just=center font=('arial', 12pt, bold)}Figure-1";
title2 "(*ESC*)S={just=center font=('arial', 11pt, bold)}Distribution of Patient Age Stratified by Treatment Group";
title3 " ";
ods graphics on / imagefmt=png;
ods select SummaryPanel QQPlot;
ods noproctitle;

Proc ttest data=Final;
	class ARMCD; /* ARMCD for grouping variable */
	var AGE; /* Age for y-axis */
run;

ods graphics off;
ods select all;
ods proctitle;
title;

proc odstext;
    p " " / style=[font_size=10pt];
    
    p "★ Figure 1. Distribution of Patient Age Stratified by Treatment Group" / style=[font_weight=bold font_size=10pt];
    p "The figure illustrates the distribution of age by treatment arm using a combination of histogram, summary panel, and Q-Q plots. The TTEST procedure also provides statistical comparison between groups. The histogram, kernel density, and normal distribution overlays demonstrate that age is approximately uniformly distributed in both groups with similar ranges and central tendencies. The boxplots further confirm that age distributions are comparable, supporting the assumption of group balance for age." / style=[font_size=10pt];
run;
run;

/* 3.5 Figure-2: Boxplot of BMI by Sex and Treatment Group */
ods graphics on / imagefmt=png;
title "(*ESC*)S={just=center font=('arial', 12pt, bold)}Figure-2: Boxplot of BMI by Sex and Treatment Group";
title2 " ";

data Final_figure2;
	set Final;
	where 17 <=Age <=70 and not missing(Sex); /* Filter the data for analysis */
run;

proc sort data=Final_figure2;
	by SEX; /* Sort the data by SEX */
run;

proc sgplot data=Final_figure2;
	
	vbox BMI / group=SEX 
	category=ARMCD /* Grouping and categorize */
	transparency=0.25 groupdisplay=cluster 
	clusterwidth=0.5 boxwidth=1
	meanattrs= circle outlierattrs= circle
	name="box";
	
	Styleattrs DATACOLORS=(lightcoral lightblue)
	Datacontrastcolors=(brown bib);
		
	/* X-axis */
	xaxis label="Treatment Group" labelAttrs=(family=arial size=12pt color=black 
		weight=bold style=normal) valueAttrs=(family=arial size=10pt weight=bold);

	/* Y-axis */
	yaxis label="BMI" labelattrs=(family=arial size=12pt color=black weight=bold) 
		valueattrs=(family=arial size=10pt weight=bold);

	/* Legend */
	keylegend "box" / title="SEX" location=outside position=top border;

	/* Title */
	title "Distribution of BMI by Sex and Treatment Group";
	title2 "(For adult patients older than 17 and younger than 70)";
run;

title;

proc odstext;
    p " " / style=[font_size=10pt];

    p "★ Figure 2. Boxplot of BMI by Sex and Treatment Group" / style=[font_weight=bold font_size=10pt];
    p "This boxplot shows BMI distributions across treatment groups, further stratified by sex. Adult patients aged 17–70 were included in this figure. Boxplots indicate that both males and females in the Drug B and Placebo groups show similar BMI medians and interquartile ranges. There are visible outliers, especially among males, but overall group-level BMI distributions appear balanced, suggesting no baseline BMI confounding between treatment groups." / style=[font_size=10pt];

run;

ods pdf close;