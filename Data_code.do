* Note:As some of our variables are being used in other research, we have anonymized the stock code (i.e., stkcd). However, this does not affect the reproducibility of the paper's results.

use data,clear


**# control variables

global cons  Leverage Tangibility ROA Size Age  IH IndRatio Income  CO2 ER GDP


**# Table2
eststo tabsum:estpost sum EP_HeXun EP_EIDQ    AIPatent AIInvention AIUtility LnAIPatent     Leverage  Tangibility ROA  Size  Age  IH  IndRatio  Income  CO2  ER  GDP, detail  
esttab tabsum using summary1.rtf, replace label /// 
       title(Descriptive statistics of main variables) /// 
       cells((sum_w( label(Obs.)) /// 
	           mean(fmt(3) label(Mean)) /// 
	             sd(fmt(3) label(Std.)) /// 
	            min(fmt(3 ) label(Min)) /// 
	            p50(fmt(3) label(Median)) ///  
	            max(fmt(3) label(Max)))) /// 
		nomtitle nonumber noobs compress nogap

  	 	
**# Table A7	
eststo tabsum:estpost sum LnAIInvention  LnAIUtility  LnAIPatent_granted IV_HeXun   IV_EIDQ    AIWord_tfidf  AIWord_frequence  OperationEfficiency  OperatingCost    EmployeeProductivity  Manufacturing  NonRoutine  Routine TobinQ  PositiveNews, detail  
esttab tabsum using summary2.rtf, replace label /// 
       title(Descriptive statistics of other variables) /// 
       cells((sum_w( label(Obs.)) /// 
	           mean(fmt(3) label(Mean)) /// 
	             sd(fmt(3) label(Std.)) /// 
	            min(fmt(3 ) label(Min)) /// 
	            p50(fmt(3) label(Median)) ///  
	            max(fmt(3) label(Max)))) /// 
		nomtitle nonumber noobs compress nogap

		


**# Table3
reghdfe EP_HeXun LnAIPatent  , absorb(year pro ind3 ) cluster(stkcd)

reghdfe EP_HeXun LnAIPatent   $cons , absorb(year pro ind3 ) cluster(stkcd)

reghdfe EP_EIDQ LnAIPatent  , absorb(year pro ind3 ) cluster(stkcd)

reghdfe EP_EIDQ LnAIPatent   $cons , absorb(year pro ind3 ) cluster(stkcd)

**# Table4
reghdfe EP_EIDQ LnAIInvention LnAIUtility   $cons, absorb(year pro ind3) cluster(stkcd) 

reghdfe EP_HeXun  LnAIInvention LnAIUtility  $cons, absorb(year  pro ind3) cluster(stkcd)

reghdfe EP_EIDQ LnAIPatent_granted  $cons, absorb(year pro ind3) cluster(stkcd) 

reghdfe EP_HeXun  LnAIPatent_granted $cons, absorb(year  pro ind3) cluster(stkcd)


**# Table5
reghdfe EP_HeXun  AIWord_frequence  $cons, absorb(year  pro ind3) cluster(stkcd) 

reghdfe EP_HeXun  AIWord_tfidf  $cons, absorb(year  pro ind3) cluster(stkcd) 

reghdfe EP_EIDQ  AIWord_frequence  $cons, absorb(year  pro ind3) cluster(stkcd) 

reghdfe EP_EIDQ  AIWord_tfidf  $cons, absorb(year  pro ind3) cluster(stkcd) 

**# Table6
ivreghdfe EP_HeXun (LnAIPatent = IV_HeXun)  $cons, absorb(year pro ind3 ) cluster(stkcd) first

ivreghdfe EP_EIDQ (LnAIPatent = IV_EIDQ)  $cons, absorb(year pro ind3 ) cluster(stkcd) first

preserve
qui reghdfe LnAIPatent  IV_HeXun  $cons , absorb(year pro ind3 ) cluster(stkcd) 
qui predict xhat,xb
qui reghdfe EP_HeXun  xhat  $cons, absorb(year pro ind3 ) cluster(stkcd) 
dis  "EP_HeXun:" e(r2)  

qui reghdfe LnAIPatent  IV_EIDQ  $cons , absorb(year pro ind3 ) cluster(stkcd) 
qui predict xhat1,xb
qui reghdfe EP_EIDQ  xhat1  $cons, absorb(year pro ind3 ) cluster(stkcd) 
dis  "EP_EIDQ:" e(r2)  
restore


/*
// data for DDL
keep EP_HeXun EP_EIDQ LnAIPatent   $cons year pro ind3 
tab year,gen(yr)
tab ind3,gen(indu)
tab pro,gen(prov)
drop year pro ind3 
order EP_HeXun EP_EIDQ LnAIPatent
save DataForDDL
*/

// TWFE_DID
reghdfe EP_EIDQ  IM $cons, a(stkcd year) vce(cluster stkcd) keepsingletons

// TWFE_Parallel trends
gen treat=did_firstyear!=.
gen pd=year-did_firstyear
sort stkcd year

forvalues i = 10(-1)1{
	gen pre`i'=(pd==-`i'& treat==1)
}
gen curr =(pd==0 & treat==1)
forvalues j = 1(1)5{
	gen aft`j'=(pd==`j'& treat==1)
}

reghdfe EP_EIDQ  pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2  curr aft1 aft2 aft3 aft4 aft5 pre1 $cons, a(stkcd year) vce(cluster stkcd) keepsingletons

coefplot,baselevels omitted keep(pre* curr aft*) order(pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 pre1 curr aft1 aft2 aft3 aft4 aft5 )  vertical recast(connect) color(black)  yline(0,lp(solid) lc(black)) xline(11,lp(dash) lc(black)) xtitle("Years Since Intelligence Manufacturing Pilot") ytitle("Average treatment effects (95% conf. interval)") title("Intelligence manufacturing pilot on EP_EIDQ")  ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0) xlabel(1 "-10" 2 "-9" 3 "-8" 4 "-7" 5 "-6" 6 "-5" 7 "-4" 8 "-3" 9 "-2" 10 "-1" 11 "0" 12 "1" 13 "2" 14 "3" 15 "4" 16 "5")



// Unreported: DID based on Sun & Abraham (2021)
// Figure R2 in Response to Reviewer
gen never=(treat==0)
eventstudyinteract EP_EIDQ  pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2  curr aft1 aft2 aft3 aft4 aft5 pre1,cohort(did_firstyear) control_cohort(never) covariates($cons) absorb(i.stkcd i.year) vce(cluster stkcd)
matrix b = e(b_iw)
matrix V = e(V_iw)
ereturn post b V

coefplot,baselevels omitted keep(pre* curr aft*) order(pre10 pre9 pre8 pre7 pre6 pre5 pre4 pre3 pre2 pre1 curr aft1 aft2 aft3 aft4 aft5 )  vertical recast(connect) color(black)  yline(0,lp(solid) lc(black)) xline(11,lp(dash) lc(black)) xtitle("Years Since Intelligence Manufacturing Pilot") ytitle("Average treatment effects (95% conf. interval)") title("Intelligence manufacturing pilot on EP_EIDQ")  ciopts(recast(rcap) lc(black) lp(dash) lw(thin)) scale(1.0) xlabel(1 "-10" 2 "-9" 3 "-8" 4 "-7" 5 "-6" 6 "-5" 7 "-4" 8 "-3" 9 "-2" 10 "-1" 11 "0" 12 "1" 13 "2" 14 "3" 15 "4" 16 "5")

// Table R8 in Response to Reviewer
lincom(curr +aft1+ aft2 +aft3+ aft4+ aft5)/6

**# Table7
// Panel A
reghdfe OperationEfficiency LnAIPatent  $cons , absorb(year pro ind3) cluster(stkcd)

reghdfe OperatingCost LnAIPatent  $cons , absorb(year pro ind3) cluster(stkcd)

reghdfe  EmployeeProductivity LnAIPatent  $cons , absorb(year  pro ind3) vce(cluster stkcd)

// Panel B
reghdfe EP_HeXun OperationEfficiency LnAIPatent  $cons, absorb(year pro ind3) cluster(stkcd)

reghdfe EP_HeXun OperatingCost LnAIPatent  $cons, absorb(year pro ind3) cluster(stkcd)

reghdfe EP_HeXun EmployeeProductivity LnAIPatent  $cons, absorb(year  pro ind3) vce(cluster stkcd)

reghdfe EP_EIDQ OperationEfficiency LnAIPatent  $cons, absorb(year pro ind3) cluster(stkcd)

reghdfe EP_EIDQ OperatingCost LnAIPatent  $cons, absorb(year pro ind3) cluster(stkcd)

reghdfe EP_EIDQ EmployeeProductivity LnAIPatent  $cons, absorb(year  pro ind3) vce(cluster stkcd)



**# Table8
reghdfe EP_HeXun  LnAIPatent   $cons if Manufacturing==0 , absorb(year  pro ind3) cluster(stkcd) keepsingletons
reghdfe EP_HeXun  LnAIPatent  $cons if Manufacturing==1, absorb(year  pro ind3) cluster(stkcd) keepsingletons

reghdfe EP_EIDQ  LnAIPatent   $cons if Manufacturing==0 , absorb(year  pro ind3) cluster(stkcd) keepsingletons
reghdfe EP_EIDQ  LnAIPatent  $cons if Manufacturing==1, absorb(year  pro ind3) cluster(stkcd) keepsingletons

 
sum Tangibility if EP_HeXun!=.,de
local d=r(p50)
reghdfe EP_HeXun  LnAIPatent   $cons if Tangibility<=`d' , absorb(year  pro ind3) cluster(stkcd) keepsingletons
reghdfe EP_HeXun  LnAIPatent  $cons if Tangibility>`d', absorb(year  pro ind3) cluster(stkcd) keepsingletons

sum Tangibility,de
local d=r(p50)
reghdfe EP_EIDQ  LnAIPatent   $cons if Tangibility<=`d' , absorb(year  pro ind3) cluster(stkcd) keepsingletons
reghdfe EP_EIDQ  LnAIPatent  $cons if Tangibility>`d', absorb(year  pro ind3) cluster(stkcd) keepsingletons


**# Table9
sum Routine if EP_HeXun!=.,de
local d=r(p50)
reghdfe EP_HeXun  LnAIPatent   $cons if Routine<=`d' , absorb(year  pro ind3) cluster(stkcd) keepsingletons
reghdfe EP_HeXun  LnAIPatent  $cons if Routine>`d', absorb(year  pro ind3) cluster(stkcd) keepsingletons

sum Routine,de
local d=r(p50)
reghdfe EP_EIDQ  LnAIPatent   $cons if Routine<=`d' , absorb(year  pro ind3) cluster(stkcd) keepsingletons
reghdfe EP_EIDQ  LnAIPatent  $cons if Routine>`d', absorb(year  pro ind3) cluster(stkcd) keepsingletons

sum NonRoutine if EP_HeXun!=.,de
local d=r(p50)
reghdfe EP_HeXun  LnAIPatent   $cons if NonRoutine<=`d' , absorb(year  pro ind3) cluster(stkcd) keepsingletons
reghdfe EP_HeXun  LnAIPatent  $cons if NonRoutine>`d', absorb(year  pro ind3) cluster(stkcd) keepsingletons

sum NonRoutine,de
local d=r(p50)
reghdfe EP_EIDQ  LnAIPatent   $cons if NonRoutine<=`d' , absorb(year  pro ind3) cluster(stkcd) keepsingletons
reghdfe EP_EIDQ  LnAIPatent  $cons if NonRoutine>`d', absorb(year  pro ind3) cluster(stkcd) keepsingletons

// Test difference of LnAIPatent coefﬁcients
preserve
qui tab year,gen(yr)
qui tab pro,gen(po)
qui tab ind3,gen(id)
foreach v in Tangibility Manufacturing NonRoutine Routine {
qui sum `v' if EP_HeXun!=.,de
local d=r(p50)
qui reg EP_HeXun  LnAIPatent   $cons yr* po* id* if `v'<`d'
estimates store A0
qui reg EP_HeXun  LnAIPatent   $cons yr* po* id* if `v'>=`d'
estimates store A1
qui suest A0 A1
qui test [A0_mean]LnAIPatent = [A1_mean]LnAIPatent

dis "`v': " r(p)
}

preserve
qui tab year,gen(yr)
qui tab pro,gen(po)
qui tab ind3,gen(id)
foreach v in Tangibility Manufacturing NonRoutine Routine {
qui sum `v',de
local d=r(p50)
qui reg EP_EIDQ  LnAIPatent   $cons yr* po* id* if `v'<`d'
estimates store A0
qui reg EP_EIDQ  LnAIPatent   $cons yr* po* id* if `v'>=`d'
estimates store A1
qui suest A0 A1
qui test [A0_mean]LnAIPatent = [A1_mean]LnAIPatent

dis "`v': " r(p)
}

**# Table10
// Panel A
reghdfe PositiveNews c.EP_HeXun c.LnAIPatent   $cons , absorb(year  pro ind3) cluster(stkcd) 

reghdfe PositiveNews c.EP_EIDQ c.LnAIPatent   $cons , absorb(year  pro ind3) cluster(stkcd) 

reghdfe PositiveNews c.EP_HeXun##c.LnAIPatent   $cons , absorb(year  pro ind3) cluster(stkcd) 

reghdfe PositiveNews c.EP_EIDQ##c.LnAIPatent   $cons , absorb(year  pro ind3) cluster(stkcd) 

// Panel B
reghdfe TobinQ c.EP_HeXun c.LnAIPatent   $cons , absorb(year  pro ind3) cluster(stkcd) 

reghdfe TobinQ c.EP_HeXun##c.LnAIPatent   $cons , absorb(year  pro ind3) cluster(stkcd) 

reghdfe TobinQ c.EP_EIDQ c.LnAIPatent   $cons , absorb(year  pro ind3) cluster(stkcd) 

reghdfe TobinQ c.EP_EIDQ##c.LnAIPatent   $cons , absorb(year  pro ind3) cluster(stkcd) 


**# Unreported: Multicollinearity analysis
regress EP_HeXun LnAIPatent  i.year i.pro i.ind3,cluster(stkcd)
estat vif

regress EP_EIDQ LnAIPatent  i.year i.pro i.ind3,cluster(stkcd)
estat vif

regress EP_HeXun LnAIPatent   $cons i.year i.pro i.ind3,cluster(stkcd)
estat vif

regress EP_EIDQ LnAIPatent   $cons i.year i.pro i.ind3,cluster(stkcd)
estat vif

// Table R10 in Response to Reviewer
ridgeregress EP_HeXun LnAIPatent   $cons i.year i.pro i.ind3

ridgeregress EP_EIDQ LnAIPatent   $cons i.year i.pro i.ind3

* 95%BC - [.0478419   .0992244 ]
capture program drop multicollinearity
program multicollinearity, rclass
preserve
ridgeregress EP_HeXun LnAIPatent   $cons i.year i.pro i.ind3
scalar b =  _b[LnAIPatent]
 end 
set seed 1234
bootstrap b,reps(500):multicollinearity  
estat boot, all

* 95%BC - [ .0877227 ,  .1307257]
capture program drop multicollinearity
program multicollinearity, rclass
preserve
ridgeregress EP_EIDQ LnAIPatent   $cons i.year i.pro i.ind3
scalar b =  _b[LnAIPatent]
 end 
set seed 1234
bootstrap b,reps(500):multicollinearity  
estat boot, all

save data



