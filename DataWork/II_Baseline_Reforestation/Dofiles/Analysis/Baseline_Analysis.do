* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *		
*          ANALYSIS of Burkina Faso 	  	   								   *
*          This do file contains the Analysis for 				 			   *
*          Burkina Faso Forestry Baseline  						   			   *
*                                                                      		   *
* **************************************************************************** *
* **************************************************************************** *


	* Project: 	Analysis for the Burkina Faso Baseline Report

	* Author: 	Jonas Guthoff (jguthoff@worldbank.org)


	* Created:  12/09/2018

	
	* Unique identifiers: hhid
	* OUTLINE: CONSTRUCT DATA, Module-by-Module	
	* This do file uses the "clean" data Baseline_raw_nodups.dta generated in the Cleaning.do
	* Here we construct the variables and indicators that will be used in the 
	* Analysis.do
	
	
	** REQUIRES: 	Run II_Baseline_Reforestation_MasterDofile.do first to set all the globals
	
	
		
********************************************************************************
** SECTION A - IDENTIFICATION OF THE PARTICIPANT
********************************************************************************


		use "$BSLREFOR_dt/Intermediate/SectionA_construct.dta" , clear


		
	
	
	
	
	
	
	
	
	
	
********************************************************************************
** SECTION B - SOCIO - DEMOGRAPHIC CHARACTERISTCS
********************************************************************************
	
	
		use "$BSLREFOR_dt/Intermediate/SectionB_construct.dta" , clear
		
		
		/* BALANCE TABLE: SOCIO-DEMOGRAPHICS + OCCUPATION/INCOME
		
		label define yesno 0 "Non" 1"Oui"
		label values female_resp 	yesno
		label values school 		yesno
		label values sbq22 			yesno
		label values farmer_resp 	yesno
			
		iebaltab 	age female_resp sbq17 sbq18 school sbq22 farmer_resp  Wsbq10,   ///
					grpvar(treatment) grplabels(1 Treatment @ 0 Control) 						   ///
					/// vce(cluster forestid) ///
					total rowvarlabels pftest ///
					tblnote("This Table summarizes socio-economic differences between treatment and control group respondents.") ///
					savetex("$output/delete_me.tex") ///
					replace 

		filefilter  "$output/delete_me.tex" "$output/Balance_Socio_Econ.tex",        ///                                                          
						from("/BShline") to ("/BScline{1-8}") replace  
		*/
	
	
		* GRAPHS: SOCIO-DEMOGRAPHICS
					
				* Age
					summ age, detail
								mat b = r(mean)
								mat c = r(p50)
								local mean = b[1,1]
									local mean = round(`=`r(mean)'',2)
								local median = c[1,1]
									local median = round(`=`r(p50)'',2)	
						di "`mean', `median'"
				hist age, percent addlabel  width(10) start(10) ///
						addlabopts(yvarformat(%9.1f))  title("Distribution des participants selon l'age") ///
						/// subtitle("(N = `r(N)')") ///
						ytitle("Percentage")  ylabel(0(10)40) ///
						xtitle("Age") /// xlabel(0(1)3, valuelabel labsize(vsmall) angle(0))   ///
						 xline(`r(mean)', lpattern(dash) lcolor(red)) xmlabel(`r(mean)' "Mean=`mean'" , labsize(vsmall) angle(0)) 		///											
						/// xline(`r(p50)' , lpattern(dash) lcolor(blue)) xmlabel(`r(p50)' "Median=`median'", labsize(vsmall) angle(0)) 		///	
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)						
				gr export 	"$output/age_total.png", width(5000) replace		
				
				
				
				
				hist age, by(foret, title("Distribution des participants selon l'age par foret") legend(off)) ///
						 percent addlabel  width(20) start(10) legend(off) ///
						addlabopts(yvarformat(%9.0f))   ///
						/// subtitle("(N = `r(N)')") ///
						ytitle("Percentage") ylabel(0(25)100) ///
						xtitle("Age") /// xlabel(0(1)3, valuelabel labsize(vsmall) angle(0))   ///
						/// xline(`r(mean)', lpattern(dash) lcolor(red)) xmlabel(`r(mean)' "Mean=`mean'" , labsize(vsmall) angle(0)) 		///											
						/// xline(`r(p50)' , lpattern(dash) lcolor(blue)) xmlabel(`r(p50)' "Median=`median'", labsize(vsmall) angle(0)) 		///	
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)						
				gr export 	"$output/age_par_foret.png", width(5000) replace		
					
	
				* Gender		
				summ female_resp, detail
				graph pie, over(female_resp) pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					format(%9.0f) color(white) size(vsmall)) pie(_all, explode) /// title(Taux moyen de survie, color(navy) size(medium)) ///
					title("Proportion de femmes parmi les participants") 
				gr export 	"$output/gender_total.png", width(5000) replace	
				
				
				graph pie, over(female_resp) by(foret, title("Proportion de femmes parmi les participants par foret")) ///
						pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					format(%9.0f) color(white) size(vsmall)) pie(_all, explode) 
					/// title(Taux moyen de survie, color(navy) size(medium)) ///
				gr export 	"$output/gender_par_foret.png", width(5000) replace		
				
				
				* schooling
				summ school, detail
				graph pie, over(school) pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					format(%9.0f) color(white) size(vsmall)) pie(_all, explode) /// title(Taux moyen de survie, color(navy) size(medium)) ///
					title("Taux de scholarisation parmi les participants") 
				gr export 	"$output/school_total.png", width(5000) replace	
				
				
				graph pie, over(school) by(foret, title("Taux de scholarisation  parmi les participants par foret")) ///
						pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					format(%9.0f) color(white) size(vsmall)) pie(_all, explode) 
					/// title(Taux moyen de survie, color(navy) size(medium)) ///
				gr export 	"$output/school_par_foret.png", width(5000) replace					
				
				
				* GGF members
				summ sbq22, detail
				graph pie, over(sbq22) pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					format(%9.0f) color(white) size(vsmall)) pie(_all, explode) /// title(Taux moyen de survie, color(navy) size(medium)) ///
					title("Participants membres de GGF") 
				gr export 	"$output/GGF_total.png", width(5000) replace	
				
				
				graph pie, over(sbq22) by(foret, title("Participants membres de GGF par foret")) ///
						pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					format(%9.0f) color(white) size(vsmall)) pie(_all, explode) 
					/// title(Taux moyen de survie, color(navy) size(medium)) ///
				gr export 	"$output/GGF_par_foret.png", width(5000) replace		
				
				
						

	
	
	
		* GRAPHS: OCCUPATION/INCOME
	
				* Agriculteur as primary occupation
				summ farmer_resp, detail
				graph pie, over(farmer_resp) pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					format(%9.0f) color(white) size(vsmall)) pie(_all, explode) /// title(Taux moyen de survie, color(navy) size(medium)) ///
					title("Agriculture comme occupation principale") 
				gr export 	"$output/farmprimary_total.png", width(5000) replace	
				
				
				graph pie, over(farmer_resp) by(foret, title("Agriculture comme occupation principale par foret")) ///
						pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					format(%9.0f) color(white) size(vsmall)) pie(_all, explode) 
					/// title(Taux moyen de survie, color(navy) size(medium)) ///
				gr export 	"$output/farmprimary_par_foret.png", width(5000) replace			
	
	
					summ Wsbq11, detail
								mat b = r(mean)
								mat c = r(p50)
								local mean = b[1,1]
									local mean = round(`=`r(mean)'',0.2)
								local median = c[1,1]
									local median = round(`=`r(p50)'',0.2)	
						di "`mean', `median'"
					twoway		(kdensity Wsbq11,  lcolor(emidblue) lwidth(medthick)), ///
									title("Revenu annuel tire de l'activite principale", size(medium)) ///
									/// subtitle("(N = `r(N)')", size(small)) ///
									xlabel(, labsize(small))  ylabel(, labsize(vsmall))			///
									xtitle("Montant (FCFA)", size(medium)) 			///
									ytitle("Density", size(medium))    ///
									/// xline(`r(mean)', lpattern(dash) lcolor(red)) xmlabel(`r(mean)' "Mean=`mean'"    , labsize(vsmall) angle(0)) 		///											
									xline(`r(p50)' , lpattern(dash) lcolor(blue)) xmlabel(`r(p50)' "Median=`median'", labsize(vsmall) angle(0)) 													
							gr export 	"$output/revenuprinc_total.png", replace				
	
********************************************************************************
** SECTION C - ASSETS
********************************************************************************

 
		use "$BSLREFOR_dt/Intermediate/SectionC_construct.dta" , clear

		
	
	
	* BALANCE TEST OF ALL ASSSET INDICES

		iebaltab 	asset_agr_index assets_agri_sum asset_hh_index assets_house_sum asset_live_index assets_livestock_sum,   ///
					grpvar(treatment) grplabels(1 Treatment @ 0 Control) ///
					/// vce(cluster forestid) ///
					total rowvarlabels pftest ///
				    tblnote("This Table shows balance tests for asset indices of agricultural and household assets, as well as of livestock. We display asset indices obtained using principal component analysis (PCA) and simpel sums.") ///
					savetex("$output/delete_me.tex") ///
					replace 

		filefilter  "$output/delete_me.tex" "$output/Balance_Asset_Indices.tex",        ///                                                          
                    from("/BShline") to("/BScline{1-8}") replace  
	
	
	
	
	* KERNEL DENSITY PLOTS FOR EACH ASSET INDEX COMPUTED USING PCA
	
	
		* 1) Agricultural Assets
		summ asset_agr_index
		twoway kdensity asset_agr_index if treatment==0, bwidth(2) ||	///
			   kdensity asset_agr_index if treatment==1, bwidth(2) ||	///
			   kdensity asset_agr_index, bwidth(2) 					///
			   scheme(sj) title("Agriculture Asset Index") subtitle("(N = `r(N)')") xtitle("Index") 	///
			   ytitle("Density") legend(order(1 "Control" 2 "Treatment" 3 "Combined"))	 graphregion(color(white)) 	///
			   note("The Asset Index is computed using PCA. Epanechnikov Kernel with Bandwidth 2.")
		gr export 	"$output/Asset_Agric_Kdensity.pdf", replace	

		
			
		* 2.) Household Assets
		summ asset_hh_index
		twoway kdensity asset_hh_index if treatment==0, bwidth(2)    ||	///
			   kdensity asset_hh_index if treatment==1, bwidth(2)  	 ||	///
			   kdensity asset_hh_index, bwidth(2) 					///
			   scheme(sj) title("Household Asset Index") subtitle("(N = `r(N)')") xtitle("Index") 	///
			   ytitle("Density") legend(order(1 "Control" 2 "Treatment" 3 "Combined")) graphregion(color(white)) 	///
			   note("The Asset Index is computed using PCA. Epanechnikov Kernel with Bandwidth 2.")
		gr export 	"$output/Asset_HH_Kdensity.pdf", replace	

		
		
		
		
		* 3.) Livestock 
		summ asset_live_index
		twoway kdensity asset_live_index if treatment==0, bwidth(2)  	||	///
			   kdensity asset_live_index if treatment==1, bwidth(2) 	||	///
			   kdensity asset_live_index, bwidth(2)					///
			   scheme(sj) title("Livestock Asset Index") subtitle("(N = `r(N)')") xtitle("Index") 	///
			   ytitle("Density") legend(order(1 "Control" 2 "Treatment" 3 "Combined"))	graphregion(color(white)) 	///
			   note("The Asset Index is computed using PCA. Epanechnikov Kernel with Bandwidth 2.")
		gr export 	"$output/Asset_livestock_Kdensity.pdf", replace	
		
		
	

	
	
********************************************************************************
** SECTION D - ECONOMIC ACTIVITY
********************************************************************************

 
	use "$BSLREFOR_dt/Intermediate/SectionD_construct.dta" , clear

	* PART 1: Agriculture Production
	* PART 2: Non-Agricultural Production
	
	
	
	
	* PART 1: Agriculture Production
	
		* 1.) Table on general characteristics &  Input use
	
	
		iebaltab 	sdq1 Wsdq2 Wsdq3 share_cult  total_inputs Wsdq18,   ///
					grpvar(treatment) grplabels(1 Treatment @ 0 Control) ///
					/// vce(cluster forestid) ///
					total rowvarlabels pftest ///
				    tblnote("This Table shows a balance tests on general agricultural production characteristcs by treatment group.") ///
					savetex("$output/delete_me.tex") ///
					replace 

		filefilter  "$output/delete_me.tex" "$output/Balance_Agricultural_Production.tex",        ///                                                          
                    from("/BShline") to("/BScline{1-8}") replace  

	
	
	
	
	* 2.) Input Use -> Total Value and Shares

		* Balance Table on Inputs Used
	
		iebaltab 	sdq4 Wsdq5 share_Wsdq5 sdq6 Wsdq7 share_Wsdq7 sdq8 sdq9 share_sdq9 sdq10 Wsdq11 share_Wsdq11 sdq12 Wsdq13 share_Wsdq13,   ///
					grpvar(treatment) grplabels(1 Treatment @ 0 Control) ///
					/// vce(cluster forestid) ///
					total rowvarlabels pftest ///
				    tblnote("This Table shows a balance tests of values of inputs used and the share of the total value spent on inputs.† Variables are winsorized at 99 percent.") ///
					savetex("$output/delete_me.tex") ///
					replace 

		filefilter  "$output/delete_me.tex" "$output/Balance_Inputs.tex",        ///                                                          
                    from("/BShline") to("/BScline{1-8}") replace  

	
	
	* 3.) Funding
	
	
			* Source of Funding -> change graph backgroun color to white		 
			summ sdq17 if treatment==0	
			graph pie if treatment==0, pie(1, color(navy)) pie(2, color(edkblue)) pie(3, color(ebblue)) pie(4, color(ltblue)) pie(5, color(bluishgray8)) over(sdq17) graphregion(color(white))  plabel(_all percent,size(*0.75) gap(15) format(%9.2fc) color(black)) title("Control (N = `r(N)')") name(Fund0)
			summ sdq17 if treatment==1
			graph pie if treatment==1, pie(1, color(navy)) pie(2, color(edkblue)) pie(3, color(ebblue)) pie(4, color(ltblue)) pie(5, color(bluishgray8)) over(sdq17) graphregion(color(white))  plabel(_all percent,size(*0.75) gap(15)  format(%9.2fc) color(black)) title("Treatment (N = `r(N)')") name(Fund1)
	
			grc1leg Fund0 Fund1, title("Source of Funding for Agric. Activities")  legendfrom(Fund1) graphregion(color(white))
			graph export "$output/Source_Funding.pdf", replace
	
			graph drop Fund0 Fund1

	
	
	
	* PART 2: Non-Agricultural Production
		* br sdq19_a  sdq19_b sdq19_c sdq19_d sdq19_e sdq19_f sdq19_g sdq19_h

	
	
		iebaltab 	sdq19_a  sdq19_b sdq19_c sdq19_d sdq19_e sdq19_f sdq19_g sdq19_h,   ///
					grpvar(treatment) grplabels(1 Treatment @ 0 Control) ///
					/// vce(cluster forestid) ///
					total rowvarlabels pftest ///
				    tblnote("This Table shows a balance tests of different non-agricultural income generating activities of participants.") ///
					savetex("$output/delete_me.tex") ///
					replace 

		filefilter  "$output/delete_me.tex" "$output/Balance_Non_Agric_Activities.tex",        ///                                                          
                    from("/BShline") to("/BScline{1-8}") replace  

	

	
	
	
********************************************************************************
** SECTION E - FOOD CONSUMPTION
********************************************************************************


 
		use "$BSLREFOR_dt/Intermediate/SectionE_construct.dta" , clear

 	
	
		* Balance Table by Treatment of Food Consumption Index variables
		
		label var 	fcs "Score de Consommation Alimentaire"
		label var 	HDDS "Echelle de Diversite Alimentaire"
		
		iebaltab 	fcs  fcs_catVar1 fcs_catVar2 fcs_catVar3 ///
					HDDS HDDS_catVar1 HDDS_catVar2 HDDS_catVar3,   ///
					grpvar(treatment) grplabels(1 Treatment @ 0 Control) ///
					/// vce(cluster forestid) ///
					total rowvarlabels pftest ///
				    tblnote("") ///
					savetex("$output/delete_me.tex") ///
					replace 

		filefilter  "$output/delete_me.tex" "$output/Food_Consumption_Indices.tex",        ///                                                          
                    from("/BShline") to("/BScline{1-8}") replace  

		
	
	
		* FOOD CONSUMPTION SCORE
		
		
				twoway kdensity fcs if treatment==1, bwidth(2)  ||	///
					   kdensity fcs if treatment==0, bwidth(2) 	||	///
					   kdensity fcs, bwidth(2)					///
					   title("Score de Consommation Alimentaire")  xtitle("Score") 	///
					   ytitle("Density") legend(order(1 "Treatment" 2 "Control" 3 "Combined"))		///
					   note("Epanechnikov Kernel with Bandwidth 2.")  ///
								graphregion(fcolor(white) ifcolor(white)) ///
								plotregion(fcolor(white) ifcolor(white)) 			   
				graph rename b1, replace
				
		
				summ fcs_cat, detail
				graph pie, over(fcs_cat) pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					format(%9.0f) color(white) size(vsmall)) pie(_all, explode) ///
					title("Categories de score de consommation alimentaire")  ///
								graphregion(fcolor(white) ifcolor(white)) ///
								plotregion(fcolor(white) ifcolor(white))  	 					
				graph rename b2, replace
				
	
		summ fcs, detail
		graph combine b1 b2, 	 title(Securite alimentaire des repondants)  ///
							subtitle("(N = `r(N)')", size(medium) color(gs10)) scale(*.7)		
		gr export 	"$output/ScoreConsommationAlimentaire.png", width(5000) replace		
				
				
		* DIETARY DIVERSTY SCALE
		

				twoway kdensity HDDS if treatment==1, bwidth(2)  ||	///
					   kdensity HDDS if treatment==0, bwidth(2) 	||	///
					   kdensity HDDS, bwidth(2)					///
					   title("Echelle de Diversite Alimentaire")  xtitle("Echelle") 	///
					   ytitle("Density") legend(order(1 "Treatment" 2 "Control" 3 "Combined"))		///
					   note("Epanechnikov Kernel with Bandwidth 2.")  ///
								graphregion(fcolor(white) ifcolor(white)) ///
								plotregion(fcolor(white) ifcolor(white)) 			   
				graph rename b1, replace
				
		
				summ HDDS_cat, detail
				graph pie, over(HDDS_cat) pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					format(%9.0f) color(white) size(vsmall)) pie(_all, explode) ///
					title("Categories de diversite alimentaire des repondants")  ///
								graphregion(fcolor(white) ifcolor(white)) ///
								plotregion(fcolor(white) ifcolor(white))  	 					
				graph rename b2, replace
				
	
		summ HDDS, detail
		graph combine b1 b2, 	 title(Diversite de la consommation alimentaire des repondants)  ///
							subtitle("(N = `r(N)')", size(medium) color(gs10)) scale(*.7)		
		gr export 	"$output/DiversiteAlimentaire.png", width(5000) replace								
						
						
						
						
						
		
				* Food Consumption Score - simpel sum
				summ fcs, detail
				twoway kdensity fcs if treatment==0, bwidth(2)  ||	///
					   kdensity fcs if treatment==1, bwidth(2) 	||	///
					   kdensity fcs, bwidth(2)						///
				scheme(sj) title("Weighted FCS")  xtitle("Score") graphregion(color(white)) 	///
				ytitle("Density") legend(order(1 "Control" 2 "Treatment" 3 "Combined"))		///
				name(fcs)
				


		/* Categorical
		summ fcs_cat, detail
		twoway kdensity fcs_cat if treatment==0, bwidth(2)  ||	///
			   kdensity fcs_cat if treatment==1, bwidth(2) 	||	///
			   kdensity fcs_cat, bwidth(2)					///
			   scheme(sj) title("Food Consumption Score (Categorized)") subtitle("(N = `r(N)')") xtitle("Index") 	///
			   ytitle("Density") legend(order(1 "Control" 2 "Treatment" 3 "Combined"))		///
			   note("Epanechnikov Kernel with Bandwidth 2.") 
		gr export 	"$output/FCS_cat_density.pdf", replace	
		*/
				
				
				* Food Consumption Score - categorical
				summ fcs_cat, detail
				twoway kdensity fcs_cat if treatment==0, bwidth(2)  ||	///
					   kdensity fcs_cat if treatment==1, bwidth(2) 	||	///
					   kdensity fcs_cat, bwidth(2)					///
				scheme(sj) title("FCS Thresholds") xtitle("Score") graphregion(color(white)) 	///
				ytitle("Density") legend(order(1 "Control" 2 "Treatment" 3 "Combined"))			///
				name(fcs_cat)

	

		* Outhseet the combined graphs
		summ fcs_cat, detail
		grc1leg fcs fcs_cat, title("Food Consumption Scores (FCS)") subtitle("(N = `r(N)')")  legendfrom(fcs) graphregion(color(white)) ///
		note("Epanechnikov Kernel with Bandwidth 2.")
		graph export "$output/FCS_graphs.pdf", replace
	
		graph drop fcs fcs_cat
	
	
	
	
	
	* Household Dietary Diversity Index (HDDS)
	
	
		/* Simple Sums
		summ			HDDS, detail
		twoway kdensity HDDS if treatment==0, bwidth(2)  ||	///
			   kdensity HDDS if treatment==1, bwidth(2) 	||	///
			   kdensity HDDS, bwidth(2)					///
			   scheme(sj) title("Dietary Diversity Index (HDDS)") subtitle("(N = `r(N)')") xtitle("Index") 	///
			   ytitle("Density") legend(order(1 "Control" 2 "Treatment" 3 "Combined"))		///
			   note("Epanechnikov Kernel with Bandwidth 2.") 
		gr export 	"$output/HDDS_sum_density.pdf", replace	
		*/
		
				* HDDS simple sum
				summ			HDDS, detail
				twoway kdensity HDDS if treatment==0, bwidth(2)  ||	///
					   kdensity HDDS if treatment==1, bwidth(2) 	||	///
					   kdensity HDDS, bwidth(2)					///
			    scheme(sj) title("Simple Score") xtitle("Score") graphregion(color(white))	 	///
			    ytitle("Density") legend(order(1 "Control" 2 "Treatment" 3 "Combined"))	 name(HDDS)					
		
		
		

		/* Categorical
		summ 			HDDS_cat, detail
		twoway kdensity HDDS_cat if treatment==0, bwidth(2)  ||	///
			   kdensity HDDS_cat if treatment==1, bwidth(2) 	||	///
			   kdensity HDDS_cat, bwidth(2)					///
			   scheme(sj) title("IFPRI Categories of HDDS") subtitle("(N = `r(N)')") xtitle("Index") 	///
			   ytitle("Density") legend(order(1 "Control" 2 "Treatment" 3 "Combined"))		///
			   note("Epanechnikov Kernel with Bandwidth 2.") 
		gr export 	"$output/HDDS_cat_density.pdf", replace	
		*/
	
	
				* HDDS categorical
				summ 			HDDS_cat, detail
				twoway kdensity HDDS_cat if treatment==0, bwidth(2)  ||	///
					   kdensity HDDS_cat if treatment==1, bwidth(2) 	||	///
					   kdensity HDDS_cat, bwidth(2)					///
			    scheme(sj) title("IFPRI Categories")  xtitle("Score") graphregion(color(white))		///
			    ytitle("Density") legend(order(1 "Control" 2 "Treatment" 3 "Combined"))	name(HDDS_cat)		
	

	
	
		* Outsheet the 2 HDDS graphs combined
		sum 	HDDS, detail
		grc1leg HDDS HDDS_cat, title("Household Dietary Diversity Score (HDDS)") subtitle("(N = `r(N)')")  ///
				legendfrom(HDDS_cat) graphregion(color(white))	note("Epanechnikov Kernel with Bandwidth 2.")
		graph export "$output/HDDS_graphs.pdf", replace
	
	
		graph drop HDDS HDDS_cat
	
	
	

********************************************************************************
** 
********************************************************************************

	
	
