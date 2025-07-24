Libname yiz4018 xlsx '/home/u64016874/SAS/patients_raw_data.xlsx';

/* Data cleaning----------------------------------------------------------------- */
DATA Baseline;
	SET yiz4018.DM_Raw;

	/* Clean ‘Sex’ */
	if sex IN('f' , 'fem', 'Fem', 'female', 'Female') then
		sex='F';
	else if sex IN('m', 'mal', 'Mal', 'male', 'Male') then
		sex='M';
	else if sex IN('na', 'n/a') then
		sex=' '; /* Set missing values */
	
	/* Clean ‘ARMCD’ */
	ARMCD=strip(ARMCD); /* Remove leading and trailing blanks */
	if upcase(ARMCD)='PLACEBO' then
		ARMCD='Placebo';
	else if upcase(ARMCD)='DRUG A' then
		ARMCD='Drug A';
	else if upcase(ARMCD)='DRUG B' then
		ARMCD='Drug B';
	else if ARMCD IN('na', 'n/a') then
		ARMCD=' '; /* Set missing values */

	/* Clean ‘Study_end_Date’ */
	if Study_end_Date ne '01OCT2024'd then
		Study_end_Date='01OCT2024'd;

	/* Create ‘Age' */
	Age=int((EnrollDate - BRTHDAT) / 365.25); /* 365.25 accounts for leap years */

	/* Create ‘BMI' */
	BMI=WEIGHT / HEIGHT**2;
	BMI=round(BMI, 0.1); /* keep only one decimal place */

	/* Create 'cWeight'*/
	length cWeight $15;
	if BMI=. then
		cWeight=' ';
	else if BMI < 18.5 then
		cWeight='Underweight';
	else if 18.5 <=BMI < 25 then
		cWeight='Normal weight';
	else if 25 <=BMI < 30 then
		cWeight='Overweight';
	else if 30 <=BMI < 40 then
		cWeight='Obese';
	else if BMI >=40 then
		cWeight='Morbidly Obese';

	/* Create 'AvgCost'*/
	AvgCost=MEAN(Cost1, Cost2, Cost3);
	AvgCost=round(AvgCost, 0.01);
	label AvgCost='Average Cost';

	/* Clean 'LBRES'*/
	if LBRES=' ' then LBRES='NA';
	label LBRES='Lab test result';

	/* Filter CWID */
	n=find(Include, 'yiz4018', 'i');
	if n=0 then delete;
run;

/* Remove duplicated rows */
proc sort data=Baseline out=yiz4018_forfinal noduprecs dupout=Duplicated;
	by _all_;
run;

/* Data Visualization------------------------------------------------------------- */
%let dsid = %sysfunc(open(yiz4018_forfinal));
%let nobs = %sysfunc(attrn(&dsid, NOBS));
%let rc = %sysfunc(close(&dsid));
title "(*ESC*)S={just=center font=('arial', 14pt, bold) textdecoration=underline}Clinical Report";
title2 " ";
title3 "(*ESC*)S={just=center font=('arial', 10pt)}by: Lana Zhang";
title4 "(*ESC*)S={just=center font=('arial', 10pt)}%sysfunc(today(), worddate.)";
title5 " ";
title6 "(*ESC*)S={just=center font=('arial', 9pt, bold)}The total number of observations after cleaning is (*ESC*)S={foreground=red}&nobs";

/* Table-1 */
Proc sort data=yiz4018_forfinal out=table_1;
	by USUBJID; /* sorted by ID in ascending order */
run;

title7 " ";
title8 "Table-1: List of the first 100 observations after cleaning, calculation";

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

/* Table-2 */
%include "/home/u64016874/SAS/FInal Project/TABLEN_web_20210718 _ZChen.sas"; /* The external file where the %tablen macro is defined */
title "(*ESC*)S={just=center font=('arial', 12pt, bold)}Table-2";
%tablen(
    data=yiz4018_forfinal, 
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

/* Figure-1 */
title "(*ESC*)S={just=center font=('arial', 12pt, bold)}Figure-1";
title2 "(*ESC*)S={just=center font=('arial', 11pt, bold)}Distribution of Age Stratified by Treatment Group";
title3 " ";
ods graphics on / imagefmt=png;
ods select SummaryPanel QQPlot;
ods noproctitle;

Proc ttest data=yiz4018_forfinal;
	class ARMCD; /* ARMCD for grouping variable */
	var AGE; /* Age for y-axis */
run;

ods graphics off;
ods select all;
ods proctitle;
title;

/* Figure-2: Boxplot of BMI by Sex and ARMCD */
ods graphics on / imagefmt=png;
title "(*ESC*)S={just=center font=('arial', 12pt, bold)}Figure-2";
title2 " ";

data yiz4018_forfinal_figure2;
	set yiz4018_forfinal;
	where 17 <=Age <=70 and not missing(Sex); /* Filter the data for analysis */
run;

proc sort data=yiz4018_forfinal_figure2;
	by SEX; /* Sort the data by SEX */
run;

proc sgplot data=yiz4018_forfinal_figure2;
	
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