*This do file generates the value label for WVS and IVS
*ssc install codebookout

*IVS codebook >>
*****************************************
cd ~/Desktop/Thesis/Stata/DataIVS
use IVS_1981-2022.dta, clear
drop  V* W* X* Y*
codebookout IVS_label.xls, replace
*maybe manually delete some variables in excel
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
