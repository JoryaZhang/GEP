*This file merges GDP, GGGI with IVS
****************************************************

clear

****************************************************
****************************************************

*IVS+GDP+GGGI
cd ~/Desktop/Thesis/Stata/IVS/
****************************************************
import excel API_NY.GDP.MKTP.CD_DS2_en_excel_v2_93.xls, firstrow clear

foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
drop Indicator_Name Indicator_Code

foreach x of varlist _1960-_1980 {
drop `x'
}

reshape long _, i(Country_Name) j(year)
rename _ GDP
save GDP, replace
****************************************************
use GDP, clear
rename Country_Name Definition
rename year Year
save GDP_IVS, replace

****************************************************

import excel "WEF-GGR.xlsx", sheet("Data") firstrow clear
keep if Indicator=="Overall Global Gender Gap Index"
keep if Attribute1=="Index"
drop IndicatorID Indicator Attribute1 Attribute2 Attribute3 Partner
rename (I J K L M N O P Q R S T U V W X) (gggi2006 gggi2007 gggi2008 gggi2009 gggi2010 gggi2011 gggi2012 gggi2013 gggi2014 gggi2015 gggi2016 gggi2017 gggi2018 gggi2020 gggi2021 gggi2022 )
reshape long gggi, i(EconomyISO3 EconomyName) j(Year)
save gggi.dta, replace
****************************************************

use gggi, clear
drop if gggi==.
rename EconomyName Definition
save GGGI_IVS, replace
****************************************************
****************************************************

use IVS_final_labelled, clear
merge m:m Country using ISO, keepusing(Definition)
drop if _merge==2
*check if all country is matched
egen temp=tag(Country)
list Country Definition if  temp==1 & _merge==1
*manually matching for some missing definition
replace Definition="Northern Cyprus" if  Country==197
replace Definition="Northern Ireland" if  Country==909
replace Definition="Kosovo" if  Country==915
*rename some definition to match with GDP file
replace Definition="Bolivia" if Definition=="Bolivia, Plurinational State of"
replace Definition="Egypt, Arab Rep." if Definition=="Egypt"
replace Definition="Hong Kong SAR, China" if Definition=="Hong Kong"
replace Definition="Iran, Islamic Rep." if Definition=="Iran, Islamic Republic of"
replace Definition="Kyrgyz Republic" if Definition=="Kyrgyzstan"
replace Definition="Kazakhstan" if Definition=="Kazakstan"
replace Definition="Korea, Rep." if Definition=="Korea, Republic of"
replace Definition="Libya" if Definition=="Libyan Arab Jamahiriya"
replace Definition="Macao SAR, China" if Definition=="Macao"
replace Definition="Moldova" if Definition=="Moldova, Republic of"
replace Definition="North Macedonia" if Definition=="Macedonia, The Former Yugoslav Republic Of"
replace Definition="Russian Federation" if Definition=="Russia Federation"
replace Definition="Serbia" if Definition=="Republic of Serbia"
replace Definition="Slovak Republic" if Definition=="Slovakia"
replace Definition="Turkiye" if Definition=="Turkey"
replace Definition="Tanzania" if Definition=="Tanzania, United Republic of"
replace Definition="Venezuela, RB" if Definition=="Venezuela"
replace Definition="Viet Nam" if Definition=="Vietnam"
replace Definition="Yemen, Rep." if Definition=="Yemen"

drop _merge temp
drop if Year<2010
save IVS_final_cc, replace
merge m:1 Definition Year using GDP_IVS,keepusing(GDP) gen(_merge_gdp)
drop if _merge_gdp==2

replace Definition="Vietnam" if Definition=="Viet Nam"
merge m:m Definition Year using GGGI_IVS, keepusing(gggi) gen(_merge_gggi)
drop if _merge_gggi==2
order Country Year question qt_label Content mean_men mean_women ///
 N_men N_women min max share_min share_max sd_c sd_y GDP gggi meaning*
sort question Country Year
save Indicator_IVS, replace
erase GDP_IVS.dta
erase GGGI_IVS.dta
**************look up missing value
egen temp=tag(Definition)

* Did not fine matched GDP data for these following countries
list Country Definition if  temp==1 & _merge_gdp==1

* Did not fine matched GGGI data for these following countries
list Country Definition gggi if  temp==1 & _merge_gggi==1
drop temp


