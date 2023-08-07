# Relationship-between-Plasma-Homocysteine-and-Cognitive-Status
This is my final project for SPH BS 805 (Intermediate Statistical Computing and Applied Regression Analysis) where I analyzed the relationship between plasma homocytesine levels and cognitive status using data from a subset of the Framingham Heart Study containing 900 observations and 13 pre-established variables.

Data preparation:
- Merged three seperate data sets into one
- Coded 6 additional new variables
- Addressed missing variables
- Created and applied formats and labels
- Subsetted data to exclude observations with missing Alzheimer's data

Statistical Analyses:
- Developed descriptive statistics using SAS Macro
- Preliminary 2-sample t-tests and Chi-square tests of independence for variables of interest using SAS Macro
- One-factor ANOVA assessing plasma homocysteine levels among 4 age groups
- Piecewise linear regression model assessing plasma homocysteine levels among 4 age groups
- Multiple linear regression predicting cognitive status with plasma homocysteine and sex (dummy variable). Additionally assessed interaction between plasma homocysteine and sex
- Simple linear regression predicting cognitive status with plasma homocysteine
- Multiple linear regression model predicting cognitive status using plasma homocysteine, sex, education, age, and pack years of cigarette smoking
- Final multiple linear regression model predicting cognitive status using education and age only.

Conclusions:
While in a simple linear regression model, plasma homocysteine was a significant predictor of cognitive status, we did not find plasma homocysteine levels to be a significant predictor of cognitive status once we adjusted for other variables. Our final multiple linear regression model predicting cognitive status included only age and education as significant predictors. You can read the full report above titled "BS805 Project Report_final".

Demonstrated SAS skills: Merging and creating new datasets; subsetting data; variable creation; SAS Macro creation; create and apply formats, labels, titles as necessary; generate descriptive statistics; proc freq; proc ttest; proc reg; proc glm; piecewise linear regression  
