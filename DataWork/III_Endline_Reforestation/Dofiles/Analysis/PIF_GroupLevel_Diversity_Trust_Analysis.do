/* *************************************************************************** *
* **************************************************************************** *
*                                                                      	       *
*         	PIF Burkina Faso		  					   			   		   *
*		  	Analysis: Social Cohesion 					   			   		   *
*																	   		   *
* **************************************************************************** *
* **************************************************************************** *


** WRITTEN BY: Jonas Guthoff (jguthoff@worldbank.org)
** CREATED: 22/02/2019

	** OUTLINE:		
											 
					1. Group Composition and effects on productivity
					
					2. Effort evaluation (in general and conditional on ethnicity)	
											
					4. Trust and the effect on productivity
				

				
				
		
	** Requires:  	To Run Project_MasterDofile.do to set the globals
						   
				    for each Section it pulls data constructed from the PIF_Endline_Construct.do		   
	
	
	
	
	** Unique identifier: hhid
	

* **************************************************************************** *
* **************************************************************************** */



	
* ------------------------------------------------------------------------------
* 1.) Descriptives on Group Composition 
* ------------------------------------------------------------------------------	

	
	* load the whole data set
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", clear	
	

	
	* Tabulate and outsheet the different ethnicities -> only for treatment & found
	eststo clear
	estpost tabulate  b7	if statut == 1 & found_participant == 1, sort
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/Ethnicities.tex", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") 		/// 
													 varlabels(, blist( "{hline @width}{break}"))     		   ///
													 nonumber nomtitle noobs replace
	
	
	
	
	
	tab 	found_participant if statut == 1 
	
	* ------------------------------------------------------------------------ *

	
	* load group level data -> number of different ethnicities on group level
	use "$EDLREFOR_dt/Intermediate/Constructed/Ethnic_Comp_GroupLevel.dta", clear


	tab		num_ethnicities
	
	* Outsheet the distribution of ethnicites for the treatment sample
	eststo clear
	estpost tabulate num_ethnicities, sort
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/Ethnicities_GroupLevel.tex", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") 		/// 
																varlabels(, blist( "{hline @width}{break}"))     		   ///
																nonumber nomtitle noobs replace
	
	
		
	* Outsheet group total distribution
	eststo clear
	estpost tabulate group_total, sort
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/Group_total.tex", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") 		/// 
																varlabels(, blist( "{hline @width}{break}"))     		   ///
																nonumber nomtitle noobs replace
	

	
	* Group Diversity score
	preserve
	duplicates drop group_id, force
	kdensity  div_score,   bwidth(0.1)  title("Group diversity score" "(# of ethnicites / # of members)")
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Group_diversity_kdens.eps" ,replace
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Group_diversity_kdens.pdf" ,replace
	restore	
	
		
		




* ---------------------------------------------------------------------------- *	
* Regressions -  Survival on Number of ethnicities with a group 
* ---------------------------------------------------------------------------- *
	
	
	* load group level data -> number of different ethnicities on group level
	use "$EDLREFOR_dt/Intermediate/Constructed/Ethnic_Comp_GroupLevel.dta", clear
	
	   
	
	rename  a1_region		region
	rename  a2_site			site
	rename  a4_bloc			bloc
	rename  a5_parcelle		parcelle

	* Merge the treatment status
	merge m:m region site bloc parcelle using "$EDLREFOR_dt/Intermediate/treatmet_status.dta", gen(Treat_merge) keep(3)

	
	* Merge tree survival data (VIVANT 1) - on group level
	merge m:m region site bloc parcelle using "$EDLREFOR_dtInt/Constructed/SurvivalRates_GroupLevel_vivant1.dta", gen(Merge_Survival) keep(3)
	
	
	* Merge tree survival data (VIVANT 2) - on group level
	merge m:m region site bloc parcelle using "$EDLREFOR_dtInt/Constructed/SurvivalRates_GroupLevel_vivant2.dta", gen(Merge_Survival2) keep(3)
	
	
	* Merge the group interaction means
	merge 1:1 group_id using "$EDLREFOR_dt/Intermediate/Constructed/GroupInteraction_GroupLevel.dta", keep(3)
	
	 
		
	* Regress categorical "Number of ethnicities" on Tree Survival Rates on Group level
	eststo clear	
	eststo:	reg vivant1  i.num_ethnicities
	estadd  local bloc "No"		
	eststo:	areg vivant1 i.num_ethnicities, absorb(bloc) 
	estadd  local bloc "Yes"	
	eststo:	areg vivant1 i.num_ethnicities median_b28, absorb(bloc) 
	estadd  local bloc "Yes"	
	eststo:	areg vivant1 i.num_ethnicities median_b28 treatment, absorb(bloc) 
	estadd  local bloc "Yes"	
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/GroupEthnic_vivant1_regression.tex", label r2 ar2 se star(* 0.10 ** 0.05 *** 0.01) replace	nobaselevels	///
		style(tex)  mtitle("Vivant 1" "Vivant 1" "Vivant 1" "Vivant 1")  																							///
		addnotes("")	///
		scalar("bloc Bloc fixed effects.")	
	
		
	* Vivant 2
	eststo clear	
	eststo:	reg vivant2  i.num_ethnicities
	estadd  local bloc "No"		
	eststo:	areg vivant2 i.num_ethnicities, absorb(bloc) 
	estadd  local bloc "Yes"	
	eststo:	areg vivant2 i.num_ethnicities median_b28, absorb(bloc) 
	estadd  local bloc "Yes"	
	eststo:	areg vivant2 i.num_ethnicities median_b28 treatment, absorb(bloc) 
	estadd  local bloc "Yes"	
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/GroupEthnic_vivant2_regression.tex", label r2 ar2 se star(* 0.10 ** 0.05 *** 0.01) replace	nobaselevels	///
		style(tex)  mtitle("Vivant 2" "Vivant 2" "Vivant 2" "Vivant 2")  																							///
		addnotes("")	///
		scalar("bloc Bloc fixed effects.")	
	
			
	
	
	* Graph: Productivity - Ethiniciy - VIVANT 1
	summ	num_ethnicities, detail
	twoway lpoly vivant1 num_ethnicities, bwidth(1)	,  	///            
			     title("Productivity by group heterogeneity - Vivant 1") subtitle("(N = `r(N)')")	ytitle("Tree survival rate (vivant 1)")		/// 
				 xtitle("Number of different ethnicities in the group")       		///
				 graphregion(fcolor(white) ifcolor(white)) 							///
				 plotregion(fcolor(white) ifcolor(white)) scale(*1)			  			
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Productivity_GroupComp_vivant1.pdf", replace
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Productivity_GroupComp_vivant1.eps", replace

	
	summ	num_ethnicities, detail	
	lpoly vivant1 num_ethnicities, ci  	           	  	///
			     title("Productivity by group heterogeneity - Vivant 1") subtitle("(N = `r(N)')")	ytitle("Tree survival rate (vivant 1)")		/// 
				 xtitle("Number of different ethnicities in the group")       		///
				 graphregion(fcolor(white) ifcolor(white)) 							///
				 plotregion(fcolor(white) ifcolor(white)) scale(*1)			  			
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Productivity_GroupComp_vivant1_CI.pdf", replace
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Productivity_GroupComp_vivant1_CI.eps", replace
	  
	  
	  
	  
	  
	
	* Graph: Productivity - Ethiniciy - VIVANT 2
	summ	num_ethnicities, detail
	twoway lpoly vivant2 num_ethnicities, bwidth(1) ,  	///            
			     title("Productivity by group heterogeneity - Vivant 2") subtitle("(N = `r(N)')")	ytitle("Tree survival rate (vivant 2)")		/// 
				 xtitle("Number of different ethnicities in the group")       		///
				 graphregion(fcolor(white) ifcolor(white)) 							///
				 plotregion(fcolor(white) ifcolor(white)) scale(*1)			  		
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Productivity_GroupComp_vivant2.pdf", replace
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Productivity_GroupComp_vivant2.eps", replace
		  
		  
		  
	summ	num_ethnicities, detail	
	lpoly vivant2 num_ethnicities, ci  	           	  	///
			     title("Productivity by group heterogeneity - Vivant 2") subtitle("(N = `r(N)')")	ytitle("Tree survival rate (vivant 2)")		/// 
				 xtitle("Number of different ethnicities in the group")       		///
				 graphregion(fcolor(white) ifcolor(white)) 							///
				 plotregion(fcolor(white) ifcolor(white)) scale(*1)			  			
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Productivity_GroupComp_vivant2_CI.pdf", replace
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Productivity_GroupComp_vivant2_CI.eps", replace
	  
	  
			
		
		
	* ------------------------------------------------------------------------ *	  
		
		
	* Bar Graph	
		  
	summ num_ethnicities, detail
	graph bar vivant1 if inlist(num_ethnicities,1,2,3,4), over(num_ethnicities) blabel(total)	///
			     title("Productivity by group heterogeneity - Vivant 1") subtitle("(N = `r(N)')")	ytitle("Tree survival rate (vivant 1)")		/// 
				 graphregion(fcolor(white) ifcolor(white)) 							///
				 plotregion(fcolor(white) ifcolor(white)) scale(*1)			  		
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Bargraph_GroupComp_vivant1.pdf", replace
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Bargraph_GroupComp_vivant1.eps", replace
	
	
	
		
	
	summ num_ethnicities, detail
	graph bar vivant2 if inlist(num_ethnicities,1,2,3,4), over(num_ethnicities) blabel(total)	///
			     title("Productivity by group heterogeneity - Vivant 2") subtitle("(N = `r(N)')")	ytitle("Tree survival rate (vivant 2)")		/// 
				 graphregion(fcolor(white) ifcolor(white)) 							///
				 plotregion(fcolor(white) ifcolor(white)) scale(*1)			  		
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Bargraph_GroupComp_vivant2.pdf", replace
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Bargraph_GroupComp_vivant2.eps", replace
	
		
		
		
		
		

	
	
* ------------------------------------------------------------------------------
* 2.) Effort Evaluation
* ------------------------------------------------------------------------------	
	
	

	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_Group_effort_construct.dta", clear	
		
		
	
	* Distribution of effort evaluation generally
	tab 	effort
	
	summ  effort, detail
	graph bar, over(effort) blabel(total, format(%9.1f)) 	///
			   title("Distribution: Effort evaluation") subtitle("Linkages: N = `r(N)'") ///
			   graphregion(fcolor(white) ifcolor(white)) 							///
			   plotregion(fcolor(white) ifcolor(white)) scale(*1)			  			
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Effort_evaluation.eps", replace
	graph export "$EDLREFOR_outRaw/Group_Aanalysis/Effort_evaluation.pdf", replace
	
	
	
	
	
	
	* Regression 
	
	lab var diff_ethnicity "Different ethnicity (Yes=1, No=0)"
	
	eststo clear
	mlogit effort diff_ethnicity, base(0)
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/mlogit_effort.tex", label r2 ar2 se star(* 0.10 ** 0.05 *** 0.01) replace 	nobaselevels	///
		style(tex)  mtitle("Effort" )  																							///
		addnotes("")	

		

	
	
	
* ------------------------------------------------------------------------------
* 3.) CONFIDENCE / TRUST Analysis 
* ------------------------------------------------------------------------------
/*	
1 Aucune confiance
2 Peu de confiance
3 Confiance moyenne
4 Assez de confiance
5 Confiance totale
*/	
	
	* Individual: Link level
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_confidence_construct.dta", clear

	* Binary variable, wether the respondent trusts the respective group member 
	* coded as 4 (Assez de confiance) or 5 (Confiance totale)
	
	lab var diff_ethnicity "Different ethnicity"
	
	
	
	eststo clear	
	eststo:	reg ind_conf diff_ethnicity
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/Trust_directlink.tex", label r2 ar2 se star(* 0.10 ** 0.05 *** 0.01) replace	nobaselevels	///
		style(tex)  mtitle("Confidence")  																												///
		addnotes("")	
	


	
* ---------------------------------------------------------------------------- *	
* Descriptives on Trust -> Individual level
* ---------------------------------------------------------------------------- *
	

	use	 "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_Trust_individual_level.dta", clear

	
	
	
	lab var 		num_trusted "Trusted"
	
	
	eststo clear
	estpost tabulate num_trusted 
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/num_trusted.tex", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") 		/// 
													 nonumber nomtitle noobs replace							///
													 eqlabels(, lhs("Trusted"))                     			///
													 varlabels(, blist("{hline @width}{break}"))      			
	

	eststo clear	
	estpost tabulate prop_trusted 
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/prop_trusted.tex", cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") 		/// 
													 nonumber nomtitle noobs replace							///
													 eqlabels(, lhs("Trusted"))                     			///
													 varlabels(, blist("{hline @width}{break}"))      			
	
	tab 	trust_50plus

* ---------------------------------------------------------------------------- *	
* Regressions -  Survival on Level of confidence within a group 
* ---------------------------------------------------------------------------- *
	
	
	
	* Group level trust
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_Group_AvgTrust.dta", clear

	* Average level of Trust
	tab 	 sum_trust_group_avg
	
	br 		 sum_trust_group_avg
	gen 	 sum_trust_group_avg_r = round(sum_trust_group_avg,1)
	
	lab	 var sum_trust_group_avg_r	"Level of Trust"
	
	
	
	* transform to Z score
	summ	sum_trust_group_avg, detail
	gen 	trust_Z = (sum_trust_group_avg - `r(p50)') / (`r(sd)')
	
	tab		 trust_Z
	
	kdensity trust_Z
	
	
	* log 
	
	gen 	trust_log = log(sum_trust_group_avg)
	
	tab 	trust_log
	
	
	* recode Trust to binary, and replace with 1 in case average is equal or above 4
	gen 	Trust = 0
	replace Trust = 1				if sum_trust_group_avg >= 4
	
	tab 	Trust
	
	

	rename a1_region 		region	
	rename a2_site 			site
	rename a4_bloc 			bloc
	rename a5_parcelle		parcelle
		
	
	* Merge tree survival data - on group level
	merge m:m region site bloc parcelle using "$EDLREFOR_dtInt/Constructed/SurvivalRates_GroupLevel_vivant1.dta", gen(Merge_Survival) keep(3)
	
	
	* Merge tree survival data - on group level
	merge m:m region site bloc parcelle using "$EDLREFOR_dtInt/Constructed/SurvivalRates_GroupLevel_vivant2.dta", gen(Merge_Survival2) keep(3)
	

	* Merge number of group interaction: pour discuter or reunion sur la parcelle
	merge 1:1 group_id using "$EDLREFOR_dt/Intermediate/Constructed/GroupInteraction_GroupLevel.dta", keep(3)

	
	
	
	
	
	* 1.) Treatment indicator -> whether the individual trusts more than 50 percent of his/her group
	eststo clear	
	eststo:	reg vivant1  i.sum_trust_group_avg_r  
	estadd local bloc "No"	
	eststo:	areg vivant1 i.sum_trust_group_avg_r, absorb(bloc)
	estadd local bloc "Yes"	
	eststo:	areg vivant1 i.sum_trust_group_avg_r median_b28, absorb(bloc)
	estadd local bloc "Yes"		
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/trust_vivant1_regression.tex", label r2 ar2 se star(* 0.10 ** 0.05 *** 0.01) replace	nobaselevels	///
		style(tex)  mtitle("Vivant 1" "Vivant 1" "Vivant 1")  														///
		addnotes("")	///
		scalar("bloc Bloc fixed effects.")	
		
	
	
	
	
	* 2.) Vivant 2
	eststo clear	
	eststo:	reg vivant2 i.sum_trust_group_avg_r  
	estadd local bloc "No"	
	eststo:	areg vivant2 i.sum_trust_group_avg_r, absorb(bloc)
	estadd local bloc "Yes"	
	eststo:	areg vivant1 i.sum_trust_group_avg_r median_b28, absorb(bloc)
	estadd local bloc "Yes"		
	esttab using "$EDLREFOR_outRaw/Group_Aanalysis/trust_vivant2_regression.tex", label r2 ar2 se star(* 0.10 ** 0.05 *** 0.01) replace	nobaselevels	///
		style(tex)  mtitle("Vivant 2" "Vivant 2" "Vivant 2")  														///
		addnotes("")	///
		scalar("bloc Bloc fixed effects.")	
	
	
	
	
	
	

	
