/*------------------------------------------------------------------*
| MACRO NAME  : standardization_macro
| SHORT DESC  : Perform data cleaning and variable derivation
|               for Sex/ARMCD/BMI/Age/AvgCost Variables
*------------------------------------------------------------------*
| CREATED BY  : Lana  (07/25/2025)
*------------------------------------------------------------------*
| PARAMETERS
|   in  = input dataset (e.g., raw DM dataset)
|   out = output cleaned dataset (e.g., Baseline)
*------------------------------------------------------------------*/

%macro standardization_macro(in=, out=);

	data &out;
		set &in;

		/*---- Clean ‘Sex’ ----*/
		if sex IN('f' , 'fem', 'Fem', 'female', 'Female') then sex='F';
		else if sex IN('m', 'mal', 'Mal', 'male', 'Male') then sex='M';
		else if sex IN('na', 'n/a') then sex=' '; /* Set missing values */

		/*---- Clean ‘ARMCD’ ----*/
		ARMCD = strip(ARMCD);
		if upcase(ARMCD) = 'PLACEBO' then ARMCD = 'Placebo';
		else if upcase(ARMCD) = 'DRUG A' then ARMCD = 'Drug A';
		else if upcase(ARMCD) = 'DRUG B' then ARMCD = 'Drug B';
		else if ARMCD in ('na', 'n/a') then ARMCD = ' '; /* Set missing values */

		/*---- Set Study_end_Date ----*/
		if Study_end_Date ne '01OCT2024'd then Study_end_Date = '01OCT2024'd;

		/*---- Create Age ----*/
		Age = int((EnrollDate - BRTHDAT) / 365.25); /* 365.25 accounts for leap years */

		/*---- Calculate BMI ----*/
		BMI=WEIGHT / HEIGHT**2;
		BMI = round(BMI, 0.1); /* keep only one decimal place */

		/*---- Categorize BMI ----*/
		length cWeight $15;
		if BMI=. then cWeight=' ';
		else if BMI < 18.5 then cWeight='Underweight';
		else if 18.5 <= BMI < 25 then cWeight='Normal weight';
		else if 25 <= BMI < 30 then cWeight='Overweight';
		else if 30 <= BMI < 40 then cWeight='Obese';
		else if BMI >= 40 then cWeight='Morbidly Obese';

		/*---- Compute Average Cost ----*/
		AvgCost = mean(Cost1, Cost2, Cost3);
		AvgCost = round(AvgCost, 0.01);
		label AvgCost = 'Average Cost';

		/*---- Clean Lab Test Result ----*/
		if LBRES = ' ' then LBRES = 'NA';
		label LBRES = 'Lab test result';

		/*---- Filter CWID ----*/
		n = find(Include, 'yiz4018', 'i');
		if n = 0 then delete;

	run;

%mend;