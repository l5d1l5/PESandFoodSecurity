set more off
drop _all

set obs 1000
gen id=_n

expand 5
bys id: gen tper=_n

matrix m = (0,0,0,0,0,0)
matrix sd = (sqrt(2),1,1,1,1,1)
drawnorm alpha Instrument x1 x2 x3 u_i, n(5000) means(m) sds(sd) seed(987654321)
sort id tper
by id: replace alpha=alpha[1]
bys id (tper): gen nwave=_N

sort id (tper)
local theta=1
by id: gen ystar=.35*x1 + .66*x2 + .25*x3 + 1.5*Instrument + .7 + `theta'*alpha + u_i if _n==1
by id: gen y=cond(ystar>0,1,0) if _n==1

sort id (tper)
forvalues i=2/5{
by id: replace ystar =.25*x1 + .75*x2 + .55*x3 + .46*y[`i'-1] + .35  + alpha + u_i if _n==`i'
by id: replace y=cond(ystar>0,1,0) if _n==`i'
}

sort id (tper)
by id: gen ylag=cond(_n>1,y[_n-1],.)

cap prog drop mpheckman_d0
program define mpheckman_d0
	args todo b lnf 
	tempname sigma theta 
	tempvar beta pi lnsigma lntheta T fi fi4 fi3 fi5 FF
	mleval `beta'		= `b', eq(1)
	mleval `pi'			= `b', eq(2)
	mleval `lnsigma'  	= `b', eq(3)  scalar
	mleval `lntheta'   	= `b', eq(4)  scalar
	
	qui:{
	by id: gen double `T' = (_n == _N)
	sort id (tper)
	tempvar k1 zb1
	by id: gen double `k1' = (2*$ML_y1[1]) - 1
	by id: gen double `zb1' = `pi'[1]
	forvalues r = 2/$T_max {
	tempvar k`r' xb`r'
	by id: gen double `k`r'' = (2*$ML_y1[`r']) - 1
	by id: gen double `xb`r'' = `beta'[`r']
	}
	
	scalar `sigma'=(exp(`lnsigma'))^2
	scalar `theta'=exp(`lntheta')
	
	forvalues s=$T_min/$T_max{
	tempname V`s' C`s'
	}
	
	mat `V$T_max'=I($T_max)*(`sigma'+1)
	mat `V$T_max'[1,1]=(`theta'^2)*`sigma'+1
	
	forvalues row=2/$T_max {
		mat `V$T_max'[`row',1] = (`theta'*`sigma')
		mat `V$T_max'[1,`row'] = `V$T_max'[`row',1]
		local r1 = `row'-1
		forvalues col=2/`r1' {
			mat `V$T_max'[`row',`col'] = `sigma' 
			mat `V$T_max'[`col',`row'] = `V$T_max'[`row',`col']
		}
	}

	forvalues r = $T_min/$T_max{
	mat `V`r'' = `V$T_max'[1..`r',1..`r'] 
	mat `C`r'' = cholesky(`V`r'')
	}
	
	egen double `fi5' = mvnp(`zb1' `xb2' `xb3' `xb4' `xb5') if nwave==5, /*
	*/ chol(`C5') dr($dr) prefix(z) signs(`k1' `k2' `k3' `k4' `k5') adoonly
		
	gen double `fi'=`fi5'
	gen double `FF' = cond(!`T',0,ln(`fi'))
	}
	mlsum `lnf' = `FF' if `T'
	if (`todo'==0 | `lnf'>=.) exit

end

global T_max=5
global T_min=5

* 20 Draws
sort id (tper)
local a ylag x1 x2 x3 
local b x1 x2 x3 Instrument
local y y

qui: probit `y' `a' if tper>1
matrix b0=e(b)

qui: probit `y' `b' if tper==1
matrix b1=e(b)

matrix b12 = (-.5,-.5)
matrix b0 = (b0 , b1 , b12)

matrix p=(2,3,5,7,11)
mdraws, neq(5) draws(20) prefix(z) primes(p) burn(15)
global dr = r(n_draws)

ml model d0 mpheckman_d0 (y: `y' = `a') (Init_Period: `y' = `b') /lnsigma /lntheta, /*
*/ title(Multivariate RE Probit, $dr Halton draws) missing
ml init b0, copy
ml max

_diparm lnsigma, function((exp(@))^2) deriv(2*(exp(@))*(exp(@))) label("Sigma^2") prob
_diparm lntheta, function(exp(@)) deriv(exp(@)) label("Theta") prob

test [y]_b[ylag]=.46
test [y]_b[x1]=.25
test [y]_b[x2]=.75
test [y]_b[x3]=.55
test [y]_b[_cons]=.35

test [Init_Period]_b[x1]=.35
test [Init_Period]_b[x2]=.66
test [Init_Period]_b[x3]=.25
test [Init_Period]_b[Instrument]=1.5
test [Init_Period]_b[_cons]=.7

keep id- ylag

* 50 Draws
sort id (tper)
local a ylag x1 x2 x3 
local b x1 x2 x3 Instrument
local y y

qui: probit `y' `a' if tper>1
matrix b0=e(b)

qui: probit `y' `b' if tper==1
matrix b1=e(b)

matrix b12 = (-.5,-.5)
matrix b0 = (b0 , b1 , b12)

matrix p=(2,3,5,7,11)
mdraws, neq(5) draws(50) prefix(z) primes(p) burn(15)
global dr = r(n_draws)

ml model d0 mpheckman_d0 (y: `y' = `a') (Init_Period: `y' = `b') /lnsigma /lntheta, /*
*/ title(Multivariate RE Probit, $dr Halton draws) missing
ml init b0, copy
ml max

_diparm lnsigma, function((exp(@))^2) deriv(2*(exp(@))*(exp(@))) label("Sigma^2") prob
_diparm lntheta, function(exp(@)) deriv(exp(@)) label("Theta") prob

test [y]_b[ylag]=.46
test [y]_b[x1]=.25
test [y]_b[x2]=.75
test [y]_b[x3]=.55
test [y]_b[_cons]=.35

test [Init_Period]_b[x1]=.35
test [Init_Period]_b[x2]=.66
test [Init_Period]_b[x3]=.25
test [Init_Period]_b[Instrument]=1.5
test [Init_Period]_b[_cons]=.7

keep id- ylag

* 100 Draws
sort id (tper)
local a ylag x1 x2 x3 
local b x1 x2 x3 Instrument
local y y

qui: probit `y' `a' if tper>1
matrix b0=e(b)

qui: probit `y' `b' if tper==1
matrix b1=e(b)

matrix b12 = (-.5,-.5)
matrix b0 = (b0 , b1 , b12)

matrix p=(2,3,5,7,11)
mdraws, neq(5) draws(100) prefix(z) primes(p) burn(15)
global dr = r(n_draws)

ml model d0 mpheckman_d0 (y: `y' = `a') (Init_Period: `y' = `b') /lnsigma /lntheta, /*
*/ title(Multivariate RE Probit, $dr Halton draws) missing
ml init b0, copy
ml max

_diparm lnsigma, function((exp(@))^2) deriv(2*(exp(@))*(exp(@))) label("Sigma^2") prob
_diparm lntheta, function(exp(@)) deriv(exp(@)) label("Theta") prob

test [y]_b[ylag]=.46
test [y]_b[x1]=.25
test [y]_b[x2]=.75
test [y]_b[x3]=.55
test [y]_b[_cons]=.35

test [Init_Period]_b[x1]=.35
test [Init_Period]_b[x2]=.66
test [Init_Period]_b[x3]=.25
test [Init_Period]_b[Instrument]=1.5
test [Init_Period]_b[_cons]=.7

keep id- ylag

* Pseudo random numbers
* 20 Draws
local a ylag x1 x2 x3 
local b x1 x2 x3 Instrument
local y y
matrix p=(2,3,5,7)

xtset, clear
redpace `y' `a' (`b'), i(id) t(tper) rep(20) drop(15) noauto 

test [y]_b[ylag]=.46
test [y]_b[x1]=.25
test [y]_b[x2]=.75
test [y]_b[x3]=.55
test [y]_b[_cons]=.35

test [rfper1]_b[x1]=.35
test [rfper1]_b[x2]=.66
test [rfper1]_b[x3]=.25
test [rfper1]_b[Instrument]=1.5
test [rfper1]_b[_cons]=.7

keep id- ylag

* 50 Draws

xtset, clear
redpace `y' `a' (`b'), i(id) t(tper) rep(50) drop(15) noauto 

test [y]_b[ylag]=.46
test [y]_b[x1]=.25
test [y]_b[x2]=.75
test [y]_b[x3]=.55
test [y]_b[_cons]=.35

test [rfper1]_b[x1]=.35
test [rfper1]_b[x2]=.66
test [rfper1]_b[x3]=.25
test [rfper1]_b[Instrument]=1.5
test [rfper1]_b[_cons]=.7

keep id- ylag

* 100 Draws

xtset, clear
redpace `y' `a' (`b'), i(id) t(tper) rep(100)  drop(15) noauto

test [y]_b[ylag]=.46
test [y]_b[x1]=.25
test [y]_b[x2]=.75
test [y]_b[x3]=.55
test [y]_b[_cons]=.35

test [rfper1]_b[x1]=.35
test [rfper1]_b[x2]=.66
test [rfper1]_b[x3]=.25
test [rfper1]_b[Instrument]=1.5
test [rfper1]_b[_cons]=.7

keep id- ylag

* Halton draws
* 20 Draws
local a ylag x1 x2 x3 
local b x1 x2 x3 Instrument
local y y
matrix p=(2,3,5,7)

xtset, clear
redpace `y' `a' (`b'), i(id) t(tper) rep(20) primes(p) drop(15) noauto halton

test [y]_b[ylag]=.46
test [y]_b[x1]=.25
test [y]_b[x2]=.75
test [y]_b[x3]=.55
test [y]_b[_cons]=.35

test [rfper1]_b[x1]=.35
test [rfper1]_b[x2]=.66
test [rfper1]_b[x3]=.25
test [rfper1]_b[Instrument]=1.5
test [rfper1]_b[_cons]=.7

keep id- ylag

* 50 Draws

xtset, clear
redpace `y' `a' (`b'), i(id) t(tper) rep(50) primes(p) drop(15) noauto halton

test [y]_b[ylag]=.46
test [y]_b[x1]=.25
test [y]_b[x2]=.75
test [y]_b[x3]=.55
test [y]_b[_cons]=.35

test [rfper1]_b[x1]=.35
test [rfper1]_b[x2]=.66
test [rfper1]_b[x3]=.25
test [rfper1]_b[Instrument]=1.5
test [rfper1]_b[_cons]=.7

keep id- ylag

* 100 Draws

xtset, clear
redpace `y' `a' (`b'), i(id) t(tper) rep(100) primes(p) drop(15) noauto halton

test [y]_b[ylag]=.46
test [y]_b[x1]=.25
test [y]_b[x2]=.75
test [y]_b[x3]=.55
test [y]_b[_cons]=.35

test [rfper1]_b[x1]=.35
test [rfper1]_b[x2]=.66
test [rfper1]_b[x3]=.25
test [rfper1]_b[Instrument]=1.5
test [rfper1]_b[_cons]=.7

keep id- ylag

exit
