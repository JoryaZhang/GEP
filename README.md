# GEP
This whole project aims to build a dataset that would demonstrate the gender gap in individuals' values across various countries.

for compiling the IVS file from WVS and EVS trend file.
Please refer to https://europeanvaluesstudy.eu/methodology-data-documentation/integrated-values-surveys/data-and-documentation/ 

EVS: doi:10.4232/1.14021

WVS: doi:10.14281/18241.23

then run ZA7503_EVS_WVS_Merge_Syntax_stata.do to compile the Integrated_values_surveys_1981-2022

GGGI Data Download: https://prosperitydata360.worldbank.org/en/indicator/WEF+GGR+INDEX
Downloaded excel **"WEF-GGR.xlsx"** is included in the file

Annual GDP Download: https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
Downloaded excel **"API_NY.GDP.MKTP.CD_DS2_en_excel_v2_93.xls"** is included in the file


## IVS_loop
1. calculate the initial parameters: weighted mean , weighted standard deviation , share of min and max of IVS.
2. generate the labelbook
3. add the meaning and label by merging with the label file

*note:*
1. Due to the excessive size of the document, I separates the dataset into different sub dataset. It will generate a dta file called "**IVS_final_labelled**" with all the essential variables and labels.
2. install the  **codebookout** command to export the labelbook if needed


## GDP_GGGI_merge
1. merge GDP, GGGI with IVS

*note:*
Since different documents record country names in different ways, we need to manually edit some of the names to match them up. 

The code will generate a data file called "**Indicator_IVS**" at the end.

## IVS2020
1. calcuate the standard gender gap, mean of GDP and GGGI for each country for 2010 and beyond.

The code will generate a data file called "**Indicator_IVS_2**" at the end.

## analysis_IVS_3
data analysis includes
1. getting the correlation of std_gg and GDP
2. getting the correlation of std_gg and GGGI
3. a rough pca analysis
