clear all
set more off
capture log close
sjlog using Multivariate_RE_Probit_Simulated_Data_AR1, replace

************************************************************** Data Preparation **********************************
sjlog using simulatedmultivariate8, replace
webuse union
drop if year<78
drop if year==83
bys idcode (year): gen nwave=_N
bys idcode (year): gen tper=_n
keep if nwave==6
by idcode (year), sort: gen Lunion = union[_n-1]
sjlog close, replace

************************************************** Multivariates RE AR1 Probit **************************************

cap prog drop mpheckman_d0
program define mpheckman_d0
	args todo b lnf 
	tempname sigma theta rho
	tempvar beta pi lnsigma lntheta trho T fi zb1 xb2 xb3 xb4 xb5 xb6 k1 k2 k3 k4 k5 k6 FF V6 C6
	mleval `beta'		= `b', eq(1)
	mleval `pi'			= `b', eq(2)
	mleval `lnsigma'  	= `b', eq(3) scalar
	mleval `lntheta'  	= `b', eq(4) scalar
	mleval `trho'       = `b', eq(5) scalar
	
	scalar `sigma'=(exp(`lnsigma'))^2
	scalar `theta'=exp(`lntheta')	
	scalar `rho'  =tanh(`trho')
	
	qui:{
	sort idcode (year)
	tempvar k1 zb1
	by idcode: gen double `k1' = (2*$ML_y1[1]) - 1
	by idcode: gen double `zb1' = `pi'[1]
	forvalues r = 2/6 {
	tempvar k`r' xb`r'
	by idcode: gen double `k`r'' = (2*$ML_y1[`r']) - 1
	by idcode: gen double `xb`r'' = `beta'[`r']
	}
			
	by idcode: gen double `T' = (_n == _N)
	
	mat `V6'=I(6)*(`sigma'+1)
	mat `V6'[1,1]=(`theta'^2)*`sigma'+1
	
	forvalues row=2/6 {
		mat `V6'[`row',1] = (`theta'*`sigma' + `rho'^(`row'-1))
		mat `V6'[1,`row'] = `V6'[`row',1]
		local r1 = `row'-1
		forvalues col=2/`r1' {
			mat `V6'[`row',`col'] = `sigma' + `rho'^(`row'-`col')
			mat `V6'[`col',`row'] = `V6'[`row',`col']
		}
	}

	mat `C6' = cholesky(`V6')
	
	egen `fi' = mvnp(`zb1' `xb2' `xb3' `xb4' `xb5' `xb6'), chol(`C6') dr($dr) prefix(z) signs(`k1' `k2' `k3' `k4' `k5' `k6')	adoonly
	gen double `FF' = cond(!`T',0,ln(`fi'))
	}
	mlsum `lnf' = `FF' if `T'
	if (`todo'==0 | `lnf'>=.) exit

end

sort idcode year
local a Lunion age grade south 
local b age grade south not_smsa
local y1 union


* 20 draws
timer on 1


sjlog using simulatedmultivariate9, replace
qui: probit union Lunion age grade south if tper>1
matrix b0=e(b)
qui: probit union age grade south not_smsa if tper==1
matrix b1=e(b)
matrix b12 = (-.5,-.5,-.2)
matrix b0 = (b0 , b1 , b12)
sjlog close, replace


sjlog using simulatedmultivariate10, replace
matrix p=(2,3,5,7,11,13)
mdraws, neq(6) draws(20) prefix(z) primes(p) burn(15) 
global dr = r(n_draws)
ml model d0 mpheckman_d0 (`y1': `y1' = `a') (Init_Period: `y1' = `b') /lnsigma /lntheta /trho /*
*/,  title(Multivariate AR1 Probit, $dr Halton draws) missing
ml init b0, copy
ml max, search(off)
sjlog close, replace

matrix b0=e(b)

_diparm lnsigma, function((exp(@))^2) deriv(2*(exp(@))*(exp(@))) label("Sigma^2") prob
_diparm lntheta, function(exp(@))	  deriv(exp(@))				 label("Theta")   prob
_diparm trho,	 tanh											 label("Rho")	  prob

keep idcode- Lunion 

* 50 Draws
local a Lunion age grade south 
local b age grade south not_smsa
local y1 union

qui: probit union Lunion age grade south if tper>1
matrix b0=e(b)

qui: probit union age grade south not_smsa if tper==1
matrix b1=e(b)

matrix b12 = (-.5,-.5,-.2)
matrix b0 = (b0 , b1 , b12)

matrix p=(2,3,5,7,11,13)
mdraws, neq(6) draws(50) prefix(z) primes(p) burn(15) 
global dr = r(n_draws)

ml model d0 mpheckman_d0 (`y1': `y1' = `a') (Init_Period: `y1' = `b') /lnsigma /lntheta /trho /*
*/,  title(Multivariate AR1 Probit, $dr Halton draws) missing
ml init b0, copy
ml max, search(off)
matrix b0=e(b)

_diparm lnsigma, function((exp(@))^2) deriv(2*(exp(@))*(exp(@))) label("Sigma^2") prob
_diparm lntheta, function(exp(@))	  deriv(exp(@))				 label("Theta")   prob
_diparm trho,	 tanh											 label("Rho")	  prob
keep idcode- Lunion 

* 100 Draws
timer on 3
local a Lunion age grade south 
local b age grade south not_smsa
local y1 union

qui: probit union Lunion age grade south if tper>1
matrix b0=e(b)

qui: probit union age grade south not_smsa if tper==1
matrix b1=e(b)

matrix b12 = (-.5,-.5,-.2)
matrix b0 = (b0 , b1 , b12)

matrix p=(2,3,5,7,11,13)
mdraws, neq(6) draws(100) prefix(z) primes(p) burn(15) 
global dr = r(n_draws)

ml model d0 mpheckman_d0 (`y1': `y1' = `a') (Init_Period: `y1' = `b') /lnsigma /lntheta /trho /*
*/,  title(Multivariate AR1 Probit, $dr Halton draws) missing
ml init b0, copy
ml max, search(off)
matrix b0=e(b)

_diparm lnsigma, function((exp(@))^2) deriv(2*(exp(@))*(exp(@))) label("Sigma^2") prob
_diparm lntheta, function(exp(@))	  deriv(exp(@))				 label("Theta")   prob
_diparm trho,	 tanh											 label("Rho")	  prob

keep idcode- Lunion 

* Redpace
xtset, clear
redpace union Lunion age grade south (age grade south not_smsa), i(idcode) t(tper) rep(20) seed(945430778)
keep idcode- Lunion
xtset, clear
redpace union Lunion age grade south (age grade south not_smsa), i(idcode) t(tper) rep(50) seed(945430778)
keep idcode- Lunion
xtset, clear
redpace union Lunion age grade south (age grade south not_smsa), i(idcode) t(tper) rep(100) seed(945430778)
keep idcode- Lunion

* 500 Draws
mat bstart1 = ( 1.322202, -.0234323, -.0363382, /*
*/  -.3695182,  .0803734,  .0108658, -.0133834, -.7548028, /*
*/  -.4195162, -.8910983,  .0756969, -.3512991,  .2041694)
mat colnames bstart1 = union:Lunion union:age union:grade union:south union:_cons /*
*/ rfper1:age rfper1:grade rfper1:south rfper1:not_smsa rfper1:_cons /*
*/ logitlam:_cons atar1:_cons ltheta:_cons
redpace union Lunion age grade south (age grade south not_smsa), i(idcode) t(tper) /*
*/  rep(500) seed(945430778) from(bstart1)

* Halton draws
keep idcode- Lunion
xtset, clear
local a Lunion age grade south 
local b age grade south not_smsa
local y1 union
matrix p=(2,3,5,7,11)

redpace `y1' `a' (`b'), i(idcode) t(tper) rep(20) drop(15) primes(p) halton

keep idcode- Lunion
xtset, clear
local a Lunion age grade south 
local b age grade south not_smsa
local y1 union
matrix p=(2,3,5,7,11)

redpace `y1' `a' (`b'), i(idcode) t(tper) rep(50) drop(15) primes(p) halton

keep idcode- Lunion
xtset, clear
local a Lunion age grade south 
local b age grade south not_smsa
local y1 union
matrix p=(2,3,5,7,11)

redpace `y1' `a' (`b'), i(idcode) t(tper) rep(100) drop(15) primes(p) halton

******************************************************************End*****************************************************************
exit
