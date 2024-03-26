clear
cd ~/Desktop/Thesis/Stata/DataIVS
use Indicator_IVS, clear

drop if Year<2010
drop if mean_men==0 & mean_women==0


bysort Country question: egen GDP1=mean(GDP)
bysort Country question: egen gggi1=mean(gggi)
bysort Country question: egen total_men=total(N_men)
bysort Country question: egen num=total(mean_men*N_men)
gen wtmean_men=num/total_men
drop num

bysort Country question: egen total_women=total(N_women)
bysort Country question: egen num=total(mean_women*N_women)
gen wtmean_women=num/total_women
drop num 

gen gender_gap=wtmean_women-wtmean_men
bysort Country question: egen sd_mean=mean(sd_c)
gen std_gg=gender_gap/sd_mean

drop GDP gggi
rename GDP1 GDP
rename gggi1 gggi


egen temp=tag(Country question)
keep if temp==1
drop temp mean_* Year sd_c sd_y
order Country question std_gg gender_gap GDP gggi wtmean* total* min max share_min share_max sd_mean
sort question Country
save Indicator_IVS_2, replace
