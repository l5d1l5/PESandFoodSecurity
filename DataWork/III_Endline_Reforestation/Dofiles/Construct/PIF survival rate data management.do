



	*************************
	*	SETTINGS DIRECTORY	*
	*************************
 
if (1) { 


	* Verify directory path by running 

	dis "`c(username)'" // The text that shows up is the username of your computer (say XXX), and insert that into the code below
	
	
   * Root folder globals
   * ---------------------

   if c(username)=="WB495145" {
       global projectfolder "C:\SD Card\Cloud Docs\Dropbox\World Bank projects\PROJECTS\1-BURKINA FORESTRY"
   }

   if c(username)=="sergeadjognon" {
       global projectfolder "/Volumes/My Passport for Mac/CloudDocs/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY"  //Enter the file path to the projectfolder of next user here
 
   }
   
   if c(username)=="soest"  {
	   global projectfolder "C:\Users\soest\Dropbox"										
	}


*These lines are used to test that name ois not already used (do not edit manually)
*round*I_RemoteSensing*STLDATA*II_Baseline_Reforestation*BSLREFOR*III_Endline_Reforestation*EDLREFOR
*untObs*************************************************************************
*subFld*************************************************************************
*iefolder will not work properly if the lines above are edited


   * Project folder globals
   * ---------------------

   global dataWorkFolder         "$projectfolder/DataWork"

*iefolder*1*FolderGlobals*subfolder*********************************************
*iefolder will not work properly if the line above is edited


*iefolder*1*FolderGlobals*master************************************************
*iefolder will not work properly if the line above is edited

   global mastData               "$dataWorkFolder/MasterData" 

*iefolder*1*FolderGlobals*encrypted*********************************************
*iefolder will not work properly if the line above is edited

   global encryptFolder          "$dataWorkFolder/EncryptedData" 


*iefolder*1*RoundGlobals*rounds*I_RemoteSensing*STLDATA*************************
*iefolder will not work properly if the line above is edited

   *I_RemoteSensing folder globals
   global STLDATA                "$dataWorkFolder/I_RemoteSensing" 
   global STLDATA_encrypt        "$encryptFolder/Round I_RemoteSensing Encrypted" 
   global STLDATA_dt             "$STLDATA/DataSets" 
   global STLDATA_do             "$STLDATA/Dofiles" 
   global STLDATA_out            "$STLDATA/Output" 


*iefolder*1*RoundGlobals*rounds*II_Baseline_Reforestation*BSLREFOR**************
*iefolder will not work properly if the line above is edited

   *II_Baseline_Reforestation folder globals
   global BSLREFOR               "$dataWorkFolder/II_Baseline_Reforestation" 
   global BSLREFOR_encrypt       "$encryptFolder/Round II_Baseline_Reforestation Encrypted" 
   global BSLREFOR_dt            "$BSLREFOR/DataSets" 
   global BSLREFOR_do            "$BSLREFOR/Dofiles" 
   global BSLREFOR_out           "$BSLREFOR/Output" 


*iefolder*1*RoundGlobals*rounds*III_Endline_Reforestation*EDLREFOR**************
*iefolder will not work properly if the line above is edited

   *III_Endline_Reforestation folder globals
   global EDLREFOR               "$dataWorkFolder/III_Endline_Reforestation" 
   global EDLREFOR_encrypt       "$encryptFolder/Round III_Endline_Reforestation Encrypted" 
   global EDLREFOR_dt            "$EDLREFOR/DataSets" 
   global EDLREFOR_do            "$EDLREFOR/Dofiles" 
   global EDLREFOR_out           "$EDLREFOR/Output" 

*iefolder*1*FolderGlobals*endRounds*********************************************
	
}
*




	****************************
	*	VARIABLE CONSTRUCT     *
	****************************
	
if (1)  {
use "$EDLREFOR_dt/Intermediate/collector_app_data_clean", clear

	generate vivant1	=(condition_code==4 | condition_code==5) & (condition_code!=.) 
	replace vivant1=vivant1*100
	label define yesno 0"Non" 100"Oui", replace
	label values vivant1 yesno
	label variable vivant1 "Plant vivant et en bon etat"
	
	generate vivant2		=(condition_code==3 | condition_code==4 | condition_code==5) & (condition_code!=.) 
	replace vivant2=vivant2*100
	label variable vivant2 "Plant vivant quelque soit l'etat"
	label values vivant2 yesno	
	
	generate count=1
	generate trees_alive=vivant1==100
	

save "$EDLREFOR_dt/Intermediate/collector_app_data_construct", replace

}
*



	****************************
	*	PRELIMINARY ANALYSIS   *
	****************************

	
	* Descriptive analysis a tree level	
	
	
if (1)  {	

	
use "$EDLREFOR_dt/Intermediate/collector_app_data_construct", clear

**** Taux de survie general et par espece d'arbre

	graph pie, over(vivant1) pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					color(white) size(vsmall)) /// title(Taux moyen de survie, color(navy) size(medium)) ///
					subtitle(Plants vivants et en bon etat, size(small))
						graph rename p1, replace

	graph pie, over(vivant2) pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					color(white) size(vsmall)) /// title(Taux moyen de survie, color(navy) size(medium))	///
					subtitle(Plants vivants quelque soit l'etat, size(small))				
						graph rename p2, replace
					
	graph hbar vivant1, over(espece_code, sort(1) label(labsize(vsmall)))  ///
						bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
						ytitle(Pourcentage) ///
						ytitle(, margin(medium)) ///
						title(Taux de survie par espece d'arbres)  ///
						subtitle(Plants vivants et en bon etat) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.8)	
						graph rename b1, replace

	graph hbar vivant2, over(espece_code, sort(1) label(labsize(vsmall)))  ///
						bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
						ytitle(Pourcentage) ///
						ytitle(, margin(medium)) ///
						title(Taux de survie par espece d'arbres)  ///
						subtitle(Plants vivants quelque soit l'etat) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.8)	
						graph rename b2, replace
						
	graph combine p1 p2 b1 b2, 	 title(Burkina Faso PIF - Campagne de reforestation 2017)  ///
						subtitle(Taux de survie des arbres plantes, size(medium) color(gs10))
	gr export	"$EDLREFOR_out/Taux_survie.pdf", replace
	gr export	"$EDLREFOR_out/Taux_survie.png", width(5000) replace
	

**** Taux de survie par forest

	graph hbar vivant1, over(site, sort(1) label(labsize(vsmall)))  ///
						bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
						ytitle(Pourcentage) ///
						ytitle(, margin(medium)) ///
						/// title(Taux de survie par foret)  ///
						subtitle(Plants vivants et en bon etat) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)	
						graph rename b1, replace

	graph hbar vivant2, over(site, sort(1) label(labsize(vsmall)))  ///
						bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
						ytitle(Pourcentage) ///
						ytitle(, margin(medium)) ///
						/// title(Taux de survie par foret)  ///
						subtitle(Plants vivants quelque soit l'etat) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)	
						graph rename b2, replace
						
	graph combine b1 b2, 	 title(Burkina Faso PIF - Campagne de reforestation 2017)  ///
						subtitle(Taux de survie par foret, size(medium) color(gs10))
	gr export	"$EDLREFOR_out/Taux_survie_par_forest.pdf", replace
	gr export	"$EDLREFOR_out/Taux_survie_par_forest.png", width(5000) replace
	

	
	
**** Taux de survie par type de traitements

	graph bar vivant1, over(treatment,  label(labsize(small)))  ///
						bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
						ytitle(Pourcentage) ///
						ytitle(, margin(medium)) ///
						/// title(Taux de survie par type de traitement)  ///
						subtitle(Plants vivants et en bon etat) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)	
						graph rename c1, replace

	graph bar vivant2, over(treatment,  label(labsize(small)))  ///
						bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
						ytitle(Pourcentage) ///
						ytitle(, margin(medium)) ///
						/// title(Taux de survie par type de traitement)  ///
						subtitle(Plants vivants quelque soit l'etat) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)	
						graph rename c2, replace						
						
	graph combine c1 c2, ycommon title(Burkina Faso PIF - Campagne de reforestation 2017)  ///
						subtitle(Taux de survie par type de contract, size(medium) color(gs10))
	gr export	"$EDLREFOR_out/Taux_survie_par_traitement.png", width(5000) replace	
	

****	
	graph pie, over(vivant2) pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
					color(white) size(vsmall)) title(Overall Survival Rate, color(navy) size(medium))	///
					subtitle(Is the tree still alive at verification?, size(small))				
						graph rename ep2, replace
					

	graph hbar vivant2, over(espece_code, sort(1) label(labsize(vsmall)))  ///
						bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
						ytitle(Percentage) ///
						ytitle(, margin(medium)) ///
						title(Which Tree Species Survived Most?)  ///
						subtitle(Percentage of trees still alive by species) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)	
						graph rename eb2, replace
						
	graph combine  ep2  eb2, 	 title(Burkina Faso PIF - Reforestation Campaign 2017)  ///
						subtitle(Tracking the Survival of Trees Planted, size(medium) color(gs10))
	gr export	"$EDLREFOR_out/Taux de survie_PIF reforestation 2017_eng.pdf", replace	
	gr export	"$EDLREFOR_out/Taux de survie_PIF reforestation 2017_eng.png", width(5000) replace	
	
****	
	
	
	
	
	
	regress vivant1 i.treatment i.siteid i.espece_code if treatment!=3
	
	regress vivant2 i.treatment i.siteid i.espece_code if treatment!=3	
	
	regress vivant1 i.treatment i.siteid i.espece_code if treatment!=3, cluster (parcelleid)
	
	regress vivant2 i.treatment i.siteid i.espece_code if treatment!=3, cluster (parcelleid)
	
	}
	*
	
	
	
	* Descriptive analysis a Parcel level	
	
	
if (1)  {	


use "$EDLREFOR_dt/Intermediate/collector_app_data_construct", clear

	collapse (mean) vivant1 vivant2 (sum) count trees_alive, by(region site bloc parcelle siteid blocid treatment parcelleid)
	
	egen TOTAL=total(count)
	bysort region site bloc parcelle siteid blocid treatment parcelleid: gen weight=count/TOTAL
	tab weight
	
	
	regress vivant1 i.treatment i.siteid  if treatment!=3 [pweight=weight]
	
	regress vivant2 i.treatment i.siteid  if treatment!=3	[pweight=weight]
	
	
	preserve
	keep if treatment!=3
	recode treatment (1=0) (2=1)
	label define treatment 0"Linear paiement" 1"Threshold Paiement", modify
	label variable vivant1 "proportion of trees alive"
	regress vivant1 treatment i.siteid [pweight=weight], robust cluster(blocid)  	
	iegraph treatment , basictitle("Treatment Effect on Outcome") ///
						yzero ylabel(0(20)40)   ytitle("Survival Rates")  ///
						legend(order(1 2)  lab(2 "Threshold Paiement")  lab(1 "Linear paiement")) ///
						note(Note: The graph shows a statistically significant difference between the two types of contract) ///
						title(Effect of Contract Design on Survival Rates)
	gr export	"$EDLREFOR_out/Effect of Contract Design on Survival Rates.pdf", replace	
	gr export	"$EDLREFOR_out/Effect of Contract Design on Survival Rates.png", width(5000) replace	
	restore
	
	/* Code Daan -- simple paired t-tests and Wilcoxen's
	generate vivant1_bleue = vivant1 if treatment == 1  /* en bonne etat, lineair */
	label variable vivant1_bleue "Lineair, plant vivant en bonne etat"
	
	generate vivant1_rouge = vivant1 if treatment == 2  /* en bonne etat, seuil */
	label variable vivant1_rouge "Seuil, plant vivant en bonne etat"
	
	generate vivant2_bleue = vivant2 if treatment == 1  /* en vie, quelque soit l'etat, lineair */
	label variable vivant2_bleue "Lineair, plant vivant quelque soit l'etat"

	generate vivant2_rouge = vivant2 if treatment == 2  /* en vie, quelque soit l'etat, seuil */
	label variable vivant2_rouge "Seuil, plant vivant quelque soit l'etat"
	
	
	sort siteid blocid treatment
	
	ttest vivant2 if treatment != 3, by(treatment)
	sdtest vivant2_rouge = vivant2_bleue

	
	regress vivant1 i.treatment i.blocid if treatment!=3, robust cluster(blocid)
	regress vivant2 i.treatment i.blocid if treatment!=3, robust cluster(blocid)
	
	preserve
	drop parcelleid vivant2_bleue vivant2_rouge vivant2 vivant1_bleue vivant1_rouge parcelle count trees_alive
	drop if treatment == 3
	reshape wide vivant1, i(blocid) j(treatment)
	signrank vivant11 = vivant12 /* vivant21 = good state, bleu; vivant22 = good state, seuil */
	ttest vivant11 = vivant12
	restore
	
	preserve
	drop parcelleid vivant2_bleue vivant2_rouge vivant1 vivant1_bleue vivant1_rouge parcelle count trees_alive
	drop if treatment == 3
	reshape wide vivant2, i(blocid) j(treatment)
	signrank vivant21 = vivant22 /* vivant21 = alive, bleu; vivant22 = alive, seuil */
	ttest vivant21 = vivant22
	restore


		
	*/
*****

	hist trees_alive if count<=300, by(treatment) width(10) 
		
	twoway (kdensity trees_alive if treatment==1) (kdensity trees_alive if treatment==2)
	
	twoway (kdensity count if treatment==1) (kdensity count if treatment==2)	
	
	twoway (kdensity vivant1 if treatment==1) (kdensity vivant1 if treatment==2)	
	
	twoway (kdensity vivant2 if treatment==1) (kdensity vivant2 if treatment==2)	

	


			
	graph box vivant1, over(treatment)			
	graph box vivant2, over(treatment)
	graph bar vivant2, over(treatment)	
	
	twoway 	(kdensity vivant2 if treatment==1) ///
			(kdensity vivant2 if treatment==2) ///
			(kdensity vivant2 if treatment==3)	
			
	twoway 	(kdensity vivant1 if treatment==1) ///
			(kdensity vivant1 if treatment==2) ///
			(kdensity vivant1 if treatment==3)
	
	}
	*
	
	
	* Randomized Inference test

if (1)  {	
	
use "$EDLREFOR_dt/Intermediate/collector_app_data_construct", clear

	preserve	
	keep if treatment!=3 
	recode treatment (1=0) (2=1)
	label define treatment 0"Parcelle Bleue"  1"Parcelle Rouge", replace
	label values treatment treatment

	ritest treatment _b[treatment], reps(50) seed(278): ///
		regress  vivant2 treatment i.siteid i.espece_code, cluster (parcelleid)
		
		mat b = r(b)
		mat p = r(p)
		local beta = b[1,1]
			local beta = round(`=100*`beta'',2)/100
		local pval = p[1,1]
			local pval = round(`=10000*`pval'',2)/10000
		
		di "`beta' , `pval'"
		
	ritest treatment _b[treatment], reps(50) ///
		kdensityplot kdensityoptions(title("Randomized Inference Results") xtitle("Beta=`beta'  &  P-Value=`pval'")) seed(278): ///
		regress  vivant2 treatment i.siteid i.espece_code, cluster (parcelleid)
		
	restore	
			
}
*


if (1)  {
* MERGING TOGETHER ALL THE DATASETS AVAILABLE

	* Take the collector app survival rate data
	use "$EDLREFOR_dt/Intermediate/collector_app_data_construct.dta", clear
	
	* then collapse at the parcelle level
	collapse (mean) vivant1 vivant2, by(region site bloc parcelle siteid blocid treatment parcelleid)
	label variable vivant1 "Plant vivant et en bon etat"
	label variable vivant2 "Plant vivant quelque soit l'etat"
	
	* Then merge it to the self reported survival rate data
	merge 1:1 region site bloc parcelle using "$EDLREFOR_dt/Intermediate/self reported survival_clean.dta", gen(merge1)
	
	* Then merge these to the baseline participant survey + actual paiement made by CEMES
		preserve 
	
			* Prepare the baseline survey data
			use "$BSLREFOR_dt/Intermediate/participant_survey_clean.dta", clear
			sort region foret bloc parcelle statut
			drop if statut==0 // dropping people in the control group

			rename region region1
			decode region1, gen(region)
			decode foret, gen(site)
			bysort region site bloc parcelle: egen count=count(objectid)
			label variable count "Number of people surveyed at baseline from this parcelle"
			order region site bloc parcelle nom prenom count
	
			
			* Then merge the baseline survey to the actual paiement data made by CEMES
			merge 1:1 region site bloc parcelle nom prenom using "$EDLREFOR_dt/Intermediate/actual paiement made_clean.dta", gen(merge2) force

			sort   region site bloc parcelle merge2 nom prenom
			order merge2  region site bloc parcelle nom prenom
			browse

			* Reporting some of the issues with the merging
			*drop if parcelle=="Parcelle VERTE"
			label define issue 1"Original Data Only" 2"CEMES paiement data only"  3"Matched - No problem"
			label values  merge2 issue
			rename merge2 PROBLEMES 
			export delimited using "$EDLREFOR_dt/raw/Archives/problemes avec les donnees.csv", replace

			* Dropping participant used as replacement in an ad hoc manner 
			bysort region site bloc parcelle: egen count1=mean(count)
			drop if PROBLEMES==2 & count1==5	
			tab PROBLEMES
			
			* we can now generate any variable we want 
			
			* Then collapse this at the parcelle level
			
			* save this data temporarily
			tempfile temp
			save `temp'
			
		restore
			
	merge 1:m region site bloc parcelle using `temp', gen(merge3)

	save "$EDLREFOR_dt/Intermediate/PIF_afforestation_AllMergeData", replace

}
*


* This is to check that the names of region forest and bloc are well written everywhere
use "$BSLREFOR_dt/Intermediate/participant_survey_clean.dta", clear
duplicates drop region foret bloc, force
rename region region1
decode region1, gen(region)
decode foret, gen(site)
merge 1:m region site bloc using "$EDLREFOR_dt/Intermediate/self reported survival_clean.dta", gen(merge1)
duplicates drop region site bloc, force
sort region site bloc merge1
order region site foret bloc merge1
drop parcelle 
*keep region site bloc
merge 1:m region site bloc using "$EDLREFOR_dt/Intermediate/actual paiement made_clean.dta", gen(merge2) force
browse
sort site bloc parcelle paiement_actual
browse site foret bloc parcelle paiement_actual survie_SR Paiement_prevu
*/



* Merging basleine and endline data

use "$BSLREFOR_dt/Intermediate/participant_survey_clean.dta", clear

gen hhid=objectid
                                                
merge 1:1  hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(repondent_fullname b* stat_enq - sexe_str)

order hhid nom prenom  repondent_fullname region foret bloc parcelle statut village
