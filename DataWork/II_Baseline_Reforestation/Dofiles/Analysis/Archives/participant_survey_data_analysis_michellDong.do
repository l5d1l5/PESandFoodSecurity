
	***************************************
	
	* Burkina Faso Data Analysis
	
	* 1) analyze sample size
	* 2) household characteristics
	* 3) possession, asset
	* 4) agricultural production
	* 5) non agricultural activities
	* 6) baseline balance table
	
	* Written by: Michell Dong
	* Last edited: March 12, 2018
	
	**************************************
	
	
	* global
	global project "C:\Users\yoon0129\Dropbox\Burkina Faso - Serge"
	global data	"$project/participants survey/clean_data"

	* open dataset
	use "$data/participant_survey_clean.dta", clear

	* treatment variable
	gen treatment = 1 if traitement==1 | traitement==3
	replace treatment = 0 if traitement==2 | traitement==4
	tab treatment
	lab def treatment ///
	0 "Control" ///
	1 "Treatment", replace
	lab val treatment treatment
	
	***************************
	* Create Tables
	***************************
	
	* 1. introduction
	******************
	* region
	estpost tab region
	esttab using "$project/output/tab_foret.csv", cells("b pct") unstack replace
	
	* 1. bloc
	estpost tab bloc treatment
	esttab using "$project/output/tab_foret.csv", cells("b colpct") unstack replace

	* 2. foret
	estpost tab foret
	esttab using "$project/output/tab_foret.csv", cells("b pct") replace

	* 3. treatment
	estpost tab traitement
	esttab using "$project/output/tab_foret.csv", cells("b pct") append

	* 2. basic chars
	******************

	* occupation
	estpost tab sbq9 treatment
	esttab using "$project/output/tab_foret.csv", cells("b colpct") label append

	* income by foret
	replace sbq15 = 0 if sbq15==.
	gen income = sbq11 + sbq15 // 14 missing
	egen consumption = rowtotal(seq2c_* seq3c_* seq4c_*)
	replace consumption = consumption*54
	extremes income consumption
	winsor income, gen(win_income) p(0.01)
	winsor consumption, gen(win_consumption) p(0.01)
	sum income win_income consumption win_consumption
	lab var income "Annual income including primary and secondary"
	lab var consumption "Annual food consumption"
	lab var win_income "Annual income winsorized including primary and secondary"
	lab var win_consumption "Annual food consumption winsorized"
	
	estpost tabstat win_income, by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") title("income") wide replace
	estpost tabstat win_consumption, by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") title("income") wide append

	* marital status
	tab sbq16
	g byte dum_married = (sbq16 == 2 | sbq16==3)
	lab var dum_married "Marital Status"
	tab dum_married
	estpost tab sbq16
	esttab using "$project/output/tab_foret.csv", cells("b pct") label append

	* number of hh members
	estpost tabstat sbq17, by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") label append

	* chef de menage
	recode sbq18 (2=0)
	estpost tabstat sbq18, by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") label append

	* niveau scolaire
	tab sbq21
	g byte dum_edu = (sbq21 !=1)
	lab var dum_edu "Received at least some level of schooling"
	estpost tab sbq21
	esttab using "$project/output/tab_foret.csv", cells("b pct") label append
	estpost tabstat dum_edu, by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") label append

	* membre de GGF
	recode sbq22 (2=0)
	tab sbq22
	estpost tabstat sbq22, by(foret) stat(mean n)
	esttab using "$project/output/tab_foret.csv", cells("mean count") label append
	estpost tabstat sbq22, by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") label append
	
	* Possession
	****************************
	
	global input scq1_100 scq1_101 scq1_102 scq1_103 scq1_104 scq1_105 scq1_106 ///
	scq1_107 scq1_108 scq1_109 scq1_110 scq1_111 scq1_112 scq1_113 scq1_114 ///
	scq1_115
	
	recode $input (2=0)
	estpost tabstat $input, stats(mean n) col(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean(label(mean) fmt(2)) count(label(n) fmt(0))") ///
	main(mean) aux(count) unstack  nonumber nonote noobs label title("Input") replace
	
	* have 
	global asset scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 ///
	scq3_207 scq3_208 scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 ///
	scq3_215 scq3_216 scq3_217 scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 ///
	scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228

	recode $asset (2=0)
	estpost tabstat $asset, stats(mean n) col(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean(label(mean) fmt(2)) count(label(n) fmt(0))") ///
	main(mean) aux(count) unstack  nonumber nonote noobs label title("Asset") replace

	* asset index
	pca $asset
	predict asset_index
	pca $input
	predict input_index
	estpost tabstat asset_index, by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") label replace
	estpost tabstat input_index, by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") label append
	
	global animal scq5_300 scq5_301 scq5_302 scq5_303 scq5_304 scq5_305
	recode $animal (2=0)
	estpost tabstat $animal, stats(mean n) col(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean(label(mean) fmt(2)) count(label(n) fmt(0))") ///
	main(mean) aux(count) unstack  nonumber nonote noobs label title("Asset") replace
	
	
	*****************************
	* SECTION D - agriculture
	*****************************
	* own land
	tab sdq1
	recode sdq1 (2=0)
	
	* land size
	list enqueteur sdq2 if sdq2>100 & sdq2!=.
	
	/* Note: there are 8 obs with over 350 ha land and same interviewer.
	will divide by 100 so that it's reasonable */
	replace sdq3 = sdq3/100 if sdq2>100 & sdq2!=. // 8 changes
	replace sdq2 = sdq2/100 if sdq2>100 & sdq2!=. // 8 changes

	estpost tabstat sdq1 sdq2 sdq3, stats(mean n) col(statistics)
	esttab using "$project/output/agriculture.csv", cells("mean(label(mean) fmt(2)) count(label(n) fmt(0))") ///
	main(mean) aux(count) unstack  nonumber nonote noobs label title("land") replace
	foreach var of varlist sdq1 sdq2 sdq3 {
	estpost tabstat `var', by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") label append
	}
	
	* agricultural input
	recode sdq4 sdq6 sdq8 sdq10 sdq12 (2=0)
	estpost tabstat sdq4 sdq6 sdq8 sdq10 sdq12, stats(mean n) col(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean(label(mean) fmt(2)) count(label(n) fmt(0))") ///
	main(mean) aux(count) unstack  nonumber nonote noobs label title("inputs") replace

	foreach var of varlist sdq4 sdq6 sdq8 sdq10 sdq12 {
	estpost tabstat `var', by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") label append
	}

	* where did you get money
	estpost tab sdq17
	esttab using "$project/output/tab_foret.csv", cells("b pct") label append

	* agricultural profit
	
	* agricultural cost
	egen agri_cost = rowtotal(sdq5 sdq7 sdq9 sdq11 sdq13 sdq16)
	replace agri_cost = . if sdq1!=1
	
	extremes sdq18
	
	* one extreme value of ag. production
	replace sdq18 = . if sdq18==225000000 // 1 change
	
	gen agri_profit = (sdq18-agri_cost)
	gen agri_yield = agri_profit/sdq3
	estpost tabstat sdq18 agri_cost agri_profit agri_yield win_income win_consumption, stats(mean n) col(statistics)
	esttab using "$project/output/baseline.csv", cells("mean(label(mean) fmt(2)) count(label(n) fmt(0))") ///
	main(mean) aux(count) unstack  nonumber nonote noobs label title("inputs") replace

	* agricultural yield by foret
	estpost tabstat agri_yield, by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") label append

	* change to "in 1,000 FCFA" for balance test table
	foreach var of varlist sdq18 agri_cost agri_profit agri_yield win_income win_consumption {
	replace `var' = `var'/1000
	}
	
	***********************
	* Non agricultural
	***********************
	* sdq19
	recode sdq19_a sdq19_b sdq19_c sdq19_d sdq19_e sdq19_f sdq19_g sdq19_h (2=0)
	egen dum_entreprise = anymatch(sdq19_*), value(1)
	estpost tabstat sdq19_a sdq19_b sdq19_c sdq19_d sdq19_e sdq19_f sdq19_g sdq19_h, stats(mean n) col(statistics)
	esttab using "$project/output/baseline.csv", cells("mean(label(mean) fmt(2)) count(label(n) fmt(0))") ///
	main(mean) aux(count) unstack  nonumber nonote noobs label title("inputs") replace
	estpost tabstat dum_entreprise, by(foret) stat(mean sd n) column(statistics)
	esttab using "$project/output/tab_foret.csv", cells("mean sd count") label append
	
	***********************
	* Balance Test
	***********************
	
	global balance sbq18 dum_married sbq17 dum_edu sbq22 ///
	sdq18 agri_cost agri_profit agri_yield win_income win_consumption ///
	sdq1 sdq2 sdq3 sdq4 sdq6 sdq8 sdq10 sdq12 asset_index
	
	tabstat $balance
	iebaltab $balance, rowvarlabels grpvar(treatment) cov(foret) pttest save("$project/output/balancetable.xlsx") replace


	***********************
	* Correlation Analysis
	***********************
	corr agri_profit agri_cost agri_yield asset_index input_index win_income win_consumption dum_edu dum_married sbq22
	