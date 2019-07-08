/* *************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
*         				PIF Burkina Faso		  					  	       *
*		  				Analysis PIF Endline data					   		   *
*																	   		   *
* **************************************************************************** *
* **************************************************************************** *


** WRITTEN BY: Jonas Guthoff 			(jguthoff@worldbank.org)
			   Guigonan Serge Adjognon  (gadjognon@worldbank.org)


** CREATED: 12/17/2018

	** OUTLINE:		0. Load data
					
					1. Outsheet Summary Statistics on a Section-by-Section Basis
							
		
	** Requires:  	To Run Project_MasterDofile.do to set the globals
						   
				    for each Section it pulls data constructed from the PIF_Endline_Construct.do		   
	
	
	
	
	** Unique identifier: hhid
	

*/
********************************************************************************
* SECTION A:  Identification du participant 			   					   *
********************************************************************************



	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", clear
	drop age female 
	
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
	
	
	* re Label treatment status english
	* label values statut treat_eng
	* label values statut treat_pes

	


	 
	* Balance characteristics - Baseline

	iebaltab  	age female farmer Lrevenu1     								 ///
			    Lrevenu_tot sec_activity married       						 ///
				hsize schooling       										 ///
				GGF_member dist_far  										 ///
				asset_agr_index asset_hh_index  							 ///
				lanholdings land_cultivated   								 ///
				FoodExp_base LFoodExp_base HDDS_base, 						 ///
				grpvar(statut) order(1 0)									 ///
				savetex("$EDLREFOR_outFin/delete_me.tex") 	  				 ///
				tblnote("") texnotewidth(2)								 	 ///
				total rowvarlabels pftest   								 ///
				ftest  fmissok												 ///
				replace
	
	filefilter "$EDLREFOR_outFin/delete_me.tex" "$EDLREFOR_outFin/PES_paper/Balancing_tests.tex",        ///                                                          
				from("/BShline") to("/BScline{1-8}") replace  	 					
				
 
	 

				
	* Balance Table on baseline characteritics of those that were found
	
	preserve
	
	* Set all covariates for not found to missing
	foreach var in 	age female farmer Lrevenu1      							 ///
					Lrevenu_tot sec_activity married      						 ///
					hsize schooling      										 ///
					GGF_member dist_far   										 ///
					asset_agr_index asset_hh_index 							     ///
					lanholdings land_cultivated    								 ///
					FoodExp_base LFoodExp_base HDDS_base	{
		replace `var' = . 		if found_participant == 0
		}
		
	
	
	iebaltab  	found_participant age female farmer Lrevenu1     								 ///
			    Lrevenu_tot sec_activity married       						 ///
				hsize schooling       										 ///
				GGF_member dist_far  										 ///
				asset_agr_index asset_hh_index  							 ///
				lanholdings land_cultivated   								 ///
				FoodExp_base LFoodExp_base HDDS_base, 						 ///
				grpvar(statut) order(1 0)									 ///
				savetex("$EDLREFOR_outFin/delete_me.tex") 	  				 ///
				tblnote("") texnotewidth(2)								 	 ///
				total rowvarlabels pftest   								 ///
				ftest  fmissok												 ///
				replace
	
	filefilter "$EDLREFOR_outFin/delete_me.tex" "$EDLREFOR_outFin/PES_paper/Balancing_tests_endline.tex",        ///                                                          
				from("/BShline") to("/BScline{1-8}") replace  	 				
	restore
	
	
	
	
	
	
	* Test for Balance Test of attrited vs non-attrited respondents
	
	iebaltab  	age female farmer Lrevenu1      							 ///
			    Lrevenu_tot sec_activity married      						 ///
				hsize schooling      										 ///
				GGF_member dist_far   										 ///
				asset_agr_index asset_hh_index 							     ///
				lanholdings land_cultivated    								 ///
				FoodExp_base LFoodExp_base HDDS_base, 						 ///
				grpvar(found_participant) 	texnotewidth(2)					 ///
				savetex("$EDLREFOR_outFin/delete_me.tex") 	  				 ///
				tblnote("") order(1 0)										 ///
				total rowvarlabels pftest replace
	
	filefilter "$EDLREFOR_outFin/delete_me.tex" "$EDLREFOR_outFin/PES_paper/Balancing_tests_attrited.tex",        ///                                                          
				from("/BShline") to("/BScline{1-8}") replace  	 				
	
	
	
		
	
	
	
	
	

********************************************************************************
* SECTION B: Caractéristiques socio-démographique du participant  			   *
********************************************************************************


	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", clear
	
	

	
	
*******************************************************************************************
* SECTION C: ACTIVITES AGRICOLES ET NON-AGRICOLE DU MENAGE au cours des 12 derniers mois *
*******************************************************************************************


	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionC_construct.dta", clear	

	

	
	
	
	
	
	
	
********************************************************************************
* SECTION D: Sécurité Alimentaire des Ménages  								   *
********************************************************************************


	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
	
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3		
	
	
	tab 		treatment	
	
	
	* drop not found participants
	tab 		found_participant
	
	drop if 	found_participant == 2
	
	
	describe FoodExp LFoodExp HFIAS_score HFIA_cat_1  HFIA_cat_4 HDDS 
	

								
	* BALANCE TABLE WITH RITEST
	
	do "$EDLREFOR_do/Analysis/iebaltab_ri_MainOutcomes.do"
	
	filefilter  "$EDLREFOR_outFin/PES_paper/baltab_ri.tex" "$EDLREFOR_outFin/PES_paper/Food_Consumption_Indices_RITEST.tex",        ///                                                          
                 from("/BShline") to("/BScline{1-7}") replace  	
					
	
	
	
	
	* ------------------------------------------------------------------------ *			 
	
	* Balance Table of food consumption shares	

	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
	
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle) gen(serge1)
		keep if serge1==3	
		
	
		
	drop foodgroup*
	
	forvalues x=1/9  {
		gen foodgroup`x'=expfoodgroup`x'>0
		label variable foodgroup`x' "Consume foodgroup`x' (0/1)"
	}
	
	
	
	
	iebaltab 	foodgroup* expfoodgroup*, 	///
				grpvar(treatment) grplabels(1 Treatment @  0 Control)  order(1 0)	///
				/// vce(cluster a2_site)										///										
				total rowvarlabels pftest  										///
				tblnote("") 													///
				savetex("$EDLREFOR_outFin/delete_me.tex") 						///
				replace

	filefilter  "$EDLREFOR_outFin/delete_me.tex" "$EDLREFOR_outFin/PES_paper/Food_Consumption_shares.tex",        ///                                                          
                    from("/BShline") to("/BScline{1-8}") replace 
				
				
				
	keep if treatment==0			
	
	* HOUSEHOLD FOOD INSECURITY ACCESS SCALE
	global graph_opts_pie bgcolor(white) graphregion(color(white)) legend(region(lc(none) fc(none))) ///
					   title(, justification(left) color(black) span pos(11)) subtitle(, justification(left) color(black))		
		
	graph pie, over(HFIA_cat) legend(size(small) lpattern(blank)) 			 ///
				pie(_all, explode) 											 ///
				pie(1, color(edkblue)) 										 ///
				pie(2, color(eltgreen)) 									 ///
				pie(3, color(olive_teal)) 									 ///
				pie(4, color(erose)) 										  ///				
			    plabel(1 percent,  size(*1) gap(0)  format(%9.2fc) color(black))  ///
			    plabel(2 percent,  size(*1) gap(-5) format(%9.2fc) color(black))  ///
			    plabel(3 percent,  size(*1) gap(0)  format(%9.2fc) color(black))  ///
			    plabel(4 percent,  size(*1) gap(0)  format(%9.2fc) color(black))  ///
			 	plabel(1 name,     size(*1) gap(-8) format(%9.2fc) color(black))  	 ///
 			 	plabel(2 name,     size(*1) gap(10) format(%9.2fc) color(black))  	 ///
			 	plabel(3 name,     size(*1) gap(10) format(%9.2fc) color(black))  	 ///
			 	plabel(4 name,     size(*1) gap(10) format(%9.2fc) color(black)) 	///
				title("") legend (off) 	 ///
				$graph_opts_pie
				
	gr export	"$EDLREFOR_outFin/PES_paper/Food_Insecure_HFIApie.eps", replace	
	
		
	
				
			
	* ------------------------------------------------------------------------ *		
	* 
	
	

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
	iegraph treatment , basictitle("Food Insecure")   barlabel noconfbars ///
						yzero  ylabel(0(10)45 , labsize(small))   ytitle("Percentage", size(medium))  ///
						legend(order(1 2)  lab(1 "Non Participants")  lab(2 "PES Participants"))  ///
				graphregion(fcolor(white) ifcolor(white)) $graph_opts_pie  ///
				plotregion(fcolor(white) ifcolor(white)) scale(*1)	
		graph rename HFIAS_1, replace		
		
		
  	regress Food_Insecure2 treatment
	iegraph treatment , basictitle("Severely Food Insecure")   barlabel noconfbars ///
						yzero  ylabel(0(10)45 , labsize(small))   ytitle("Percentage", size(medium))  ///
						legend(order(1 2)  lab(1 "Non Participants")  lab(2 "PES Participants"))  ///
				graphregion(fcolor(white) ifcolor(white)) $graph_opts_pie  ///
				plotregion(fcolor(white) ifcolor(white)) scale(*1)	
		graph rename HFIAS_4, replace	
		
		
		
	* Outsheet both bar graphs	
	grc1leg HFIAS_1 HFIAS_4, title()  ///
			subtitle(, size(small)) ///
			legendfrom(HFIAS_1) graphregion(color(white))  ///
			note ("Note: Food security categories based on Household Food Insecurity Access Prevelance (HFIAP)" "Bars represent coefficient sizes estimated using OLS regressions", size(small))
	gr export	"$EDLREFOR_outFin/PES_paper/Food_Insecure_iegraph.eps",  replace	
	graph drop HFIAS_1 HFIAS_4		
				
	
			
			
				
				
				
				
				
			
	* ------------------------------------------------------------------------ *		
			
	
	* FOOD CONSUMPTION EXPENDITURE

	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
	
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3		
	
		

	
	* Distriubtion Food Consumption Expenditure
	
	* Set graph global option 
	global graph_opts1 bgcolor(white) graphregion(color(white)) legend(region(lc(none) fc(none))) ///
					   ylab(,angle(0)) title(, justification(left) color(black) span pos(11)) subtitle(, justification(left) color(black))		

	summ LFoodExp, detail
				mat b = r(mean)
				mat c = r(p50)
				local mean = b[1,1]
				local mean = round(`=`r(mean)'',0.1)
				local median = c[1,1]
				local median = round(`=`r(p50)'',0.1)	
				di "`mean', `median'"	
	
	twoway 		kdensity LFoodExp if statut==1, bwidth(0)   					||	   				///
				kdensity LFoodExp if statut==0, bwidth(0)  lpattern(dash)		||,	  				///
				xtitle("Food Expenditure (in FCFA)") 									///
				ytitle("Density") legend(order(1 "PES" 2 "non-PES"))			///
				xline(`r(mean)', lpattern(dash) lcolor(maroon))  xmlabel(`r(mean)' "Mean=`mean'",     labsize(vsmall) angle(0)) 	///	
				xline(`r(p50)' , lpattern(solid) lcolor(navy))   xmlabel(`r(p50)'  "Median=`median'", labsize(vsmall) angle(0)) ///
				$graph_opts1
	gr export 	"$EDLREFOR_outFin/PES_paper/kdensity_LOG_FoodConsExp.eps", replace		
		
	
	
	
	
	
	
	
	* ------------------------------------------------------------------------ *		
			
	
	* FOOD CONSUMPTION EXPENDITURE - Share spent on food groups

	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
	
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle) gen(serge1)
		keep if serge1==3		
	
		
	
	
	
	* Share of food expenditure spent on the various food groups - bar graph
	
	
	global graph_opts1 bgcolor(white) graphregion(color(white)) legend(region(lc(none) fc(none))) ///
					   ylab(,angle(0) nogrid) title(, justification(left) color(black) span pos(11)) ///
					   subtitle(, justification(left) color(black))	
	
	
	reshape long expshr_foodgroup, i(hhid) j(foodgroup)
	
	* label food groups
	label define foodgroups				1 	"Cereals and Tubers"     ///
										2 	"Pulses"    ///
										3 	"Vegetables"                          ///
										4 	"Fruit"                           ///
										5 	"Meat and fish"                ///
										6	"Milk"                ///
										7	"Oil"                           ///
										8	"Sugar"                            ///
										9	"Others" 
	
	
	label values foodgroup  foodgroups
	
	
	* br foodgroup treatment expshr_foodgroup
	
	
	
	graph bar expshr_foodgroup ///
						, over(treatment) asy bargap(20) over(foodgroup, sort(expshr_foodgroup) reverse lab(alternate labsize(small)))  nofill 									///
						blabel(bar, size(vsmall) format(%9.2f)) 														///
						$graph_opts1 bar(1 , lc(black) lw(thin) fi(100)) bar(2 , lc(black) lw(thin) fi(100)) 		///
						ytitle("Share of total expenditures (in %)", height(7)) 				
	gr export 	"$EDLREFOR_outFin/PES_paper/FoodConsExpShr_byfoodgroup.eps",  replace		
	
	
		
			
			
	* ------------------------------------------------------------------------ *		
						
	* FOOD EXPENDITURES STACKED BAR GRAPH	 

	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
	
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3		

						

	global graph_opts1 bgcolor(white) graphregion(color(white)) legend(region(lc(none) fc(none))) ///
					   ylab(,angle(0)) subtitle(, justification(left) color(black) span pos(11)) title(, color(black) span)
	
	
	graph bar expfoodgroup*, ///
			stack over(statut, desc) nofill										    ///
			ylab(0(5000)15000) 	 blabel(bar, position (center) format(%9.0f) size(tiny))	///												
			legend(order(1 "Cereals and Tubers" 2 "Pulses" 3 "Vegetables" 4 "Fruit"  5 "Meat and Fish"  6 "Milk" 7 "Oil" 8 "Sugar"  9 "Other") ///
			c(1) symxsize(small) symysize(small) pos(3) size(small)) ///				
			$graph_opts1  															///																						
			bar(1,lw(thin) lc(black) fcolor(edkblue*0.9))  			bar(2,lw(thin) lc(black)  fcolor(edkblue*0.8))  		///
			bar(3,lw(thin) lc(black) fcolor(edkblue*0.7))  			bar(4,lw(thin) lc(black)  fcolor(edkblue*0.6))		///
			bar(5,lw(thin) lc(black) fcolor(edkblue*0.5)) 			bar(6,lw(thin) lc(black)  fcolor(edkblue*0.4)) 		///  
			bar(7,lw(thin) lc(black) fcolor(edkblue*0.3))   		bar(8,lw(thin) lc(black)  fcolor(edkblue*0.2))		///  
			bar(9,lw(thin) lc(black) fcolor(edkblue*0.1))																																	
	gr export 	"$EDLREFOR_outFin/PES_paper/FoodConsExp_byfoodgroup_stack.eps",  replace		
						

						
						
						
	* ------------------------------------------------------------------------ *		
						
	* DIETARY DIVERSITY SCALE
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
	
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3		
			
	
	* Global with options
	global graph_opts_hdds bgcolor(white)  legend(region(lc(none) )) title(, color(black) span)
					    

	
	* Histogram
	preserve
	replace statut = 2		if statut == 0
	
	label def staut_fix 1 "PES" 2 "non-PES"
	label val statut staut_fix
	
	
	hist HDDS, by(statut, legend(off) bgcolor(white) graphregion(color(white)) graphregion(color(white)) note("") ) ///
							 subtitle(,  fcolor(white) lcolor(white)) 						///
							 percent addlabel  width(1) start(1)   ylab(,angle(0) )	///
							 addlabopts(yvarformat(%9.0f))  ylabel(0(10)40)   				///
							 ytitle("Share of the respondents (in %)")   					///
							 xtitle("HDDS") 									///									
							 lstyle(solid)  color(edkblue*0.9)
	gr export 	"$EDLREFOR_outFin/PES_paper/DiversiteAlimentaire.eps",  replace								
					
	restore			
	
	
		
		
		
		
				
				
				

	
	
	* ------------------------------------------------------------------------ *			 
	
	* Graph - Levels of Food Security
	
	* Transform and graph "food security levels"

	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
	
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle) gen(serge1)
		keep if serge1==3		
		
		keep if treatment==0
	
	
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
					   ylab(,angle(0) ) title(, justification(left) color(black) span pos(11)) subtitle(, justification(left) color(black))		
	
	
	
	graph bar year2018_, over(month, 	///
						 relabel(1 "Oct"  2 "Nov" 3 "Dec"  4 "Jan" 5 "Feb" 6	"Mar" 7	"Apr"   					///
								 8 "May"  9	"Jun"  10 "Jul" 	11  "Aug"  12  "Sept" ))							///
						 ytitle("Percent")										///
						 blabel(bar, format(%9.1f) lstyle(solid) lc(black) color(black) size(vsmall)) 	bargap(10) 			///
						 $graph_bar
	gr export "$EDLREFOR_outFin/PES_paper/FoodInsecure_bymonth_bars.eps",  replace	
	
	
			
		
		
		
		
* ------------------------------------------------------------------------------
*	COMPLIANCE ANALYSIS - PAIEMENTS RECEIVED
* ------------------------------------------------------------------------------
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", keepusing(rev_total_12mois Lrev_total_12mois W01_rev_total_12mois ///
																												rev_total_12mois b10 b11 sec_occup ///
																												b21 b22 W01_b22 W03_b22 W05_b22) gen(serge2)
		keep if serge2==3			
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", keepusing(b21 b22 W01_b22 W03_b22 W05_b22) gen(serge3)
		keep if serge3==3
		
		
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
						drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/final/actual paiement made_analysis.dta",  ///
				  keepusing (paiement_actual)
				  mvencode paiement_actual, mv(0) override
				  keep if treatment!=.
				  drop _merge
		
	
	
	graph bar b21,     			over(treatment)
	
	graph box b22,     			over(treatment)
	
	graph box W01_b22, 			over(treatment)
	
	graph box paiement_actual, 	over(treatment)    ///
					title("Compliance to the treatment assignment", size(large)) ///	
					ytitle("Paiement amounts (in FCFA)", size(medium))    ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*1) ///
						name(paimentgraph)		
	graph export "$EDLREFOR_outFin/PES_paper/paiementrecu.eps", replace
	graph drop paimentgraph							
	

		summ b22, detail
				mat b = r(mean)
				local mean_SR = b[1,1]
				local mean_SR = round(`=`r(mean)'',0.2)				
		summ paiement_actual, detail
				mat c = r(mean)
				local mean_actual = c[1,1]
				local mean_actual = round(`=`r(mean)'',0.2)	
						di "`mean_SR', `mean_actual'"	
						
						
						
	/* Exclude - Not in the paper					
		*graph drop paimentgraph							
		twoway	(kdensity b22 if treatment==1,  lcolor(blue) lwidth(medthick) xaxis(1 2)) ///
				(kdensity paiement_actual if treatment==1,  lcolor(red) lwidth(medthick) xaxis(1 2)), ///
					title("Compliance to the treatment assignment", size(large)) ///
					subtitle("Distribution of paiements received by treatment and control farmers", size(medium)) ///
					xlabel(, labsize(small) axis(1))  xlabel("", labsize(small) axis(2)) ///
					ylabel(, labsize(small)) legend(order(1 "Self-reported paiement received" 2 "Actual paiements transfers from monitoring data") row(2))			///
					xtitle("Montant (FCFA)", size(small)) 			///
					ytitle("Densite", size(medium))    ///
					/// xline(`mean_SR', lpattern(dash) lcolor(edkblue)) ///
					/// xmlabel(`r(mean)' "Moyenne = `mean_actual' FCFA", axis(2) labsize(vsmall) angle(0)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*1) ///
						name(paimentgraph)	
	 graph export "$EDLREFOR_outFin/PES_paper/paiement_recu.eps", replace

	*/
	
	
	
	
* ------------------------------------------------------------------------------
*	REGRESSION ANALYSIS - FOOD EXPENDITURES
* ------------------------------------------------------------------------------
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", keepusing(rev_total_12mois Lrev_total_12mois W01_rev_total_12mois ///
																												rev_total_12mois b10 b11 sec_occup ///
																												b21 b22 W01_b22 W03_b22 W05_b22) gen(serge2)
		keep if serge2==3			
		
	
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
						drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/final/actual paiement made_analysis.dta",  ///
				  keepusing (paiement_actual)
				  mvencode paiement_actual, mv(0) override		
		
	
	
	
	local covariates     "age female farmer lanholdings Lrevenu_tot sec_activity married hsize schooling GGF_member dist_far"
	
	local base_outcome 	 "FoodExp_base LFoodExp_base HDDS_base"
	
	lab var treatment "PES"
	
	
	gen FoodExp2  = FoodExp/hsize
	gen LFoodExp2 = log(FoodExp2)

	
	eststo clear
		
	foreach var in  FoodExp LFoodExp	{
		
	preserve
	
	gen 		   baseline_outcome = `var'_base
	
	lab var  	   baseline_outcome "Baseline outcome"
	
	reg `var' treatment  i.bloc i.parcelle
	eststo 	`var'_1
	estadd	local Controls		"No"
	estadd	local Bloc			"Yes"
	
	reg `var' treatment baseline_outcome  i.bloc i.parcelle
	eststo  `var'_2
	estadd	local Controls		"No"
	estadd	local Bloc			"Yes"		

	reg `var' treatment baseline_outcome  i.bloc i.parcelle `covariates'
	eststo  `var'_3
	estadd	local Controls		"Yes"
	estadd	local Bloc			"Yes"
	
	ttest `var', by(treatment)
		estadd scalar T_obs  = r(N_2)
		estadd scalar T_mean = r(mu_2)
		estadd scalar C_obs  = r(N_1)
		estadd scalar C_mean = r(mu_1)	
		
	if `var' == LFoodExp {
	
	esttab  ///
				using "$EDLREFOR_outFin/PES_paper/Food_exp_regression.tex", ///
				/// s(C_obs T_obs C_mean, fmt(0 0 1))  ///
				prehead("\begin{tabular}{l*{7}{c}} \hline\hline  \\ & \multicolumn{3}{c}{Food Expenditures} & \multicolumn{3}{c}{log(Food Expenditures)} \\  \cmidrule(lr){2-4} \cmidrule(lr){5-7} ") ///
				nomtitles drop(*bloc *parcelle `covariates')	star(* 0.10 ** 0.05 *** 0.01)  ///
				scalars("Controls Covariates included" "Bloc Bloc fixed effects" "C_mean Control mean") sfmt(0) ///
				addnotes("The baseline outcomes represent respectively the food expenditure and log-food expenditure at baseline."	///
						 "The covariates include age, gender, occupation, landholdings, revenue, size of the household," 			///
						 "education, distance to the reforestation site, and memnership of a forest membership group.")				///
				label r2 ar2 constant  																								///
				replace
	}
	restore
	
	}

	
	
	
	* IV ESTIMATION
	*FoodExp LFoodExp paiement_actual FoodExp_base LFoodExp_base revenu_tot Lrevenu_tot rev_total_12mois Lrev_total_12mois
	
	gen paiement_actual1=paiement_actual/100
	label variable paiement_actual1 "PES tranfers received (in 100 FCFA)"
	
	eststo clear
	
	foreach var in  FoodExp LFoodExp	{
	
	preserve
	
	gen 		   baseline_outcome = `var'_base
	
	lab var  	   baseline_outcome "Baseline outcome"
	
	ivregress 2sls `var' i.bloc i.parcelle  (paiement_actual1 = treatment)
	eststo 	`var'_1
	estadd	local Controls		"No"
	estadd	local Bloc			"Yes"
	
	ivregress 2sls `var' baseline_outcome i.bloc i.parcelle  (paiement_actual1 = treatment)
	eststo  `var'_2
	estadd	local Controls		"No"
	estadd	local Bloc			"Yes"		

	ivregress 2sls `var' baseline_outcome i.bloc i.parcelle `covariates' (paiement_actual1 = treatment)
	eststo  `var'_3
	estadd	local Controls		"Yes"
	estadd	local Bloc			"Yes"
	
	ttest `var', by(treatment)
		estadd scalar T_obs  = r(N_2)
		estadd scalar T_mean = r(mu_2)
		estadd scalar C_obs  = r(N_1)
		estadd scalar C_mean = r(mu_1)	
		
	if `var' == LFoodExp {
	
	esttab  ///
				using "$EDLREFOR_outFin/PES_paper/Food_exp_IVregression.tex", ///
				/// s(C_obs T_obs C_mean, fmt(0 0 1))  ///
				prehead("\begin{tabular}{l*{7}{c}} \hline\hline  \\ & \multicolumn{3}{c}{Food Expenditures} & \multicolumn{3}{c}{log(Food Expenditures)} \\  \cmidrule(lr){2-4} \cmidrule(lr){5-7} ") ///
				nomtitles drop(*bloc *parcelle `covariates')	star(* 0.10 ** 0.05 *** 0.01)  ///
				scalars("Controls Covariates included" "Bloc Bloc fixed effects" "C_mean Control mean") sfmt(0) ///
				addnotes("The baseline outcomes represent respectively the food expenditure and log-food expenditure at baseline."	///
						 "The covariates include age, gender, occupation, landholdings, revenue, size of the household," 			///
						 "education, distance to the reforestation site, and memnership of a forest membership group.")				///
				label r2 ar2 constant  																								///
				replace
	}
	restore
	
	}
	
	
	/* MV Tobit estimation
		
	eststo clear
		
	foreach var in  FoodExp LFoodExp	{
		
	preserve
		
	gen 		   baseline_outcome = `var'_base
	lab var  	   baseline_outcome "Baseline outcome"
	
    * constraint define 1 [y1]x11 = [y2]x22

    mvtobit (expfoodgroup1 = treatment    `covariates') ///
			(expfoodgroup2 = treatment    `covariates') ///
			(expfoodgroup3 = treatment    `covariates') ///
			(expfoodgroup4 = treatment    `covariates') ///
			(expfoodgroup5 = treatment    `covariates') ///
			(expfoodgroup6 = treatment    `covariates') ///
			(expfoodgroup7 = treatment    `covariates') ///
			(expfoodgroup8 = treatment    `covariates') ///
			(expfoodgroup9 = treatment    `covariates'), ///
			dr(20)  adoonly
			an 
			*constraints(1)	
	
	esttab  ///
				using "$EDLREFOR_outFin/PES_paper/mvtobit_Food_exp_regression.tex", ///
				/// s(C_obs T_obs C_mean, fmt(0 0 1))  ///
				prehead("\begin{tabular}{l*{7}{c}} \hline\hline  \\ & \multicolumn{3}{c}{Food Expenditures} & \multicolumn{3}{c}{log(Food Expenditures)} \\  \cmidrule(lr){2-4} \cmidrule(lr){5-7} ") ///
				nomtitles drop(*bloc *parcelle `covariates')	star(* 0.10 ** 0.05 *** 0.01)  ///
				scalars("Controls Covariates included" "Bloc Bloc fixed effects" "C_mean Control mean") sfmt(0) ///
				addnotes("The baseline outcomes represent respectively the food expenditure and log-food expenditure at baseline."	///
						 "The covariates include age, gender, occupation, landholdings, revenue, size of the household," 			///
						 "education, distance to the reforestation site, and memnership of a forest membership group.")				///
				label r2 ar2 constant  																								///
				replace
	}
	restore
	
	}	
	*/

	* Engel curves ESTIMATION
	*FoodExp LFoodExp paiement_actual FoodExp_base LFoodExp_base revenu_tot Lrevenu_tot rev_total_12mois Lrev_total_12mois
	
	drop  paiement_actual1
	
	gen paiement_actual1=paiement_actual/100
	label variable paiement_actual1 "PES tranfers received (in 100 FCFA)"
	
	gen L2FoodExp=asinh(FoodExp)
	label variable L2FoodExp "IHS tranformed Household Total Food Concumption Expenditures"
	
	
	
	
	
	eststo clear

	foreach var in  expfoodgroup1 expfoodgroup2 expfoodgroup3 expfoodgroup4 expfoodgroup5 expfoodgroup6 expfoodgroup7 expfoodgroup8 expfoodgroup9	{
	
	preserve
	gen L`var'=asinh(`var')
	
	ivregress 2sls L`var' i.bloc i.parcelle `covariates' (L2FoodExp = treatment)
	eststo  `var'_1
	estadd	local Controls		"Yes"
	estadd	local Bloc			"Yes"	
	
	ttest `var', by(treatment)
		estadd scalar T_obs  = r(N_2)
		estadd scalar T_mean = r(mu_2)
		estadd scalar C_obs  = r(N_1)
		estadd scalar C_mean = r(mu_1)	
		
	restore
	}	
	esttab  ///
				using "$EDLREFOR_outFin/PES_paper/Foodgroup_exp_IVregression.tex", ///
				/// s(C_obs T_obs C_mean, fmt(0 0 1))  ///
				/// prehead("\begin{tabular}{l*{7}{c}} \hline\hline  \\ & \multicolumn{3}{c}{Food Expenditures} & \multicolumn{3}{c}{log(Food Expenditures)} \\  \cmidrule(lr){2-4} \cmidrule(lr){5-7} ") ///
				nomtitles drop(*bloc *parcelle `covariates')	star(* 0.10 ** 0.05 *** 0.01)  ///
				scalars("Controls Covariates included" "Bloc Bloc fixed effects" "C_mean Control mean") sfmt(0) ///
				addnotes("The covariates include age, gender, occupation, landholdings, revenue, size of the household," 			///
						 "education, distance to the reforestation site, and memnership of a forest membership group.")				///
				label r2 ar2 constant  																								///
				replace
	
	
	
	
	
* ------------------------------------------------------------------------------
*	REGRESSION ANALYSIS - Household Dietary Diversity Score (HDDS) 
* ------------------------------------------------------------------------------
	
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", keepusing(rev_total_12mois Lrev_total_12mois W01_rev_total_12mois ///
																												rev_total_12mois b10 b11 sec_occup ///
																												b21 b22 W01_b22 W03_b22 W05_b22) gen(serge2)
		keep if serge2==3			
		
	
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
						drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/final/actual paiement made_analysis.dta",  ///
				  keepusing (paiement_actual)
				  mvencode paiement_actual, mv(0) override
					gen paiement_actual1=paiement_actual/100
					label variable paiement_actual1 "PES tranfers received (in 100 FCFA)"		
					
	
	
	local covariates     "age female farmer lanholdings Lrevenu_tot sec_activity married hsize schooling GGF_member dist_far"
	
	local base_outcome 	 "FoodExp_base LFoodExp_base HDDS_base"
	
	label var treatment "PES"
	
	
	
	eststo clear
	
	
	foreach var in  HDDS	{
	
	preserve
	
	gen 		   baseline_outcome = `var'_base
	
	label variable baseline_outcome  "HDDS at baseline"
	
	reg `var' treatment  i.bloc i.parcelle
	eststo 	`var'_1
	estadd	local Controls		"No"
	estadd	local Bloc			"Yes"
	estadd	local estimation	"OLS"
	
	
	reg `var' treatment baseline_outcome  i.bloc i.parcelle
	eststo  `var'_2
	estadd	local Controls		"No"
	estadd	local Bloc			"Yes"		
	estadd	local estimation	"OLS"

	reg `var' treatment baseline_outcome  i.bloc i.parcelle `covariates'
	eststo  `var'_3
	estadd	local Controls		"Yes"
	estadd	local Bloc			"Yes"
	estadd	local estimation	"OLS"

	ivregress 2sls `var' baseline_outcome i.bloc i.parcelle `covariates' (paiement_actual1 = treatment)
	eststo  `var'_4
	estadd	local Controls		"Yes"
	estadd	local Bloc			"Yes"	
	estadd	local estimation	"IV"
	
	ttest `var', by(treatment)
		estadd scalar T_obs  = r(N_2)
		estadd scalar T_mean = r(mu_2)
		estadd scalar C_obs  = r(N_1)
		estadd scalar C_mean = r(mu_1)		
	
	esttab  ///
				using "$EDLREFOR_outFin/PES_paper/HDDS_RegResults.tex", 		///	
				/// s(C_obs T_obs C_mean, fmt(0 0 1))  ///
				/// prehead("\begin{tabular}{l*{7}{c}} \hline\hline  \\ & \multicolumn{3}{c}{Food Expenditures} & \multicolumn{3}{c}{log(Food Expenditures)} \\  \cmidrule(lr){2-4} \cmidrule(lr){5-7} ") ///
				nomtitles drop(*bloc *parcelle `covariates')	star(* 0.10 ** 0.05 *** 0.01)  ///
				scalars("Controls Covariates included" "Bloc Bloc fixed effects" "estimation Estimation approach" "C_mean Control mean") sfmt(0) ///
				addnotes("The covariates include age, gender, occupation, landholdings, revenue, size of the household," 		///
						 "education, distance to the reforestation site, and membership of a forest membership group.")		///
				label r2 ar2 constant  											///
				replace

	restore
	
	}
	
	
	
					

	
	
	
* ------------------------------------------------------------------------------
*	REGRESSION ANALYSIS - HFIAS 
* ------------------------------------------------------------------------------
	
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", keepusing(rev_total_12mois Lrev_total_12mois W01_rev_total_12mois ///
																												rev_total_12mois b10 b11 sec_occup ///
																												b21 b22 W01_b22 W03_b22 W05_b22) gen(serge2)
		keep if serge2==3			
		
	
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
						drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/final/actual paiement made_analysis.dta",  ///
				  keepusing (paiement_actual)
				  mvencode paiement_actual, mv(0) override		
		
		
	
	local covariates     "age female farmer lanholdings Lrevenu_tot sec_activity married hsize schooling GGF_member dist_far"
	
	
	lab var treatment "PES"
	
	
	eststo clear
		

	foreach lhsVar of varlist HFIAS_score HFIA_cat_1 HFIA_cat_4   {
		
	
	
		reg `lhsVar' treatment  i.bloc i.parcelle
		eststo
		eststo dir
		estadd	local Controls		"No"
		estadd	local Bloc			"Yes"

		reg `lhsVar' treatment  i.bloc i.parcelle `covariates'
		eststo
		estadd	local Controls		"Yes"
		estadd	local Bloc			"Yes"

		ttest `lhsVar', by(treatment)
		estadd scalar T_obs  = r(N_2)
		estadd scalar T_mean = r(mu_2)
		estadd scalar C_obs  = r(N_1)
		estadd scalar C_mean = r(mu_1)	
		
		
	esttab  ///
				using "$EDLREFOR_outFin/PES_paper/HFIAS.tex", ///	
				prehead("\begin{tabular}{l*{6}{c}} \hline\hline  \\ & \multicolumn{2}{c}{Overall Scale \in [0,4]} & \multicolumn{2}{c}{Being food secure(0/1)} & \multicolumn{2}{c}{Being severely food insecure(0/1)}\\  \cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} ") ///
				nomtitles drop(*bloc *parcelle `covariates')	star(* 0.10 ** 0.05 *** 0.01)  ///
				scalars("Controls Covariates included" "Bloc Bloc fixed effects" "C_mean Control mean") sfmt(3) ///
				addnotes("The control covariates include age, gender, occupation, landholdings, revenue, size of the household, education," 		///
						 "distance to the reforestation site, and memnership of a forest membership group.")					///
				label r2 ar2 constant  											///
				replace
		
	}

	
	
	
	
	
		
	
	
	
	
	
	
	
	
	
	
* ------------------------------------------------------------------------------
*	REGRESSION ANALYSIS - Household Hunger Scale Regressions 
* ------------------------------------------------------------------------------
	
	
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", keepusing(rev_total_12mois Lrev_total_12mois W01_rev_total_12mois ///
																												rev_total_12mois b10 b11 sec_occup ///
																												b21 b22 W01_b22 W03_b22 W05_b22) gen(serge2)
		keep if serge2==3			
		
	
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
						drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/final/actual paiement made_analysis.dta",  ///
				  keepusing (paiement_actual)
				  mvencode paiement_actual, mv(0) override	
		
	
	lab var HHS  		"HHS"
	lab var HHScat1		"HHS (no hunger)"
	lab var HHScat2		"HHS (moderate hunger)"
	
	
	
	local covariates     "age female farmer lanholdings Lrevenu_tot sec_activity married hsize schooling GGF_member dist_far"
	
	local base_outcome 	 "FoodExp_base LFoodExp_base HDDS_base"
	
	lab var treatment "PES"
	
	eststo clear

	foreach lhsVar of varlist  HHS HHScat1 HHScat2  {
		
	
	
		reg `lhsVar' treatment  i.bloc i.parcelle
		eststo
		eststo dir
		estadd	local Controls		"No"
		estadd	local Bloc			"Yes"

		reg `lhsVar' treatment  i.bloc i.parcelle `covariates'
		eststo
		estadd	local Controls		"Yes"
		estadd	local Bloc			"Yes"

		
		esttab  ///
				using "$EDLREFOR_outFin/PES_paper/HHS_regressions.tex", ///	
				prehead("\begin{tabular}{l*{6}{c}} \hline\hline  \\ & \multicolumn{2}{c}{Scale \in [0,3]} & \multicolumn{2}{c}{Scale = 1 (no hunger)} & \multicolumn{2}{c}{Scale = 2 (moderate hunger)}\\  \cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} ") ///
				nomtitles drop(*bloc *parcelle `covariates' )	  ///
				scalars("Controls Controls " "Bloc Bloc fixed effects") ///
				addnotes("The control covariates include age, gender, occupation, landholdings, revenue, size of the household, education," 		///
						 "distance to the reforestation site, and memnership of a forest membership group.")									    ///
				label r2 ar2 constant  											///
				replace
	}

	
	
	
	
	
	
		
	* For Robustness checks
	preserve


	global graph_rob bgcolor(white) graphregion(color(white)) legend(region(lc(none) fc(none))) ///
					   xlab(-0.8(0.4)0.8) ylab(,angle(0) nogrid labsize(vsmall)) title(, justification(left) color(black) span pos(11)) subtitle(, justification(left) color(black))		
	
	* Ben's approach (Bonferroni)
	forest reg FoodExp LFoodExp HFIAS_score HFIA_cat_1 ///
			HFIA_cat_4 HHS HHScat1 HDDS = treatment,  ///
			controls(i.bloc i.parcelle) d bonferroni  ///
					graphopts($graph_rob)
					
	gr export "$EDLREFOR_outFin/PES_paper/robustness_forest.eps",  replace	

	

	* Kling & Liebman approach
		replace FoodExp=-FoodExp
		replace LFoodExp=-LFoodExp
		replace HFIA_cat_1=1-HFIA_cat_1
		replace HHScat1=1-HHScat1
	avg_effect FoodExp LFoodExp HFIAS_score HFIA_cat_1 ///
			HFIA_cat_4 HHS HHScat1 HDDS, x(treatment) effectvar(treatment) controltest(treatment==0)
			
			
	* Anderson's approach	
	
	restore		

	
	
********************************************************************************
*  Heterogenous Treatment Effects
********************************************************************************
	
	/* Not included in paper yet
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", keepusing(rev_total_12mois Lrev_total_12mois W01_rev_total_12mois ///
																												rev_total_12mois b10 b11 sec_occup ///
																												b21 b22 W01_b22 W03_b22 W05_b22) gen(serge2)
		keep if serge2==3			
		
	
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
						drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/final/actual paiement made_analysis.dta",  ///
				  keepusing (paiement_actual)
				  mvencode paiement_actual, mv(0) override
				  
		
		
	
	* drop not found participants
	tab 		found_participant, mis
	
	drop if 	found_participant == 2 | found_participant == .
	
		
	local covariates     "age female farmer lanholdings Lrevenu_tot sec_activity married hsize schooling GGF_member dist_far"
	
	local base_outcome 	 "FoodExp_base LFoodExp_base HDDS_base"	
	
	
	
	* Distribution of Food Expenditures
	
	summ  FoodExp, detail
	qplot FoodExp, over(treatment) recast(line) ytitle("Food expenditure (last 7 days)") title("Sample: N = `r(N)'")	///
				    xlab(0(0.1)1) xline(0.5) xline(0.1) xline(0.9)
	graph export "$EDLREFOR_outFin/PES_paper/qreg_FoodExp.eps", replace
	
	*/
	
	
	
	
	/* ------------------------------------------------------------------------ *
	
	* 1.) Quantile Regression - with CONTROLS
	local   covariates     "age female farmer lanholdings Lrevenu_tot sec_activity married hsize schooling GGF_member dist_far"
	lab var statut 		   "PES"

	eststo clear
	
	foreach q in 0.1 0.25 0.5 0.75 0.9 {
	eststo, ti("Q(`q')"): qui qreg FoodExp statut i.bloc i.parcelle `covariates', q(`q') nolog
	
	estadd	local Controls		"Yes"
	estadd	local Bloc			"Yes"

	
	}
		
	esttab using "$EDLREFOR_outFin/PES_paper/qreg_FoodExp.tex", 			///
				keep(statut) 	 mti	star(* 0.10 ** 0.05 *** 0.01)  							///
				scalars("Controls Controls " "Bloc Bloc fixed effects") ///
				addnotes("")				///
				label constant  																								///
				replace
			   										
	
	* 2.) Quantile Regression - WITHOUT CONTROLS
	local   covariates     "age female farmer lanholdings Lrevenu_tot sec_activity married hsize schooling GGF_member dist_far"
	lab var statut 		   "PES"

	eststo clear
	
	foreach q in 0.1 0.25 0.5 0.75 0.9 {
	eststo, ti("Q(`q')"): qui qreg FoodExp statut i.bloc i.parcelle, q(`q') nolog
	
	estadd	local Controls		"No"
	estadd	local Bloc			"Yes"

	
	}
		
	esttab using "$EDLREFOR_outFin/PES_paper/qreg_FoodExp_nocontrols.tex", 			///
				keep(statut) 	 mti	star(* 0.10 ** 0.05 *** 0.01)  							///
				scalars("Controls Controls " "Bloc Bloc fixed effects") ///
				addnotes("")				///
				label constant  																								///
				replace
			   										
	
	
	*/
	
********************************************************************************
*  Subgroup Analysis
********************************************************************************


	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3	
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", keepusing(rev_total_12mois Lrev_total_12mois W01_rev_total_12mois ///
																												rev_total_12mois b10 b11 sec_occup ///
																												b21 b22 W01_b22 W03_b22 W05_b22) gen(serge2)
		keep if serge2==3			
		
	
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
						drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/final/actual paiement made_analysis.dta",  ///
				  keepusing (paiement_actual)
				  mvencode paiement_actual, mv(0) override
				  
		
		
	
	* drop not found participants
	tab 		found_participant, mis
	
	drop if 	found_participant == 2 | found_participant == .
	
		
	local covariates     "age female farmer lanholdings Lrevenu_tot sec_activity married hsize schooling GGF_member dist_far"
	
	local base_outcome 	 "FoodExp_base LFoodExp_base HDDS_base"	
	
	summ lanholdings, detail
	
	gen 	rich = 0		if lanholdings < 5 
	replace rich = 1  		if lanholdings >= 5
	
	tab 	rich 
	
	
	bys rich: qreg  LFoodExp statut, q(.50) nolog
	
	grqreg, cons ci ols olsci reps(40)
	
	

	

	sqreg FoodExp statut `covariates', q(0.1 .25 .5 .75 0.9)

	test   [q25]statut = [q75]statut

	lincom [q75]statut-[q25]statut




	/*

	CODES FROM PAUL

	************************

	foreach var in  FoodExp LFoodExp	{
		
		preserve
		
		gen 		   baseline_outcome = `var'_base
		
		lab var  	   baseline_outcome "Baseline outcome"
		
		reg `var' treatment  i.bloc i.parcelle
		eststo 	`var'_1
		estadd	local Controls		"No"
		estadd	local Bloc			"Yes"
		ttest `X', by(treatment)
			estadd scalar T_obs = r(N_2)
			estadd scalar T_mean = r(mu_2)
			estadd scalar C_obs = r(N_1)
			estadd scalar C_mean = r(mu_1)	
		
		
		reg `var' treatment baseline_outcome  i.bloc i.parcelle
		eststo  `var'_2
		estadd	local Controls		"No"
		estadd	local Bloc			"Yes"		

		reg `var' treatment baseline_outcome  i.bloc i.parcelle `covariates'
		eststo  `var'_3
		estadd	local Controls		"Yes"
		estadd	local Bloc			"Yes"
		
		
		if `var' == LFoodExp {
		
		esttab  ///
					using "$EDLREFOR_outFin/PES_paper/Food_exp_regression.tex", ///
					s(C_obs T_obs C_mean, fmt(0 0 1))  ///
					prehead("\begin{tabular}{l*{7}{c}} \hline\hline  \\ & \multicolumn{3}{c}{Food Expenditures} & \multicolumn{3}{c}{log(Food Expenditures)} \\  \cmidrule(lr){2-4} \cmidrule(lr){5-7} ") ///
					nomtitles drop(*bloc *parcelle `covariates')	star(* 0.10 ** 0.05 *** 0.01)  ///
					scalars("Controls Controls " "Bloc Bloc fixed effects") ///
					addnotes("The baseline outcomes represent respectively the food expenditure and log-food expenditure at baseline."	///
							 "The covariates include age, gender, occupation, landholdings, revenue, size of the household," 			///
							 "education, distance to the reforestation site, and memnership of a forest membership group.")				///
					label r2 ar2 constant  																								///
					replace
		}
		restore
		
		}


		estimates drop _all

	local moduleA "FoodExp LFoodExp"
	foreach X of local moduleA {

		preserve
		gen 		   baseline_outcome = `X'_base
		lab var  	   baseline_outcome "Baseline outcome"
		
	eststo `X': areg `X' treatment i.parcelle, absorb(bloc) vce(robust)
		*lincom Treatment+TreatXAft
			*estadd scalar coeff = r(estimate)
			*local t = r(estimate)/r(se)
			*estadd scalar pval = tprob(r(df), abs(`t'))
		ttest `X', by(treatment)
			estadd scalar T_obs = r(N_2)
			estadd scalar T_mean = r(mu_2)
			estadd scalar C_obs = r(N_1)
			estadd scalar C_mean = r(mu_1)
		restore
			}
			
		*xml_tab *, below stats(C_obs T_obs C_mean coeff pval)  sheet(corr) drop(_cons) lines(COL_NAMES 2 treated 2 EST_NAMES 2 LAST_ROW 13) cwidth(0 120) font("Calibri" 11) save("expenses1.xml")		
		esttab _all using "$EDLREFOR_outFin/PES_paper/DELETE_regression.tex", b(3) se(3) s(C_obs T_obs C_mean coeff pval, fmt(0 0 3 3 2)) replace     ///
				label booktabs                      ///
				page(dcolumn)                       ///
				alignment(D{.}{.}{-1})              ///
				starlevels(\sym{*} 0.10 \sym{**} 0.05 \sym{***} 0.01)
				
		esttab  _all ///
					using "$EDLREFOR_outFin/PES_paper/DELETE_regression.tex", ///
					s(C_obs T_obs C_mean coeff pval, fmt(0 0 3 3 2)) ///
					prehead("\begin{tabular}{l*{7}{c}} \hline\hline  \\ & \multicolumn{3}{c}{Food Expenditures} & \multicolumn{3}{c}{log(Food Expenditures)} \\  \cmidrule(lr){2-4} \cmidrule(lr){5-7} ") ///
					/// nomtitles drop(*bloc *parcelle `covariates')	///
					star(* 0.10 ** 0.05 *** 0.01)  ///
					/// scalars("Controls Controls " "Bloc Bloc fixed effects") ///
					addnotes("The baseline outcomes represent respectively the food expenditure and log-food expenditure at baseline."	///
							 "The covariates include age, gender, occupation, landholdings, revenue, size of the household," 			///
							 "education, distance to the reforestation site, and memnership of a forest membership group.")				///
					label r2 ar2 constant  																								///
					replace			
		
	estimates drop _all




	*/



	
	
	
	
	
	
	
	
********************************************************************************
* SECTION E: CAPITAL SOCIAL - CONFIANCE AUX INSTITUTIONS LOCALES   	   		   *
********************************************************************************


	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_construct.dta", clear	
	
	
	
	
	





	
********************************************************************************
* SECTION F: PERCEPTION DE LA VALEUR ENVIRONNEMENTALE ET PREFERENCES 	   	   *
********************************************************************************

	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionF_construct.dta", clear	
	
	
	
	
	
	
	
	
	
	
	
	
		
********************************************************************************
* SECTION G: PREFERENCES PAR RAPPORT AU RISQUE 	   	   						   *
********************************************************************************
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionG_construct.dta", clear	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
********************************************************************************
********************************************************************************
********************************************************************************

	
		
	
	
	
	
	
	
	
	
	
	
	
	
	
