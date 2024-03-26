# GEP
This whole project aims to build a dataset that would demonstrate the gender gap in individuals' values across various countries.

Please refer to https://europeanvaluesstudy.eu/methodology-data-documentation/integrated-values-surveys/data-and-documentation/ for compiling the IVS file from WVS and EVS trend file.

## IVS_loop
1. calculate the initial parameters: weighted mean , weighted standard deviation , share of min and max of IVS.
2. add the meaning and label by merging with the label file

*note:*
Due to the excessive size of the document, I separates the dataset into different sub dataset. It will generate a dta file called "**IVS_final_labelled**" with all the essential variables and labels.

## labelbook
1. generate the value label for IVS (*ssc install codebookout if needed)

## GDP_GGGI_merge
1. merge GDP, GGGI with IVS

*note:*
Since different documents record country names in different ways, we need to manually edit some of the names to match them up. 

The code will generate a data file called "**Indicator_IVS**" at the end.

## IVS2020
1. calcuate the standard gender gap, mean of GDP and GGGI for each country for 2010 and beyond.
