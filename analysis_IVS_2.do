
clear
*cd "F:\Users\thomas\Dropbox\Breda_Cimpian_Napp\data"
cd ~/Desktop/Thesis/Stata/DataIVS

cap log c
log using first_analysis.log, replace


*****************************
*** create mean and number of observations of each var
clear
set obs 0 // Set the number of observations to zero
generate question =""
save IVS_obs, replace

use Indicator_IVS_2, clear
duplicates report Country question
levelsof question, local(all_values)
 
foreach i of local all_values {
use Indicator_IVS_2, clear
keep if question=="`i'"
qui: sum std_gg
gen nb_obs=r(N)
gen mean=r(mean)
gen pos_std_gg=(std_gg>=0) if std_gg!=.
qui: sum pos_std_gg if GDP!=.
gen nb_pos=r(N)
keep question mean nb_obs nb_pos
keep in 1
append using IVS_obs
save IVS_obs, replace
}

*** generate a new dataset
clear
set obs 0 // Set the number of observations to zero
generate question =""
save IVS_corr, replace

use Indicator_IVS_2, clear
levelsof question, local(all_values)
foreach i of local all_values {
use Indicator_IVS_2, clear
pwcorr std_gg GDP gggi if question=="`i'"
matrix result= r(C) 
matrix list result
matrix result = result[1,1... ]
matrix list result
matrix colnames result =  std_gg cor_GDP cor_GGGI
clear
svmat2 result, names(col) rnames(question)
replace question="`i'"
append using IVS_corr
save IVS_corr, replace
}


*****************************
*** merge the two file
clear
use IVS_corr, clear
merge 1:1 question using IVS_obs
gen GEP_GDP=mean*cor_GDP
gen GEP_GGGI=mean*cor_GGGI
drop std_gg _merge
order question cor* mean nb* GEP*
sort question
save Correlation_IVS, replace





*****************************

*** recover labels
use Data_01, clear
gen to_drop=1
append using temp
drop if to_drop==1
drop to_drop
order GGI lGDP2012 indiv
xpose, clear varname
rename v1 GGI
rename v2 lGDP2012
rename v3 indiv
order _varname
sort _varname
merge _varname using mean_vars
drop _merge
sort _varname
merge _varname using nb_obs
drop if _varname=="var"
drop _merge

save correlations, replace












gen mean=1
collapse (mean)  GGI-CHESS , by(mean)
xpose, clear varname
rename v1 mean_var
drop if _n==1
order _varname
sort _varname
save mean_vars, replace
******************************

*****************************
*** create number of non-missing obs of each var
use Data_01, clear
summarize
order GGI lGDP2012 indiv 
gen mean=1
collapse (count) GGI-CHESS , by(mean)
xpose, clear varname
rename v1 nb_obs
drop if _n==1
order _varname
sort _varname
save nb_obs, replace
*********************************

*********************************
***** main data creation
use Data_01, clear

order GGI lGDP2012 indiv
qui:pwcorr
display r(N)
matrix result= r(C) 
matrix list result
matrix result=result[1..3,1...]
matrix list result
matrix rownames result =  GGI lGDP2012 indiv

clear
svmat2 result, names(col) rnames(var)
save temp, replace

*** recover labels
use Data_01, clear
gen to_drop=1
append using temp
drop if to_drop==1
drop to_drop
order GGI lGDP2012 indiv
xpose, clear varname
rename v1 GGI
rename v2 lGDP2012
rename v3 indiv
order _varname
sort _varname
merge _varname using mean_vars
drop _merge
sort _varname
merge _varname using nb_obs
drop if _varname=="var"
drop _merge

save correlations, replace
*** Here we code by hand if it needs to be inverted

*** resulting file is correlation_01_completed
* it contains a new variable "invert" that takes value 1 if a positive correlation with GDP or other macro variable indicates an anti-GEP rather than a GEP

*save correlations_completed, replace
use correlations_completed, clear

**** identify GEP and noGEP
replace invert=-1 if invert==1
replace invert=1 if invert==0
replace invert=. if macro==1

gen GGI2=GGI*invert
gen lGDP2=lGDP2012*invert
gen indiv2=indiv*invert

gsort GGI2

drop if macro==1
drop if inlist(_varname,"GGI","lGDP2012","indiv")
sort GGI2


foreach var in GGI lGDP indiv {
gen GEP_`var'= (`var'2>0)
gen NOGEP_`var'= (`var'2<0)
gen bigGEP_`var'= (`var'2>0.5)
gen bigNOGEP_`var'= (`var'2<-0.5)
}

foreach var in GGI lGDP indiv {
tab GEP_`var' 
tab NOGEP_`var' 
tab bigGEP_`var' 
tab bigNOGEP_`var' 
}

sort _varname
save correlations_GEP, replace
erase temp.dta

/*** Full data for PCA (includes transpose of initial data matched with information on GEP, correlations, nb obs, mean of each variable)  ***/
use Data_01, clear
xpose, clear varname
sort _varname
merge _varname using correlations_GEP
*keep if bigGEP_GGI==1
keep if macro==0
save Data_for_pca, replace


/**** PCAs from here */

cap log using pca_only.log, replace

***** 1) PCA for 15 largest GEP for GGI (with at least 40 country obs)
use Data_for_pca, clear
gsort -lGDP2
keep if nb_obs>=40
keep if _n<=15
keep v1-v67 _varname
xpose, clear varname
drop _varname

*** Full variable list top 15 GEP with t least 40 obs:
* AC_ATT_science_SE_adjusted PREF_FH_patience WELL_BEING_eating_disorder AC_ATT_math_SE_adjusted AC_ATT_M_math_anx_adjusted_perf ATT_fear_failure AC_ATT_math_SC_adjusted AC_ATT_math_instru ATT_perseverance AC_ATT_Math_instru_adjusted AC_ATT_math_openness_problem ATT_M_confidence AC_ATT_math_important ATT_talent OCC_M_exp_engineering

** This is the pca for 15 largest GEP for GGI
pca _all, components(3)
rotate


***** 2) PCA for 15 largest anti-GEP for GGI (with at least 40 country obs)
use Data_for_pca, clear
gsort lGDP2
keep if nb_obs>=40
keep if _n<=15
keep v1-v67 _varname
xpose, clear varname
drop _varname

*** Full variable list for top 15 anti-GEP with t least 40 obs:
* SCH_ATT_M_truancy1 SCH_ATT_M_truancy2 IM WORK_unpaid_care AC_ATT_math_compet WORK_M_Labor_force2 LEVEL_STU_mean_years SCH_ATT_M_Repeat2 VAL_SR_M_achievement ACHIE_M_math_high ATT_master_task ACHIE_M_Math_high2 SCH_ATT_Repeat PERSO_M_Lee_Ashton_Agreeableness AC_ATT_read_SC_adjusted

** This is the pca for 15 largest noGEP for GGI
pca _all, components(3)
rotate


***** 3) PCA for Top 10 GEP and top 10 anti-GEP variables with at least 40 countries
use Data_for_pca, clear
gsort lGDP2
keep if nb_obs>=40
 keep if _n<=10 | ( (_N- _n) >=1 & (_N- _n) <=10) 
* keep if _n<=20 | (_n >=160 & _n<=180) 
keep v1-v67 _varname
xpose, clear varname
drop _varname

** For variable list, see two first PCAs

** This is the pca  for top 10 GEP and top 10 anti-GEP variables with at least 40 countries
pca _all, components(3)
rotate


***** 4) PCA for all variables with at least 60 countries
use Data_for_pca, clear
keep if nb_obs>=60
keep v1-v67 _varname
xpose, clear varname
drop _varname

** Full variable list for variables with at least 60 country obs.
* ACHIE_M_Math_high2 ACHIE_M_math_high ACHIE_M_reading ACHIE_M_science_high ACHIE_math1 ACHIE_math2 ACHIE_reading_high AC_ATT_M_math_anx_adjusted_perf AC_ATT_M_math_resp_failure AC_ATT_Math_instru_adjusted AC_ATT_Math_intrinsic_adjusted AC_ATT_Math_perceived_control2 AC_ATT_math_SC AC_ATT_math_SC_adjusted AC_ATT_math_SE_adjusted AC_ATT_math_anx_adj_int AC_ATT_math_compet AC_ATT_math_enjoyment AC_ATT_math_failure2 AC_ATT_math_important AC_ATT_math_instru AC_ATT_math_intrinsic AC_ATT_math_openness_problem AC_ATT_math_parents_beliefs AC_ATT_math_perceived_control AC_ATT_math_quick AC_ATT_read_enjoyment1 ATT_M_compet1 ATT_M_self_efficacy ATT_Sustain_perf2 ATT_fear_failure ATT_growth_mindset ATT_master_task ATT_perseverance ATT_sustain_perf1 ATT_talent CHESS IM LEVEL_STU_mean_years PROFILE_M_MR SCH_ATT_M_Trying_hard2 SCH_ATT_M_school_helps_job SCH_ATT_M_trying_hard SCH_ATT_Repeat STU_math_intentions Seffectsize WELL_BEING_BMI WELL_BEING_eating_disorder WELL_BEING_rankBMI WELL_BEING_suicide2015 WELL_BEING_suicide2016 WORK_M_Labor_force2 gendergapingrowthmindsetG

** This is the pca  for all variables with at least 60 countries
pca _all, components(3)
rotate

cap log c



/**** January 2024: file exported for Clotilde to complete ***/
*use correlations_01, replace
*br
*drop GGI2 lGDP2 indiv2
*export excel using list_variables.xlsx, replace    firstrow(variables)    keepcellfmt



/** TO be done to improve 
* delete when loading below .3

parallel analysis: built in in recent stata
otherwise use "paran": how many components to retain
Do EFA instead of PCA and apply oblique rotation









