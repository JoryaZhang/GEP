*This file calculates the weighted mean and weighted standard deviation for
*male and female in IVS
*Due to the excessive size of the document, I separates the dataset into different sub dataset
*******************************************

cd ~/Desktop/Thesis/Stata/IVS
use Integrated_values_surveys_1981-2022.dta, clear
*****************************************************
* X001 - Sex indicator
* S003 - Country
* S020 - Year survey
* S017 - Weight
*****************************************************

rename X001 Sex
rename S003 S003
rename S020 Year
rename S017 Weight


local vars `r(varlist)'
local vars_exclude "S002EVS S002 S003 Weight Year COW_ALPHA"
local vars : list vars - vars_exclude
drop `vars' mm*
save IVS_1981-2022.dta, replace

*This part divides the dataset to small dataset
*****************************************************
foreach x in A B C D E F G H I V{
use IVS_1981-2022.dta, clear
keep  `x'* Sex S002EVS S002 S003 Weight Year
save IVS_`x', replace
}

use IVS_A, clear
keep Sex S002EVS S002 S003 Weight Year A001-A100 
save "IVS_A_part1.dta", replace

use IVS_A, clear
keep Sex S002EVS S002 S003 Weight Year A101-A198
save "IVS_A_part2.dta", replace

use IVS_E, clear
keep Sex S002EVS S002 S003 Weight Year E001-E110
save "IVS_E_part1.dta", replace

use IVS_E, clear
keep Sex S002EVS S002 S003 Weight Year E111-E290
save "IVS_E_part2.dta", replace
*****************************************************

use IVS_A_part1.dta, clear
foreach i of varlist A*{
qui replace `i'=. if `i'<0
}


gen women=(Sex==2) if Sex !=.
gen men=(Sex==1) if Sex !=.
label var women "Sex"
label var men "Sex"

foreach i of varlist A* {
qui{
bysort S003 Sex Year: egen num = total(`i' *  Weight )
bysort S003 Sex Year: egen sumwt = total(Weight )
gen mean`i' = num/sumwt
drop num sumwt

*sd per year per S003 (standardize to mean=0)
bysort S003 Year: egen num = total(`i' *  Weight )
bysort S003 Year: egen sumwt = total(Weight )
gen wtmean = num/sumwt
bysort S003 Year: egen double CSS=total(Weight*(`i'-wtmean)^2)
gen double variance=CSS/sumwt
gen double sd_c`i'=sqrt(variance)
label var sd_c`i' "SD per Country per year"
drop sumwt wtmean num
drop variance CSS

*sd per year all counrty (standardize to mean=0)
bysort Year: egen num = total(`i' *  Weight )
bysort Year: egen sumwt = total(Weight)
gen wtmean = num/sumwt
bysort Year: egen double CSS=total(Weight*(`i'-mean`i')^2)
gen double variance=CSS/sumwt
gen double sd_y`i'=sqrt(variance)
label var sd_y`i' "SD per year all Country"
drop sumwt wtmean num
drop variance CSS

*count number of observation
bysort S003 Sex Year : egen N_sex = count(`i')
bysort S003 Year: egen min`i'=min(`i')
bysort S003 Year: egen max`i'=max(`i')

*share of min/max
bysort S003 Year : egen N = count(`i')
bysort S003 Year: egen N_min=total(`i'==min`i')
bysort S003 Year: egen N_max=total(`i'==max`i')
gen share_min`i'=(N_min/N)
gen share_max`i'=(N_max/N)
drop N_min N_max N

*separate variables for women
gen temp=mean`i' if women==1
gen N_temp = N_sex if women==1
bysort S003 Year:  egen mean_women`i' = max(temp)
bysort S003 Year:  egen N_women`i' = max(N_temp)
drop temp N_temp

*separate variable for men
gen temp=mean`i' if men==1
gen N_temp = N_sex if men==1
bysort S003 Year:  egen mean_men`i' = max(temp)
bysort S003 Year:  egen N_men`i' = max(N_temp)
drop temp N_temp
}
drop N_sex `i' mean`i' 
display "`i' finished at $S_TIME"
}


egen tag_S003_year=tag(S003 Year)
keep if tag_S003_year==1
reshape long mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y, i(S003 Year) j(question) string
order S003 Year question mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y

sort question S003

save IVS_A_1, replace
*****************************************************

use IVS_A_part2.dta, clear
foreach i of varlist A*{
qui replace `i'=. if `i'<0
}


gen women=(Sex==2) if Sex !=.
gen men=(Sex==1) if Sex !=.
label var women "Sex"
label var men "Sex"

foreach i of varlist A* {
qui{
bysort S003 Sex Year: egen num = total(`i' *  Weight )
bysort S003 Sex Year: egen sumwt = total(Weight )
gen mean`i' = num/sumwt
drop num sumwt

*sd per year per S003 (standardize to mean=0)
bysort S003 Year: egen num = total(`i' *  Weight )
bysort S003 Year: egen sumwt = total(Weight )
gen wtmean = num/sumwt
bysort S003 Year: egen double CSS=total(Weight*(`i'-wtmean)^2)
gen double variance=CSS/sumwt
gen double sd_c`i'=sqrt(variance)
label var sd_c`i' "SD per Country per year"
drop sumwt wtmean num
drop variance CSS

*sd per year all counrty (standardize to mean=0)
bysort Year: egen num = total(`i' *  Weight )
bysort Year: egen sumwt = total(Weight)
gen wtmean = num/sumwt
bysort Year: egen double CSS=total(Weight*(`i'-mean`i')^2)
gen double variance=CSS/sumwt
gen double sd_y`i'=sqrt(variance)
label var sd_y`i' "SD per Country all S003"
drop sumwt wtmean num
drop variance CSS

*count number of observation
bysort S003 Sex Year : egen N_sex = count(`i')
bysort S003 Year: egen min`i'=min(`i')
bysort S003 Year: egen max`i'=max(`i')

*share of min/max
bysort S003 Year : egen N = count(`i')
bysort S003 Year: egen N_min=total(`i'==min`i')
bysort S003 Year: egen N_max=total(`i'==max`i')
gen share_min`i'=(N_min/N)
gen share_max`i'=(N_max/N)
drop N_min N_max N

*separate variables for women
gen temp=mean`i' if women==1
gen N_temp = N_sex if women==1
bysort S003 Year:  egen mean_women`i' = max(temp)
bysort S003 Year:  egen N_women`i' = max(N_temp)
drop temp N_temp

*separate variable for men
gen temp=mean`i' if men==1
gen N_temp = N_sex if men==1
bysort S003 Year:  egen mean_men`i' = max(temp)
bysort S003 Year:  egen N_men`i' = max(N_temp)
drop temp N_temp
}
drop N_sex `i' mean`i' 
display "`i' finished at $S_TIME"
}


egen tag_S003_year=tag(S003 Year)
keep if tag_S003_year==1
reshape long mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y, i(S003 Year) j(question) string
order S003 Year question mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y

sort question S003

save IVS_A_2, replace
*****************************************************

append using IVS_A_1 IVS_A_2
erase IVS_A_1.dta 
erase IVS_A_2.dta
save IVS_A_final.dta, replace



*************************************************************

foreach x in B D F G H I{
use IVS_`x'.dta, clear

gen women=(Sex==2) if Sex !=.
gen men=(Sex==1) if Sex !=.
label var women "Sex"
label var men "Sex"

foreach i of varlist `x'* {
qui{
bysort S003 Sex Year: egen num = total(`i' *  Weight )
bysort S003 Sex Year: egen sumwt = total(Weight )
gen mean`i' = num/sumwt
drop num sumwt

*sd per year per S003 (standardize to mean=0)
bysort S003 Year: egen num = total(`i' *  Weight )
bysort S003 Year: egen sumwt = total(Weight )
gen wtmean = num/sumwt
bysort S003 Year: egen double CSS=total(Weight*(`i'-wtmean)^2)
gen double variance=CSS/sumwt
gen double sd_c`i'=sqrt(variance)
label var sd_c`i' "SD per Country per year"
drop sumwt wtmean num
drop variance CSS

*sd per year all counrty (standardize to mean=0)
bysort Year: egen num = total(`i' *  Weight )
bysort Year: egen sumwt = total(Weight)
gen wtmean = num/sumwt
bysort Year: egen double CSS=total(Weight*(`i'-mean`i')^2)
gen double variance=CSS/sumwt
gen double sd_y`i'=sqrt(variance)
label var sd_y`i' "SD per year all Country"
drop sumwt wtmean num
drop variance CSS

*count number of observation
bysort S003 Sex Year : egen N_sex = count(`i')
bysort S003 Year: egen min`i'=min(`i')
bysort S003 Year: egen max`i'=max(`i')

*share of min/max
bysort S003 Year : egen N = count(`i')
bysort S003 Year: egen N_min=total(`i'==min`i')
bysort S003 Year: egen N_max=total(`i'==max`i')
gen share_min`i'=(N_min/N)
gen share_max`i'=(N_max/N)
drop N_min N_max N

*separate variables for women
gen temp=mean`i' if women==1
gen N_temp = N_sex if women==1
bysort S003 Year:  egen mean_women`i' = max(temp)
bysort S003 Year:  egen N_women`i' = max(N_temp)
drop temp N_temp

*separate variable for men
gen temp=mean`i' if men==1
gen N_temp = N_sex if men==1
bysort S003 Year:  egen mean_men`i' = max(temp)
bysort S003 Year:  egen N_men`i' = max(N_temp)
drop temp N_temp
}
drop N_sex `i' mean`i' 
display "`i' finished at $S_TIME"
}


egen tag_S003_year=tag(S003 Year)
keep if tag_S003_year==1
reshape long mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y, i(S003 Year) j(question) string
order S003 Year question mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y

sort question S003

save IVS_`x'_final, replace
}
******************************************************
use IVS_C.dta, clear

gen women=(Sex==2) if Sex !=.
gen men=(Sex==1) if Sex !=.
label var women "Sex"
label var men "Sex"

foreach i of varlist C001-C061 {
qui{
bysort S003 Sex Year: egen num = total(`i' *  Weight )
bysort S003 Sex Year: egen sumwt = total(Weight )
gen mean`i' = num/sumwt
drop num sumwt

*sd per year per S003 (standardize to mean=0)
bysort S003 Year: egen num = total(`i' *  Weight )
bysort S003 Year: egen sumwt = total(Weight )
gen wtmean = num/sumwt
bysort S003 Year: egen double CSS=total(Weight*(`i'-wtmean)^2)
gen double variance=CSS/sumwt
gen double sd_c`i'=sqrt(variance)
label var sd_c`i' "SD per Country per year"
drop sumwt wtmean num
drop variance CSS

*sd per year all counrty (standardize to mean=0)
bysort Year: egen num = total(`i' *  Weight )
bysort Year: egen sumwt = total(Weight)
gen wtmean = num/sumwt
bysort Year: egen double CSS=total(Weight*(`i'-mean`i')^2)
gen double variance=CSS/sumwt
gen double sd_y`i'=sqrt(variance)
label var sd_y`i' "SD per year all Country"
drop sumwt wtmean num
drop variance CSS

*count number of observation
bysort S003 Sex Year : egen N_sex = count(`i')
bysort S003 Year: egen min`i'=min(`i')
bysort S003 Year: egen max`i'=max(`i')

*share of min/max
bysort S003 Year : egen N = count(`i')
bysort S003 Year: egen N_min=total(`i'==min`i')
bysort S003 Year: egen N_max=total(`i'==max`i')
gen share_min`i'=(N_min/N)
gen share_max`i'=(N_max/N)
drop N_min N_max N

*separate variables for women
gen temp=mean`i' if women==1
gen N_temp = N_sex if women==1
bysort S003 Year:  egen mean_women`i' = max(temp)
bysort S003 Year:  egen N_women`i' = max(N_temp)
drop temp N_temp

*separate variable for men
gen temp=mean`i' if men==1
gen N_temp = N_sex if men==1
bysort S003 Year:  egen mean_men`i' = max(temp)
bysort S003 Year:  egen N_men`i' = max(N_temp)
drop temp N_temp
}
drop N_sex `i' mean`i' 
display "`i' finished at $S_TIME"
}


egen tag_S003_year=tag(S003 Year)
keep if tag_S003_year==1
reshape long mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y, i(S003 Year) j(question) string
order S003 Year question mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y

sort question S003

save IVS_C_final, replace
*******************************************************
use IVS_E_part1.dta, clear
foreach i of varlist E*{
qui replace `i'=. if `i'<0
}

gen women=(Sex==2) if Sex !=.
gen men=(Sex==1) if Sex !=.
label var women "Sex"
label var men "Sex"

foreach i of varlist E* {
qui{
bysort S003 Sex Year: egen num = total(`i' *  Weight )
bysort S003 Sex Year: egen sumwt = total(Weight )
gen mean`i' = num/sumwt
drop num sumwt

*sd per year per S003 (standardize to mean=0)
bysort S003 Year: egen num = total(`i' *  Weight )
bysort S003 Year: egen sumwt = total(Weight )
gen wtmean = num/sumwt
bysort S003 Year: egen double CSS=total(Weight*(`i'-wtmean)^2)
gen double variance=CSS/sumwt
gen double sd_c`i'=sqrt(variance)
label var sd_c`i' "SD per S003 per year"
drop sumwt wtmean num
drop variance CSS

*sd per year all counrty (standardize to mean=0)
bysort Year: egen num = total(`i' *  Weight )
bysort Year: egen sumwt = total(Weight)
gen wtmean = num/sumwt
bysort Year: egen double CSS=total(Weight*(`i'-mean`i')^2)
gen double variance=CSS/sumwt
gen double sd_y`i'=sqrt(variance)
label var sd_y`i' "SD per year all S003"
drop sumwt wtmean num
drop variance CSS

*count number of observation
bysort S003 Sex Year : egen N_sex = count(`i')
bysort S003 Year: egen min`i'=min(`i')
bysort S003 Year: egen max`i'=max(`i')

*share of min/max
bysort S003 Year : egen N = count(`i')
bysort S003 Year: egen N_min=total(`i'==min`i')
bysort S003 Year: egen N_max=total(`i'==max`i')
gen share_min`i'=(N_min/N)
gen share_max`i'=(N_max/N)
drop N_min N_max N

*separate variables for women
gen temp=mean`i' if women==1
gen N_temp = N_sex if women==1
bysort S003 Year:  egen mean_women`i' = max(temp)
bysort S003 Year:  egen N_women`i' = max(N_temp)
drop temp N_temp

*separate variable for men
gen temp=mean`i' if men==1
gen N_temp = N_sex if men==1
bysort S003 Year:  egen mean_men`i' = max(temp)
bysort S003 Year:  egen N_men`i' = max(N_temp)
drop temp N_temp
}
drop N_sex `i' mean`i' 
display "`i' finished at $S_TIME"
}


egen tag_S003_year=tag(S003 Year)
keep if tag_S003_year==1
reshape long mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y, i(S003 Year) j(question) string
order S003 Year question mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y

sort question S003

save IVS_E_1, replace
*****************************************************

use IVS_E_part2.dta, clear
foreach i of varlist E*{
qui replace `i'=. if `i'<0
}


gen women=(Sex==2) if Sex !=.
gen men=(Sex==1) if Sex !=.
label var women "Sex"
label var men "Sex"

foreach i of varlist E* {
qui{
bysort S003 Sex Year: egen num = total(`i' *  Weight )
bysort S003 Sex Year: egen sumwt = total(Weight )
gen mean`i' = num/sumwt
drop num sumwt

*sd per year per S003 (standardize to mean=0)
bysort S003 Year: egen num = total(`i' *  Weight )
bysort S003 Year: egen sumwt = total(Weight )
gen wtmean = num/sumwt
bysort S003 Year: egen double CSS=total(Weight*(`i'-wtmean)^2)
gen double variance=CSS/sumwt
gen double sd_c`i'=sqrt(variance)
label var sd_c`i' "SD per Country per year"
drop sumwt wtmean num
drop variance CSS

*sd per year all counrty (standardize to mean=0)
bysort Year: egen num = total(`i' *  Weight )
bysort Year: egen sumwt = total(Weight)
gen wtmean = num/sumwt
bysort Year: egen double CSS=total(Weight*(`i'-mean`i')^2)
gen double variance=CSS/sumwt
gen double sd_y`i'=sqrt(variance)
label var sd_y`i' "SD per year all Country"
drop sumwt wtmean num
drop variance CSS

*count number of observation
bysort S003 Sex Year : egen N_sex = count(`i')
bysort S003 Year: egen min`i'=min(`i')
bysort S003 Year: egen max`i'=max(`i')

*share of min/max
bysort S003 Year : egen N = count(`i')
bysort S003 Year: egen N_min=total(`i'==min`i')
bysort S003 Year: egen N_max=total(`i'==max`i')
gen share_min`i'=(N_min/N)
gen share_max`i'=(N_max/N)
drop N_min N_max N

*separate variables for women
gen temp=mean`i' if women==1
gen N_temp = N_sex if women==1
bysort S003 Year:  egen mean_women`i' = max(temp)
bysort S003 Year:  egen N_women`i' = max(N_temp)
drop temp N_temp

*separate variable for men
gen temp=mean`i' if men==1
gen N_temp = N_sex if men==1
bysort S003 Year:  egen mean_men`i' = max(temp)
bysort S003 Year:  egen N_men`i' = max(N_temp)
drop temp N_temp
}
drop N_sex `i' mean`i' 
display "`i' finished at $S_TIME"
}


egen tag_S003_year=tag(S003 Year)
keep if tag_S003_year==1
reshape long mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y, i(S003 Year) j(question) string
order S003 Year question mean_men mean_women N_men N_women min max share_min share_max sd_c sd_y

sort question S003

save IVS_E_2, replace
*****************************************************

append using IVS_E_1 IVS_E_2
erase IVS_E_1.dta 
erase IVS_E_2.dta
save IVS_E_final.dta, replace

*****************************************************
append using IVS_A_final IVS_B_final IVS_C_final IVS_D_final IVS_E_final IVS_F_final IVS_G_final IVS_H_final IVS_I_final
save IVS_final, replace

*ssc install codebookout

*IVS codebook >>
*****************************************
cd ~/Desktop/Thesis/Stata/IVS
use IVS_1981-2022.dta, clear
drop  V* W* X* Y*
codebookout IVS_label.xls, replace
*i.e. Country Code, Admin/protocal variables
import excel IVS_label.xls,firstrow clear

replace VariableName = VariableName[_n-1] if missing(VariableName)
replace VariableLabel = VariableLabel[_n-1] if missing(VariableLabel)

rename VariableName question
rename VariableLabel qt_label
rename AnswerLabel meaning
rename AnswerCode value

keep question qt_label meaning value
destring value, replace
drop if value > 10
drop if value==.
drop if value<0

reshape wide meaning, i(question qt_label) j(value)
format meaning*  %20s

save IVS_label, replace

*merge label
*****************************************************
use IVS_final, clear
merge m:1 question using IVS_label
drop if _merge==2
egen temp=tag(question)
list question if  _merge==1 & temp==1
drop if _merge==1
drop temp _merge
rename S003 Country
drop if Country==.
gen Content=""
replace Content = "Perceptions of life" if substr(question, 1, 1) =="A"
replace Content = "Environment" if substr(question, 1, 1) =="B"
replace Content = "Work" if substr(question, 1, 1) =="C"
replace Content = "Family" if substr(question, 1, 1) =="D"
replace Content = "Politics and Society" if substr(question, 1, 1) =="E"
replace Content = "Religion and Morale" if substr(question, 1, 1) =="F"
replace Content = "National Identity" if substr(question, 1, 1) =="G"
replace Content = "Security" if substr(question, 1, 1) =="H"
replace Content = "Science" if substr(question, 1, 1) =="I"

save IVS_final_labelled, replace

****

foreach x in A B C D E F G H I V{
erase IVS_`x'.dta
}

foreach x in A B C D E F G H I{
erase IVS_`x'_final.dta
}

erase IVS_A_part1.dta
erase IVS_A_part2.dta
erase IVS_E_part1.dta
erase IVS_E_part2.dta

