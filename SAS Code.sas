libname Project "/home/u60739998/BS 805/Project";

proc sort data=Project.demog_bs805_f22;
	by demogid;
run;
proc sort data=Project.labs_bs805_f22;
	by labsid;
run;
proc sort data=Project.neuro_bs805_f22;
	by neuroid;
run;

data project_temp;
	merge Project.demog_bs805_f22 Project.labs_bs805_f22 Project.neuro_bs805_f22;
run;

proc format;
	value malef 	0="Female" 
					1="Male";
	value educgf 	1="Education <8 years" 
					2="Education >=8 years, no HS degree" 
					3="HS degree, but no college"
					4="At least some college";
	value adin7yrsf	0="No AD in 7 years"
					1="AD in 7 years";
	value hcyge14f	0="HCY<14"
					1="HCY>=14";
	value agegrpf	0="65-74 years old"
					1="75-79 years old"
					2="80-84 years old"
					3="85-89 years old";
	value hsdegf	0="Less than HS degree"
					1="HS degree or higher";
	value excludef	0="non-missing ADin7yrs value"
					1="missing ADin7yrs value";
	value mmseff	0="No cognitive deficits"
					1="Cognitive deficits";
run;

data Project.fulldataset;
	set project_temp;
	
	lhcy=log(hcy);
	
	if 0 < hcy < 14 then hcyge14=0;
	else if hcy >= 14 then hcyge14=1;
	
	if 65 <= age <=74 then agegrp=0;
	else if 75 <= age <=79 then agegrp=1;
	else if 80 <= age <=84 then agegrp=2;
	else if 85 <= age <=89 then agegrp=3;
	
	if educg = 1 or educg = 2 then hsdeg=0; 
	else if educg = 3 or educg = 4 then hsdeg=1;
	
	if adin7yrs = . then exclude = 1;
	else exclude=0;
	
	if educg = 1 and mmse > 22 then mmsef=0;
	else if educg =1 and 0 < mmse <= 22 then mmsef=1;
	
	if educg = 2 and mmse > 24 then mmsef=0;
	else if educg =2 and 0 < mmse <= 24 then mmsef=1;
	
	if educg = 3 and mmse > 25 then mmsef=0;
	else if educg =3 and 0 < mmse <= 25 then mmsef=1;
	
	if educg = 4 and mmse > 26 then mmsef=0;
	else if educg =4 and 0 < mmse <= 26 then mmsef=1;
	
	label demogid="Subject ID in Demographics" age= "Age (years)" male="Sex" educg="Education level"
	pkyrs="Pack years of cigarette smoking" labsid="Subject ID in Labs" 
	hcy="Plasma homocysteine level (μmol/L)" folate="Plasma folate (nmol/L)"
	vitb12="Plasma vitamin B12 (pmol/L)" vitB6="Plasma B6 (nmol/L)" neuroid="Subject ID in Neuro"
	mmse="Mini-Mental State Examination Score (0-30)" adin7yrs="AD in 7 years f/u"
	lhcy="Natural log of HCY" agegrp="Age group" hsdeg="HS degree or higher vs. no HS degree" 
	exclude="Missing adin7yrs" mmsef="Presence of cognitive deficits based on education and mmse" 
	hcyge14="HCY >= 14 vs. HCY < 14";
	
	format male malef. educg educgf. adin7yrs adin7yrsf. hcyge14 hcyge14f. agegrp agegrpf.
	hsdeg hsdegf. exclude excludef. mmsef mmseff.;
run;

proc contents data=project.fulldataset; run;

%macro ttest(var);

proc ttest data=project.fulldataset;
	class exclude;
	var &var;
	title "Q3. 2-Sample T-test of mean &var by exclusion/non-exclusion group";
run;

%mend ttest;

%ttest (age);
%ttest (pkyrs);
%ttest (mmse);
%ttest (lhcy);

%macro chi(var);

proc freq data=project.fulldataset;
	tables exclude*&var / expected chisq measures nocol nopercent;
	title "Q3. Chi-Square test of &var by exclusion/non-exclusion group";
run;

%mend chi;

%chi(male);
%chi(hsdeg);
%chi(hcyge14);

data temp;
	set project.fulldataset;
	where exclude=0;
	drop exclude;
run;

%macro descrip(var);

proc sgplot data=temp;
	vbar &var;
	title "Q5. Bar chart of &var";
run; 
proc univariate data=temp;
	var &var;
	title "Q5. Descriptive statistics of &var";
run;

%mend descrip;

%descrip (pkyrs);
%descrip (hcy);
%descrip (lhcy);
%descrip (folate);
%descrip (mmse);

*check normality of age;
proc sgplot data=temp;
	vbar age;
	title "Q6. Normality of age";
run;
proc sgplot data=temp;
	scatter x=age y=lhcy;
	title "Q6. Scatterplot of age and log hcy";
run;

proc reg data=temp;
	model lhcy=age; title "Q6. Simple linear regression predicting log hcy with age"; 
run;

proc sgplot data=temp;
	scatter x=age y=mmse;
	title "Q6. Scatterplot of age and MMSE score";
run;
proc reg data=temp;
	model mmse=age; title "Q6. Simple linear regression predicting MMSE score with age"; 
run;

proc sort data=temp;
	by agegrp;
run;

proc glm data=temp;
	class agegrp;
	model lhcy=agegrp;
	means agegrp;
	means agegrp / tukey cldiff;
	lsmeans agegrp / stderr adjust=tukey tdiff;
	title "Q7. 1-factor ANOVA of mean log hcy by age group";
run;

/* question 8*/
data piecewise;
	set temp;
	if (65 <= age < 75) then age1=age;
	else if age >= 75 then age1=75;
	
	if (65 <= age < 75) then age2=75;
	else if (75 <= age < 80) then age2=age;
	else if age >= 80 then age2=80;
	
	if (65 <= age < 80) then age3=80;
	else if (80 <= age < 85) then age3=age;
	else if age >= 85 then age3=85;
	
	if (65 <= age < 85) then age4=85;
	else if age >= 85 then age4=age;
	
	label age1 = "Piecewise variable for 65-74" age2 = "Piecewise variable for 75-79"
	age3 = "Piecewise variable for 80-84" age4 = "Piecewise variable for 85-89";
run;

proc contents data=piecewise; title "Contents of piecewise dataset"; run;

proc sort data=piecewise;
	by age;
run;

proc sgplot data=piecewise;
	series x=age y=age1;
	series x=age y=age2;
	series x=age y=age3;
	series x=age y=age4;
	title "Q8. Visual check of correct creation of piecewise variables";
run;

proc reg data=piecewise;
	model lhcy=age1 age2 age3 age4/ stb;
	output out=piecewise2 p=lhcy_pred;
	test age1=age2;
	test age1=age3;
	test age1=age4;
	test age2=age3;
	test age2=age4;
	test age3=age4;
	title "Q8. Piecewise linear regression analysis";
run; *overall significant, but none of the test statements are sig.?;
proc sgplot data=piecewise2;
	series x=age y=lhcy_pred;
	title "Q8. Piecewise linear regression plot";
run;

/* question 9 */
proc glm data=temp;
	class male;
	model mmse=lhcy male lhcy*male / solution;
	title "Q9. Multiple linear regression predicting MMSE with interaction";
run;

proc glm data=temp;
	class male;
	model mmse=lhcy male / solution;
	lsmeans male / stderr tdiff;
	title "Q9. Multiple linear regression predicting MMSE without interaction";
run;

/* question 10 */
proc sgplot data=temp;
	scatter x=lhcy y=mmse;
	title "Q10. Scatterplot of log hcy and MMSE score";
run;
proc reg data=temp;
	model mmse=lhcy;
	title "Q10. Simple linear regression analysis predicting MMSE score with log hcy";
run;

/*question 11*/
data fullmodel;
	set temp;
	
	if educg=1 then less8=1; else less8=0;
	if educg=2 then grt8noHS=1; else grt8noHS=0;
	if educg=3 then HSnocol=1; else HSnocol=0;
	
	if agegrp=1 then age2=1; else age2=0;
	if agegrp=2 then age3=1; else age3=0;
	if agegrp=3 then age4=1; else age4=0;
	
	label less8="Dummy var <8 years of education" grt8noHS="Dummy var >=8 years, no HS degree" 
	HSnocol="Dummy var HS degree, but no college" age2="Dummy var 75-79" age3="Dummy var 80-84"
	age4="Dummy var 85-89";
run;

proc contents data=fullmodel; title "Q.11 Contents of fullmodel dataset"; run;

proc sgplot data=fullmodel;
	scatter x=pkyrs y=mmse;
	title "Q11. Scatterplot of pack years of cigarette smoking and MMSE score";
run;

proc sgplot data=fullmodel;
	vbox mmse / category=educg;
	title "Q.11 Side-by-side boxplots of MMSE score by education group";
run;
proc sgplot data=fullmodel;
	vbox mmse / category=male;
	title "Q.11 Side-by-side boxplots of MMSE score by sex";
run;
proc sgplot data=fullmodel;
	vbox mmse / category=agegrp;
	title "Q.11 Side-by-side boxplots of MMSE score by age group";
run;

proc rank groups=5 data=fullmodel out=boxplots;
	var lhcy pkyrs;
	ranks rlhcy rpkyrs;
run;

proc sgplot data=boxplots;
	vbox mmse / category=rlhcy;
	title "Q.11 Side-by-side boxplots of MMSE score by quintiles of log hcy";	
run;
proc sgplot data=boxplots;
	vbox mmse / category=rpkyrs; 
	title "Q.11 Side-by-side boxplots of MMSE score by quintiles of pack years of cigarette smoking";	
run;

proc reg data=fullmodel;
	model mmse=lhcy male less8 grt8noHS HSnocol age2 age3 age4 pkyrs / stb clb;
	test less8, grt8noHS, HSnocol = 0;
	test age2, age3, age4 = 0;
	title "Q11. Multiple linear regression model with all predictors";
run;

proc sort data=fullmodel;
	by educg; run;
proc means data=fullmodel;
	var mmse;
	by educg;
	title "Q11. Mean MMSE by education group";
run;
proc sort data=fullmodel;
	by agegrp; run;
proc means data=fullmodel;
	var mmse;
	by agegrp;
	title "Q11. Mean MMSE by age group";
run;
proc sort data=fullmodel;
	by male;run;
proc means data=fullmodel;
	var mmse;
	by male;
	title "Q11. Mean MMSE by sex";
run;

proc reg data=fullmodel;
	model mmse=less8 grt8noHS HSnocol age2 age3 age4 / stb clb vif r;
	test less8, grt8noHS, HSnocol = 0;
	test age2, age3, age4 = 0;
	id demogid;
	output out=influence predicted=mmse_pred residual=mmse_resid student=mmse_stu
	press=mmse_press;
	title "Q11. Final multiple linear regression model with only significant predictors";
run;

proc reg data=fullmodel outest=results;
	model mmse=lhcy male less8 grt8noHS HSnocol age2 age3 age4 pkyrs / selection=rsquare 
	adjrsq cp best=1; 
	title "Q11. Comparing final model against C(p) statistic";
run;
	
proc sgplot data=results;
series x=_p_ y=_cp_;
series x=_p_ y=_p_;
title 'Q.11 CP vs P plot';
run;

/* general assessment - are there any very large or small observations?*/
proc univariate plots normal data=influence;
	id demogid;
	var mmse;
	title "Q11. Assessment of extreme MMSE values";
run;
/* identify influence - predicted values*/
proc univariate plots normal data=influence;
	id demogid;
	var mmse_pred; 
	title "Q11. Assessment of extreme MMSE predicted values";		
run;
/*identify outliers - studentized resid*/
proc univariate plots normal data=influence;
	id demogid;
	var mmse_stu; 
	title "Q11. Assessment of extreme MMSE studentized residuals";
run;
/* identify outliers and influence - PRESS */
proc univariate plots normal data=influence;
	id demogid;
	var mmse_press; 
	title "Q11. Assessment of extreme MMSE PRESS residuals";
run;