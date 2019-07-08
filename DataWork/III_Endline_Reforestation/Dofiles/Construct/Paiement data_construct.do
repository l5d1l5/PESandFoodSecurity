



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




use "$EDLREFOR_dt/Intermediate/actual paiement made_clean.dta", clear

	forvalues x=1/3 {
	generate use`x'=.
	replace  use`x'=1 if utilisation`x'=="Acheter des habits"
	replace  use`x'=2 if utilisation`x'=="Acheter des intrants agricoles"
	replace  use`x'=3 if utilisation`x'=="Acheter des médicaments pour se soigner" 
	replace  use`x'=4 if utilisation`x'=="Acheter des produits cosmétiques (savons, pommades, etc"
	replace  use`x'=5 if utilisation`x'=="Acheter des vivres"
	replace  use`x'=6 if utilisation`x'=="Autres dépenses familiales"
	replace  use`x'=7 if utilisation`x'=="Dépenses scolaires (scolarités, fournitures, etc)"
	replace  use`x'=8 if utilisation`x'=="Faire de l'élevage"
	replace  use`x'=9 if utilisation`x'=="Réparer son engin de déplacement (moto, vélo)"
	replace  use`x'=10 if utilisation`x'==""
	}
	*
	label define use 1"Acheter des habits"                           ///
					 2"Acheter des intrants agricoles"               ///
					 3"Acheter des médicaments pour se soigner"      ///
					 4"Acheter des produits cosmétiques"             ///
					 5"Acheter des vivres"                           ///
					 6"Autres dépenses familiales"                   ///
					 7"Dépenses scolaires"                           ///
					 8"Faire de l'élevage"                            ///
					 9"Réparer son engin de déplacement (moto, vélo)" ///
					 10"Don't Know"                                   ///
					 
	label values use1 use
		label values use2 use
			label values use3 use

			
	tab use1, gen(repartition)
		forvalues z=1/10  {
			replace repartition`z'=1 if use1==`z' | use2==`z' | use3==`z'
		}
		*
		
	label variable repartition1 "Acheter des habits"                       
	label variable repartition2 "Acheter des intrants agricoles"               
	label variable repartition3 "Acheter des médicaments pour se soigner"  
	label variable repartition4 "Acheter des produits cosmétiques"
	label variable repartition5 "Acheter des vivres"                         
	label variable repartition6 "Autres dépenses familiales"            
	label variable repartition7 "Dépenses scolaires"                     
	label variable repartition8 "Faire de l'élevage"                   
	label variable repartition9 "Réparer son engin de déplacement (moto, vélo)"
	label variable repartition10 "Don't Know" 
	
	
	
	encode parcelle, gen(tr)
	
	rename region region_str
	duplicates tag nom prenom, gen(dups)
	drop if dups==1
	drop dups
   save "$EDLREFOR_dt/Intermediate/actual paiement made_construct.dta"	, replace
   
   
	use "$BSLREFOR_dt/raw/participant_survey_clean.dta", clear
	decode region, gen(region_str)
	duplicates tag nom prenom region_str, gen(dups)
	drop if dups==1
	drop dups	
	keep hhid nom prenom region_str
	merge 1:1 nom prenom region_str using "$EDLREFOR_dt/Intermediate/actual paiement made_construct.dta" 
	keep if _merge==3
	drop _merge
	save "$EDLREFOR_dt/final/actual paiement made_analysis.dta"	, replace

   
	*********************************************************
	* SUMMARY STATISTICS ON THE PAIMENTS RECEIVED BY FARMERS
	*********************************************************

	use "$EDLREFOR_dt/Intermediate/actual paiement made_construct.dta", clear
	
	twoway (kdensity paiement_actual if tr==1),  ///
		   name(paiement1)
		   
	twoway (kdensity paiement_actual if tr==2),  ///
		   name(paiement2)		  
		   
	twoway (kdensity paiement_actual if tr==3), ///
			name(paiement3)
			
	graph combine paiement1 paiement2 paiement3
		   
	graph hbox paiement_actual, over(tr), if tr!=3	
	graph dot paiement_actual, over(tr) , if tr!=3	
				
		graph drop paimentgraph		
		summ paiement_actual if tr!=3, detail
								mat b = r(mean)
								mat c = r(p50)
								local mean = b[1,1]
									local mean = round(`=`r(mean)'',0.2)
								local median = c[1,1]
									local median = round(`=`r(p50)'',0.2)	
						di "`mean', `median'"		
		twoway	(kdensity paiement_actual if tr==1,  lcolor(blue) lwidth(medthick) xaxis(1 2)) ///
				(kdensity paiement_actual if tr==2,  lcolor(red) lwidth(medthick) xaxis(1 2)), ///
					title("Paiments recus par les participants", size(large)) ///
					subtitle("aux contracts PSE du PIF pour la maintenance des plants", size(medium)) ///
					xlabel(, labsize(small) axis(1))  xlabel("", labsize(small) axis(2)) ///
					ylabel(, labsize(small)) legend(order(1 "Parcelle Bleue - Lineaire" 2 "Parcelle Rouge - Seuil"))			///
					xtitle("Montant (FCFA)", size(small)) 			///
					ytitle("Densite", size(medium))    ///
					xline(`r(mean)', lpattern(dash) lcolor(edkblue)) ///
					xmlabel(`r(mean)' "Moyenne = `mean' FCFA", axis(2) labsize(vsmall) angle(0)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*1) ///
						name(paimentgraph)
	graph export "$EDLREFOR_out/Raw/paiementrecu.png", replace

	
	* how were the paiements used ???
	graph pie, over(use1)
	graph bar repartition1-repartition9, nolabel
	
	graph bar repartition1-repartition9 if tr!=3,  bargap(10) label ///
						bar(1,  fcolor(teal))  blabel(bar, format(%9.1g)) ///
						ytitle(Pourcentage) ///
						ytitle(, margin(medium)) ///
						legend (order(	1 "Acheter des habits"       ///                
										2 "Acheter des intrants agricoles"     ///          
										3 "Acheter des médicaments pour se soigner"  ///
										4 "Acheter des produits cosmétiques" ///
										5 "Acheter des vivres"        ///                 
										6 "Autres dépenses familiales"       ///     
										7 "Dépenses scolaires"      ///               
										8 "Faire de l'élevage"        ///           
										9 "Réparer son engin de déplacement (moto, vélo)") ///
									size(vsmall)) 			///			
						/// title("Can PES improve Household Food Security?") ///
						title("Les PSE peuvent-ils ameliorer la securite alimentaire?") ///
						/// subtitle("Most people who received PES transfers as part of the Burkina Faso FIP reforestation campaign in 2017" "indicated they would use it primarily towards food purchases for their households", size(vsmall))  ///
						subtitle("Une proportion importante des paysans beneficiaires des paiements PSE pour la maintenance des plants" "lors de la campagne de reforestation du PIF Burkina Faso en 2017 ont indique" "qu'ils utiliseront ces paiements pour l'achat de vivres", size(vsmall))  ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*1)	
	graph export "$EDLREFOR_out/Raw/paiementUses.png", replace
	
				summ use1, detail
				graph pie, over(use1) legend(size(small) lpattern(blank)) ///
				        plabel(_all percent, format(%9.0f) size(vsmall)) ///
						pie(_all, explode) ///
						title("Can PES improve Household Food Security?") ///
						subtitle("Most people who received PES transfers as part of the Burkina Faso FIP reforestation campaign in 2017" "indicated they would use it primarily towards food purchases for their households", size(small))  
				gr export 	"$EDLREFOR_out/Raw/TransfersUses.pdf", replace				
