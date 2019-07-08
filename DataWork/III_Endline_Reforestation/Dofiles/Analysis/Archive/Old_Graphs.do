/* ******************************************************************* *
* ******************************************************************** *
*                                                                      *
*         		PIF Burkina Faso		  					   			*
*		  		Archive of old Graphs		
*																	   *
* ******************************************************************** *
* ******************************************************************** *


** WRITTEN BY: Jonas Guthoff (jguthoff@worldbank.org)
** CREATED: 25/03/2019

	** OUTLINE:		0. Load data
					
					1. Outsheet Summary Statistics on a Section-by-Section Basis
							
		
	** Requires:  	To Run Project_MasterDofile.do to set the globals
						   
				    for each Section it pulls data constructed from the PIF_Endline_Construct.do		   
	
	
	
	
	** Unique identifier: hhid
	

*/
********************************************************************************
********************************************************************************
		
	
			
	* ------------------------------------------------------------------------ *		
	* ie graphs
	
	

	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
	
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle) gen(serge1)
		keep if serge1==3		
	
	global graph_opts_pie bgcolor(white) graphregion(color(white)) legend(region(lc(none) fc(none))) ///

	gen Food_Insecure1 = (1-HFIA_cat_1)*100
	gen Food_Insecure2 = (HFIA_cat_4)*100
	
	*label variable Food_Insecure "Food insecure category of the HFIA scale"
	label define treatment 0"Non Participants" 1"PES Participants", modify
	label values treatment treatment
	*regress Food_Insecure treatment 
  	regress Food_Insecure1 treatment
	iegraph treatment , basictitle("Food Insecure")  ///
						yzero  ylabel(0(10)45 , labsize(small))   ytitle("Percentage", size(medium))  ///
						legend(order(1 2)  lab(1 "Non Participants")  lab(2 "PES Participants"))  ///
						/// note("Note: The graph shows that participants in the PES scheme are 14 pct. points less likely"  ///
						///     "to be food insecure compared to non participants. This suggests that, if well-planned,"  ///
						///	 "agri environmental schemes in developing countries have the potential to deliver both"  ///
						///	 "in terms of food security and ecosystem services, especially amongst vulnerable communities"  ///
						///	 "in the drylands of SSA.") ///
				graphregion(fcolor(white) ifcolor(white)) $graph_opts_pie  ///
				plotregion(fcolor(white) ifcolor(white)) scale(*1)	
		graph rename HFIAS_1, replace		
		
		
  	regress Food_Insecure2 treatment
	iegraph treatment , basictitle("Severely Food Insecure")  ///
						yzero  ylabel(0(10)45 , labsize(small))   ytitle("Percentage", size(medium))  ///
						legend(order(1 2)  lab(1 "Non Participants")  lab(2 "PES Participants"))  ///
						/// note("Note: The graph shows that participants in the PES scheme are 14 pct. points less likely"  ///
						///     "to be food insecure compared to non participants. This suggests that, if well-planned,"  ///
						///	 "agri environmental schemes in developing countries have the potential to deliver both"  ///
						///	 "in terms of food security and ecosystem services, especially amongst vulnerable communities"  ///
						///	 "in the drylands of SSA.") ///
				graphregion(fcolor(white) ifcolor(white)) $graph_opts_pie  ///
				plotregion(fcolor(white) ifcolor(white)) scale(*1)	
		graph rename HFIAS_4, replace	
		
		
		
	* Outsheet both bar graphs	
	grc1leg HFIAS_1 HFIAS_4, title(Conservation Incentives and Food Security)  ///
			subtitle(Evidence from the Burkina Faso Forest Investment Program (FIP), size(small)) $graph_opts_pie ///
			legendfrom(HFIAS_1) graphregion(color(white))  note ("Note: Food security categories based on Household Food Insecurity Experience Scale (FIES)", size(small))
	gr export	"$EDLREFOR_outFin/Food_Insecure_graph.eps",  replace	
	graph drop HFIAS_1 HFIAS_4		
				
	
			
			
				
				
				
				
		
	
	
	
	
	
	* Bar graph food expenditure
	graph bar expshr_foodgroup*, over(treatment, label(labsize(small))) blabel(bar, format(%9.1f) size(vsmall)) 	bargap(10) ///
						ytitle(Part Moyenne (en pourcentage), size(small)) ///
						ytitle(, margin(medium)) ///
						legend (order(	1 	"Céréales, racines, et tubers"     ///
										2 	"Gousses / fruits à pericarpes"    ///
										3 	"Légumes"                          ///
										4 	"Fruits"                           ///
										5 	"Viande et poisson"                ///
										6	"Produits laitiers"                ///
										7	"Huiles"                           ///
										8	"Sucre"                            ///
										9	"Autres - tabac, alcool, condiments" )  ///	
									size(vsmall)) 			///			
						/// title("Can PES improve Household Food Security?") ///
						title("Distribution des depenses alimentaires par groupe d'aliments", size(medium)) ///
						/// subtitle("Most people who received PES transfers as part of the Burkina Faso FIP reforestation campaign in 2017" "indicated they would use it primarily towards food purchases for their households", size(vsmall))  ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*1)		
	gr export 	"$EDLREFOR_outFin/FoodConsExpShr_byfoodgroup.eps",  replace		
	
	
	
	
				
	* Stack Graph 					
	graph bar expfoodgroup*, stack over(treatment, label(labsize(small)))  blabel(bar, position (center) format(%9.0f) size(tiny))  ///
						ytitle(Depenses (en FCFA), size(small)) ///
						ytitle(, margin(medium)) ///
						legend (order(	1 	"Céréales, racines, et tubers"     ///
										2 	"Gousses / fruits à pericarpes"    ///
										3 	"Légumes"                          ///
										4 	"Fruits"                           ///
										5 	"Viande et poisson"                ///
										6	"Produits laitiers"                ///
										7	"Huiles"                           ///
										8	"Sucre"                            ///
										9	"Autres - tabac, alcool, condiments" )  ///	
									size(vsmall)) 			///			
						title("Depenses alimentaires par groupe d'aliments", size(medium)) ///
						/// subtitle("Most people who received PES transfers as part of the Burkina Faso FIP reforestation campaign in 2017" "indicated they would use it primarily towards food purchases for their households", size(vsmall))  ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*1)		
	gr export 	"$EDLREFOR_outFin/FoodConsExp_byfoodgroup_stack.eps",  replace		
	
	
	
	* Transform and graph "food security levels"

	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
	
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle) gen(serge1)
		keep if serge1==3		
	
	foreach month in  oct nov dec {
		rename 	`month'_2017 year2017_`month'
		}
	
	
	foreach month in jan feb mar april may june jul aug sept  {					 
		rename 	`month'_2018 year2018_`month'
		}
	
	rename year2018_jan		year2018_4		
	rename year2018_feb		year2018_5
	rename year2018_mar		year2018_6
	rename year2018_april	year2018_7
	rename year2018_may		year2018_8
	rename year2018_june	year2018_9
	rename year2018_jul		year2018_10
	rename year2018_aug		year2018_11
	rename year2018_sept	year2018_12
	rename year2017_oct		year2017_1
	rename year2017_nov		year2017_2	
	rename year2017_dec		year2017_3
			
			
	reshape long year2017_ year2018_, i(hhid) j(month)
 	
	replace 	 year2018_ = year2017_ 		if year2018_ == . & year2017_ !=.
	
	* Bar graph	
	global graph_bar bgcolor(white) graphregion(color(white)) legend(region(lc(none) fc(none))) ///
					   ylab(,angle(0) nogrid) title(, justification(left) color(black) span pos(11)) subtitle(, justification(left) color(black))		
	
	
	
	graph bar year2018_, over(month, 	///
						 relabel(1 "Oct"  2 "Nov" 3 "Dec"  4 "Jan" 5 "Feb" 6	"Mar" 7	"Apr"   					///
								 8 "May"  9	"Jun"  10 "Jul" 	11  "Aug"  12  "Sept" ))							///
						ytitle("Percent")										///
						blabel(bar, format(%9.1f) lstyle(solid) lc(black) color(edkblue) size(vsmall)) 	bargap(10) 			///
						$graph_bar
	gr export "$EDLREFOR_outFin/PES_paper/FoodInsecure_bymonth_bars.eps",  replace	
	
	
	
	
	collapse (mean)	 year2018_, by(month treatment)
	 
		
	label define months	1 "Oct"  2 "Nov" 3 "Dec"  4 "Jan" 5 "Feb" 6	"Mar" 7	"Apr"   ///
						8 "May"  9	"Jun"  10 "Jul" 	11  "Aug"  12  "Sept" 
						
	label values month	 months								         
							
	global graph_lpoly bgcolor(white) graphregion(color(white)) legend(region(lc(none) fc(none))) ///
					   ylab(,angle(0) nogrid) title(, justification(left) color(black) span pos(11)) subtitle(, justification(left) color(black))		
	
	
	twoway  (lpoly year2018_ month if treatment == 0)  ||						///
			(lpoly year2018_ month if treatment == 1),  						///
			xlabel(1(1)12) 	ytitle("Share of respondents (in %)", height(7))		///
			xtitle("Months", height(7))													///
			xlabel(1 "Oct"  2 "Nov" 3 "Dec"  4 "Jan" 5 "Feb" 6	"Mar" 7	"Apr"   ///
						8 "May"  9	"Jun"  10 "Jul" 	11  "Aug"  12  "Sept"  ) ///
			legend(order(1 "Control" 2 "Treatment"))							///	
			$graph_lpoly
			
	gr export "$EDLREFOR_outFin/PES_paper/FoodInsecure_bymonth_lpoly.eps",  replace	
		
				
		
		
	
	
	
	

* ------------------------------------------------------------------------------
*								OLS regressions
* ------------------------------------------------------------------------------


	
	* REGRESSION ANALYSIS
	
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle) gen(serge1)
		keep if serge1==3	
		
			
		*adding baseline info 
		
		merge 1:1 hhid using "$BSLREFOR_dt/Intermediate/SectionB_construct.dta", ///
				  keepusing(age female farmer revenu1 Lrevenu1 revenu_tot       ///
							Wrevenu_tot Lrevenu_tot sec_activity married       ///
							monogamous polygamous hsize chief schooling       ///
							GGF_member dist_far motor) 
						drop _merge
							
		merge 1:1 hhid using "$BSLREFOR_dt/Intermediate/SectionC_construct.dta",  ///
				keepusing(assets_agri_sum assets_house_sum assets_livestock_sum  ///
							asset_agr_index asset_hh_index asset_live_index)
						drop _merge
		
		merge 1:1 hhid using "$BSLREFOR_dt/Intermediate/SectionD_construct.dta",  ///
				keepusing(lanholdings land_cultivated)
						drop _merge
						
		merge 1:1 hhid using "$BSLREFOR_dt/Intermediate/SectionE_construct.dta",  ///
				keepusing (FoodExp_base LFoodExp_base HDDS_base)		
		
	drop if 	found_participant == 2
	
	
	
	local covariates     "age female farmer lanholdings Lrevenu_tot sec_activity married hsize schooling GGF_member dist_far"
	local base_outcome 	 "FoodExp_base LFoodExp_base HDDS_base"


 

	foreach lhsVar of varlist FoodExp LFoodExp HDDS  {

	label variable `lhsVar'_base  "Baseline outcome"

	estimates clear

		reg `lhsVar' treatment  i.bloc i.parcelle
		eststo
		eststo dir
		estadd	local Controls		"No"
		estadd	local Bloc			"Yes"
		
		reg `lhsVar' treatment `lhsVar'_base  i.bloc i.parcelle
		eststo
		eststo dir
		estadd	local Controls		"No"
		estadd	local Bloc			"Yes"		

		reg `lhsVar' treatment `lhsVar'_base  i.bloc i.parcelle `covariates'
		eststo
		estadd	local Controls		"Yes"
		estadd	local Bloc			"Yes"

		
		esttab using 	"$EDLREFOR_outFin/delete_me.tex", replace ///
						varwidth(5) modelwidth(2) width(1.2\hsize) bracket label r2 ar2 p(%9.3f) ///
						nobaselevels noomitted interaction(" X ") ///
						/// nomtitles 		///				
						drop(*.bloc *.parcelle `covariates') ///
						star(+ 0.15  * 0.10  ** 0.05  *** 0.01) ///						
						scalars("Controls Controls" "Bloc Bloc fixed-effects")  ///
						mtitles("`lhsVar'" "`lhsVar'" "`lhsVar'") ///
						addnotes(Notes: P value in bracket. \sym{+} \(p<0.15\), \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)) nonotes 
						
						
						
		filefilter 	"$EDLREFOR_outFin/delete_me.tex" "$EDLREFOR_outFin/delete_me1.tex", 	///				
					from("{l}") to("{p{1.0\BStextwidth}}") replace						
							
                    filefilter   "$EDLREFOR_outFin/delete_me1.tex" "$EDLREFOR_outFin/`lhsVar'_RegResults.tex",        ///                                                          
                            from("\BShline") to("\BScline{1-4}") replace      					
	}
	*	
	
	
	
	
	
	
* ------------------------------------------------------------------------------
*	REGRESSION ANALYSIS - HFIAS 
* ------------------------------------------------------------------------------
	
	
	
	foreach lhsVar of varlist HFIAS_score HFIA_cat_1 HFIA_cat_4 HHS HHScat1 HHScat2  {



	estimates clear

		reg `lhsVar' treatment  i.bloc i.parcelle
		eststo
		eststo dir
		estadd	local Controls		"No"
		estadd	local Bloc			"Yes"

		reg `lhsVar' treatment  i.bloc i.parcelle `covariates'
		eststo
		estadd	local Controls		"Yes"
		estadd	local Bloc			"Yes"

		
		esttab using 	"$EDLREFOR_outFin/delete_me.tex", replace ///
						varwidth(5) modelwidth(2) width(1.2\hsize) bracket label r2 ar2 p(%9.3f) ///
						nobaselevels noomitted interaction(" X ") ///
						/// nomtitles 		///				
						drop(*.bloc *.parcelle `covariates') ///
						star(+ 0.15  * 0.10  ** 0.05  *** 0.01) ///						
						scalars("Controls Controls" "Bloc Bloc fixed-effects")  ///
						mtitles("`lhsVar'" "`lhsVar'") ///
						addnotes(Notes: P value in bracket. \sym{+} \(p<0.15\), \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)) nonotes 
						
						
						
		filefilter 	"$EDLREFOR_outFin/delete_me.tex" "$EDLREFOR_outFin/delete_me1.tex", 	///				
					from("{l}") to("{p{1.0\BStextwidth}}") replace						
							
                    filefilter   "$EDLREFOR_outFin/delete_me1.tex" "$EDLREFOR_outFin/`lhsVar'_RegResults.tex",        ///                                                          
                            from("\BShline") to("\BScline{1-3}") replace      					
	}
	*		
	
	
			
