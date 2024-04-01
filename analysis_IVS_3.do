
clear
*cd "F:\Users\thomas\Dropbox\Breda_Cimpian_Napp\Build_large_dataset"
cd ~/Desktop/Thesis/Stata/IVS

cap log c
log using first_analysis.log, replace


*****************************
*** create mean and number of observations of each var
clear
set obs 0 // Set the number of observations to zero
generate question =""
save IVS_corr, replace

use Indicator_IVS_2, clear
duplicates report Country question
levelsof question, local(all_values)
 
foreach i of local all_values {
use Indicator_IVS_2, clear
keep if question=="`i'"

egen min_min=min(min)
egen max_max=min(max)

qui: sum std_gg 
gen nb_obs=r(N)
gen mean=r(mean)

qui: sum std_gg if GDP!=.
gen nb_obs_GDP=r(N)
gen mean_GDP=r(mean)

qui: sum std_gg if gggi!=.
gen nb_obs_gggi=r(N)
gen mean_gggi=r(mean)

gen pos_std_gg=(std_gg>=0) if std_gg!=.
qui: sum pos_std_gg 
gen share_pos=r(mean)

qui: sum pos_std_gg if GDP!=. 
gen share_pos_GDP=r(mean)

qui: sum pos_std_gg if gggi!=. 
gen share_pos_gggi=r(mean)

pwcorr std_gg GDP
gen cor_GDP=`r(rho)'

pwcorr std_gg gggi
gen cor_gggi=`r(rho)'

keep question mean nb_obs share_pos mean_GDP nb_obs_GDP share_pos_GDP   mean_gggi nb_obs_gggi share_pos_gggi cor_GDP  cor_gggi min_min max_max qt_label Content meaning0 meaning1 meaning2 meaning3 meaning4 meaning5 meaning6 meaning7 meaning8 meaning9 meaning10 

keep in 1
append using IVS_corr
save IVS_corr, replace
sleep 800
}

use IVS_corr, clear

gen GEP_GDP= cor_GDP* sign(mean_GDP)
gen GEP_gggi= cor_gggi* sign(mean_gggi)
order Content question qt_label GEP_GDP  cor_GDP  mean_GDP nb_obs_GDP share_pos_GDP  GEP_gggi cor_gggi  mean_gggi nb_obs_gggi share_pos_gggi mean nb_obs share_pos min_min max_max meaning0 meaning1 meaning2 meaning3 meaning4 meaning5 meaning6 meaning7 meaning8 meaning9 meaning10 

duplicates report question
sort GEP_GDP
save correlations, replace


*****************************
use correlations, clear






*** Here we code by hand if it needs to be inverted

*** resulting file is correlation_01_completed
* it contains a new variable "invert" that takes value 1 if a positive correlation with GDP or other macro variable indicates an anti-GEP rather than a GEP

*save correlations_completed, replace


**** identify GEP and noGEP
// replace invert=-1 if invert==1
// replace invert=1 if invert==0
// replace invert=. if macro==1

// gen GGI2=GGI*invert
// gen lGDP2=lGDP2012*invert
// gen indiv2=indiv*invert

// gsort GGI2

// drop if macro==1
// drop if inlist(_varname,"GGI","lGDP2012","indiv")
// sort GGI2


// foreach var in GGI lGDP indiv {
// gen GEP_`var'= (`var'2>0)
// gen NOGEP_`var'= (`var'2<0)
// gen bigGEP_`var'= (`var'2>0.5)
// gen bigNOGEP_`var'= (`var'2<-0.5)
// }

// foreach var in GGI lGDP indiv {
// tab GEP_`var' 
// tab NOGEP_`var' 
// tab bigGEP_`var' 
// tab bigNOGEP_`var' 
// }

// sort _varname
// save correlations_GEP, replace
// erase temp.dta

/*** Full data for PCA (includes transpose of initial data matched with information on GEP, correlations, nb obs, mean of each variable)  ***/
*keep if bigGEP_GGI==1
// keep if macro==0
// save Data_for_pca, replace


/**** PCAs from here */

cap log using pca_file.log, replace

***** 1) PCA for 15 largest GEP for GDP (with at least 40 country obs)
clear
cd ~/Desktop/Thesis/Stata/IVS


************some rough analysis of gender gap
use correlations, clear
*only keep the questions with at least 40 country obs
keep if nb_obs>=40
*show GEP distribution
sum GEP_GDP, d
sum GEP_gggi, d


gsort GEP_GDP

*show number of questions in each Content
tab Content



************pca
use Indicator_IVS_2, clear
keep Country question std_gg
reshape wide std_gg, i(question) j(Country)

merge 1:1 question using correlations
drop if _merge==2
gsort -GEP_GDP

keep if nb_obs>=40
keep if _n<=10
keep question std_gg*
reshape long std_gg, i(question) j(Country)
reshape wide std_gg, i(Country) j(question) string
save data_pca, replace

** This is the pca for top 10 questions with largest GEP for GDP

use data_pca, clear
pca std_gg*
*estat kmo
pca std_gg*, components(3)
*pca, leave blank if loading<0.3
pca std_gg*, components(3) blanks(.3)
rotate

predict f1-f7

*rename *std_gg* **
loadingplot
scoreplot, msize(small) mlabel(Country) mlabsize(tiny) ///
			xline(0,lp(dash)) yline(0,lp(dash))

/***** 2) PCA for 15 largest anti-GEP for GGI (with at least 40 country obs)
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
Do EFA instead of PCA and apply oblique rotation*/









