
***HW6 APPLIED ECONOMETRIC****************
***** CENTRAL JAVA DATABASE YEAR OF 2011********
*log using "$data/HW#6_central_java", replace


*****IMORT DATA**********
**WEIGHT MATRIX****
* Import .dta weights matrix with spmatrix (official function from Stata15)
use "https://github.com/quarcs-lab/data-open/raw/master/Columbus/columbus/Wqueen_fromStata_spmat.dta", clear
gen id = _n
order id, first
drop if id>35
drop v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49
spset id
spmatrix fromdata WqueenS_fromStata15 = v*, normalize(row) replace
spmatrix summarize WqueenS_fromStata15



****DATA****
*use "$data/HW#6_central_java", replace

use "https://github.com/rabdulah85/assignment/raw/main/HW%236_central_java.dta", replace
gen lnwage=ln(wage)
spmatrix create contiguity WqueenS_fromStata15   , replace 
label var pov "Poverty at District Level in Central Java-Indonesia 2011"
label var hdi  "Human Development Index at District Level in Central Java-Indonesia 2011"
label var lnwage "Minimum Wage (log natural) at District Level in Central Java-Indonesia 2011"
*year : 20111

describe


**Map of the Data***
grmap lnwage, t(2011)
grmap hdi, t(2011)
grmap pov, t(2011)
******************************
***** ANSELIN'S APPROACH *****
******************************

* OLS
regress hdi pov lnwage
eststo OLS_1

estat ic
mat s=r(S)
quietly estadd scalar AIC = s[1,5]

* Moran's I test. It tests if error terms are independently and identically distributed (i.i.d.), indicating no spatial autocorrelation.
regress hdi pov lnwage
estat moran, errorlag(WqueenS_fromStata15)

* Lagrange Multiplier (LM) test for spatial autocorrelation
spatwmat using "https://github.com/quarcs-lab/data-open/raw/master/Columbus/columbus/Wqueen_fromStata_spmat.dta", name(WqueenS_fromStata_spatwmat) eigenval(eWqueenS_fromStata_spatwmat) standardize drop(36/49)
quietly reg hdi pov lnwage
spatdiag, weights(WqueenS_fromStata_spatwmat) 

**KEEP OLS, NO SIGNIFICANCE ON LEM TEST

****************************
***** ELHORST APPROACH *****
****************************

* SDM
spregress hdi pov lnwage, ml dvarlag(WqueenS_fromStata15) ivarlag(WqueenS_fromStata15: pov lnwage)
eststo SDM_1

estat ic
mat s=r(S)
quietly estadd scalar AIC = s[1,5], replace

estat impact


* Wald tests. 
** Reduce to OLS? (NO if p < 0.05 of the spatial terms)
spregress hdi pov lnwage, ml dvarlag(WqueenS_fromStata15) ivarlag(WqueenS_fromStata15: pov lnwage)


** Reduce to SLX? (NO if p < 0.05)
test ([WqueenS_fromStata15]hdi = 0)

*P-value 0,6707 ==> reduce to SLX


** Reduce to SAR (NO if p < 0.05)
test ([WqueenS_fromStata15]pov = 0) ([WqueenS_fromStata15]lnwage = 0)
*P-value 0,8304 ==> reduce to SAR

** Reduce to SEM? (NO if p < 0.05)
testnl ([WqueenS_fromStata15]pov = -[WqueenS_fromStata15]hdi*[hdi]pov) ([WqueenS_fromStata15]lnwage = -[WqueenS_fromStata15]hdi*[hdi]lnwage)

*P-value 0,7906 ==> reduce to SEM



* Compile regression table
#delimit;
    esttab OLS_1 SEM_1 SAR_1 SLX_1 SDM_1,
    keep(hdi pov lnwage)
    se
	label 
    stats(N N_g r2 AIC, 
        fmt(0 0 2)
        label("Observations" "N Districts" "R-squared"))
    mtitles("OLS" "SEM" "SAR" "SLX" "SDM") 
    nonotes
    addnote("* p<0.10, ** p<0.05, *** p<0.01")
    star(* 0.10 ** 0.05 *** 0.01)  
    b(%7.3f)
    compress
    replace;
#delimit cr


* Export regression table to Latex
#delimit;
    esttab OLS_1 SEM_1 SAR_1 SLX_1 SDM_1 using "hw6_1.tex",
    keep(hdi pov lnwage)
    se
	label 
    stats(N N_g r2 AIC, 
        fmt(0 0 2)
        label("Observations" "N Districts" "R-squared"))
    mtitles("OLS" "SEM" "SAR" "SLX" "SDM") 
    nonotes
    addnote("* p<0.10, ** p<0.05, *** p<0.01")
    star(* 0.10 ** 0.05 *** 0.01)  
    b(%7.3f)
    replace;
#delimit cr 
  

* Export regression table to html then convert to latex using AI

esttab OLS_1 SAR_1 SEM_1 SLX_1 SDM_1, label stats( r2 AIC) mtitle("OLS" "SAR" "SEM" "SLX" "SDM") html



