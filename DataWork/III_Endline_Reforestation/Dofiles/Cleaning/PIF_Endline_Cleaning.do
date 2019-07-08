/* *************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
*         				PIF Burkina Faso		  					   		   *
*		  				Clean PIF Endline data						   		   *
*																	  		   *
* **************************************************************************** *
* **************************************************************************** *
 


** WRITTEN BY: Jonas Guthoff 			(jguthoff@worldbank.org)
			   Guigonan Serge Adjognon  (gadjognon@worldbank.org)

			   
** CREATED: 11/21/2018

	** OUTLINE:		0. Load data
					
					1. Merge Section C data, collected separately
					
					2. Clean the data Section by Section, and save construct data set
					
		
		
	** Requires:  	Enquete Reboisement PIF (Endline).dta
					
					Run III_Endline_Reforestation_MasterDofile.do to set the globals
	
	
	** Unique identifier: hhid
	
	

* ---------------------------------------------------------------------------- *
* 								0. Load data								   *
* ---------------------------------------------------------------------------- */



	* load the Section C data to format variables for a proper merge
	use "$EDLREFOR_dtRaw/Follow-up Section C/Follow-up Section C.dta", clear
		
	destring simid, replace
	
	
	* rename variables from SECTION C to merge and move over data
	foreach var in c1 c2 c2_alert c3 c3_1 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 ///
				  c15 c16 c17 c17_autre c17b c17b_autre c17c c17c_autre c18 	///
				  {
		rename `var' `var'_corr
		
		}
	
	

	save "$EDLREFOR_dtRaw/Follow-up Section C/Follow-up Section C_clean.dta", replace
	
	
	
	
	

********************************************************************************
* 						1. Merge Section C	& Move data over				   *
********************************************************************************

	

	* load the raw data from the surveyCTO import and after dropping duplicates
	use "$EDLREFOR_dtRaw/Enquete Reboisement PIF/Enquete Reboisement PIF (Endline).dta", clear


	* Generate the survey date
	gen 	surveydate  = dofc(starttime)
	format  surveydate %td

	* Generate survey time
	gen 	survey_time = (endtime-starttime)/(1000*60) // Time is in minutes
	replace survey_time = round(survey_time,.1) 
	
	* Submissiondate
	gen    	date 		= dofc(submissiondate)
	format 	date %td

	
	
	
	global iedup_identifiers "starttime survey_time enqueteur_name hhid traitement b1 b2 b3 surveydate date" 

	* implement the ieduplicates command	
	ieduplicates hhid,  folder("$EDLREFOR_HFC/HFCs_Output") uniquevars(key) keepvars("$iedup_identifiers")


	* save without duplicates
	save "$EDLREFOR_dtRaw/Enquete Reboisement PIF/Enquete Reboisement PIF (Endline)_no_dups.dta", replace

	* Merge in the Section C that was collected as part of the Follow-up due to the inconsistencies
	* where respondents reported to be farmers but without any land. We followed up with the 111 
	* and collected those in a separate from, which we merge here:
	
	merge 1:1 hhid using "$EDLREFOR_dtRaw/Follow-up Section C/Follow-up Section C_clean.dta"

		
	
	* br c1 c1_corr c2_alert c4 c6 c8 c10 c12 c14 c17 c17b c17c c18  if  b9==1 & c1==2
	
	* Move over the data 
	* 1.) Select_one or select_multiple
	
	foreach var in c1 c2_alert c4 c6 c8 c10 c12 c14 c17 c17b c17c     		{
					  
					
			replace `var' = `var'_corr 					if 	`var' != `var'_corr	 &  `var'_corr!=.
		}
		
	
	* br c1 c1_corr c2 c2_alert c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c17 c17b c17c c18  if  _merge == 3
				
		         
	
	* 2.) Numerics
	
	foreach var in c2  c3 c5 c7 c9 c11 c13 c18 {			  
			
			replace `var' =  `var'_corr					if `var' == . & `var'_corr	!=.	& `var' != `var'_corr
		
		}
	
	

	
	
	
	save "$EDLREFOR_dtRaw/Enquete Reboisement PIF/Enquete Reboisement PIF (Endline)_nodups+SecC.dta", replace

		
********************************************************************************
* Corrections  & Formatting of some major variables  						   *
********************************************************************************
	
	
	use  "$EDLREFOR_dtRaw/Enquete Reboisement PIF/Enquete Reboisement PIF (Endline)_nodups+SecC.dta", clear

	
	
	* Run the Correction do file based on HFCs
	do "$EDLREFOR_do/Cleaning/Corrections_PIF_Endline.do"
	


	
	* Destring some variables
	* br statut statut_name traitement traitement_num group_id

	foreach var in statut traitement_num {
		
		destring `var', replace		
	}	
	
	
	label define treatment 1 "Traitement collectif" 2 "Controle collectif" 3 "Traitement individuel" 4 "Controle individuel"
	label values traitement_num treatment
		
	label define treat 0 "Controle" 1 "Traitement"	
	label values statut treat
		
	label define treat_eng 0 "Control" 1 "Treatment"	
	label values statut treat
	
	
	* More specific treatment label
	label define treat_pes	0 "non-PES" 1 "PES"
	label values statut treat_pes

	

	
	
	* generate a treatment indicator, called treatment
	gen 	treatment = .
	replace treatment = 0
	replace treatment = 1					if statut == 1
	
	label values treatment treat_eng
	
	
	tab 	treatment statut
	
	
	* Also general cleaning, as this will become relevant in all sections to check the N
	* Check the Participants that were found -> the variable was introduced later, 
	* therefore clean accordingly that it reflects the correct number
	
	tab 	found_participant, miss
	
	tab 	stat_enq found_participant, miss
	
	order 	found_participant consent b9
	* br  										if found_participant == .
	* those that were found, have said yes to the consent and have answered to b9	
	replace found_participant = 1				if stat_enq == 1

	* total rate	
	tab 		found_participant, miss
	

	tab 		notfound_reason
	
	tab 		time_travel 	if notfound_reason == 3
	
	
	

	* Set global for identifiers, those vars that are important across sections
	global identifiers "date hhid found_participant  a1_region a2_site a3_village a4_bloc a5_parcelle b5 b6 b7 statut statut_name traitement traitement_num group_id treatment"			
						

						
						
		
	save "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", replace	

 	
 	
	/* Outsheet those that traveled or had another reason for why they were not found
	preserve 
	keep if found_participant == 2 & inlist(notfound_reason,3,4)
	drop if b3 == "99" & b4 == "99"
	br 		hhid repondent_fullname a1_region a2_site a4_bloc b3 b4 found_participant notfound_reason time_travel notfound_info if found_participant == 2 & inlist(notfound_reason,3,4)
	keep 	hhid repondent_fullname a1_region a2_site a4_bloc b3 b4 found_participant notfound_reason time_travel notfound_info
	gen 	Notes = ""
	order  	hhid repondent_fullname a1_region a2_site a4_bloc b3 b4 found_participant notfound_reason time_travel notfound_info Notes
	export 	excel "$EDLREFOR_HFC/HFCs_Output/Notfound_followup.xlsx",  replace  firstrow(variables)
	restore
	*/
	
	

* Clean from here on Section-by-Section

********************************************************************************
* SECTION A:  Identification du participant 			   					   *
********************************************************************************
		
	use "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", clear	
 
	
	sort a1_region a2_site a4_bloc a5_parcelle group_id
	* br 	 a1_region a2_site a4_bloc a5_parcelle group_id
	
	* keep only the Section relevant variables
	keep $identifiers a1_region - a5_parcelle
 
 
	
	* Check regions
	tab     a1_region   a1_region_confirm
	replace a1_region	= proper(a1_region)
	
	* Check Sites
	tab 	a2_site	    a2_site_confirm
	
	
	* Check Villages 
	tab 	a3_village	a3_village_confirm
	* -> 74 Incorrect villages from the baseline
	
	
	* Check Bloc
	tab 	a4_bloc		a4_bloc_confirm
	* ->  6 incorrect blocs recorded compared to the baseline
	
	


	save "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionA_clean.dta", replace 

 	
	
********************************************************************************
* SECTION B: Caractéristiques socio-démographique du participant  			   *
********************************************************************************

		
	use "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", clear	

	
	* Keep only relevant variables
	keep $identifiers b1 - b38_unit b9
	
	
	
	
	* Age -> already cleaned in the correction do file, we take the Age from the Endline as the
	*		 goldstandard, as supposedly more respondents possessed an ID
	
	* br 		b5 b5_confirm b5_correct
		
	summ 	b5, detail
	
	
	* Ethnicity
	tab 	b7

	
	tab b8a_1
	* 2 No's -> both sould be re-taken, confirm
	tab hhid 		if b8a_1 == 2
	
	
	tab b8c if statut == 0, miss
	 
	
	* Occupation
	tab b9
	
	* br b9	b9_autre		if b9_autre !=""
	
	
	* Revenu - the last 30 days
	summ 	b10, detail	
	replace b10 = `r(p50)'			if b10 < 0
	
	
	
	* Revenu - the last 12 months
	summ 	b11, detail
	replace b11 = `r(p50)'			if b11 < 0
	
	
	* Winsorize both revenu variables at the 1st and 99th percentile
	foreach var in b10 b11 {
		foreach value of numlist 1,3,5 {		
		winsor `var', gen(W0`value'_`var') p(0.0`value')
				
			}
		}
		
	
	summ W01_b10 W03_b10 W05_b10
	
	summ W01_b11 W03_b11 W05_b11
	
	* B.12  10 cailloux question ->  3 observations with a don't know
	* br 		b10 b11 b12 	if b12 == -999

	summ  	b12, detail
	replace b12 = `r(p50)'			if b12 < 0
	
	
	
	
	
	* Occupation 2nd
	tab 	   b13
	
	
	* Revenu 2nd -  last 30 days
	summ 	   b14, detail
	
	
	* br 		   b9 b10  b13 b14				if b10 == 0 & b14 > 0 & b14 !=.
	* -> issue, zero revenu from the first occupation and a positive one from the second
	
	summ 	   b14, detail
	replace    b14 = `r(p50)'			if b14 < 0 
	
	
	* Revenu 2nd -  last 12 months
	summ 	   b15, detail	
	replace    b15 = `r(p50)' 			if b15 < 0
	
	
	* Winsorize both revenu variables at the 1st and 99th percentile
	foreach var in b14  b15 {
		foreach value of numlist 1,3,5 {
		winsor `var', gen(W0`value'_`var') p(0.0`value')
			}
		}
		
		
	summ 	   W01_b14 W03_b14 W05_b14
		
	summ 	   W01_b15 W03_b15 W05_b15
	
	
	* Received a PIF paiment
	tab 	   b21
	
	* the sum received by PIF
	summ 	   b22, detail
	
	* Winsorize the values
	foreach value of numlist 1,3,5 {
		winsor b22, gen(W0`value'_b22) p(0.0`value')
		}
	
	


	* USAGES -> clean and check in the construct, clean with respect to the usage
	
	* Amount that is left
	summ 		b24, detail
	* replace 'dont know' with 0's in that case
	replace 	b24 = 0					if b24 < 0
	
	
 	
	* Remember member of your group
	tab 		b25, nolabel
	
	* recode to compute rates (0/1) 
	replace		b25 = 0					if b25 == 2
	
	label var 	b25 "Le participant se rappelle des membres de son équipe (Oui=1, Non=0)"
	
	* total group size
	destring	groupsize, replace
	
	summ		groupsize, detail
	
	label var 	groupsize "Nombre de membre dans l'équipe"
	
	* Membre connus
	destring 	no_membre_connu, replace
	
	summ		no_membre_connu, detail
	
	* label var 
	label var 	no_membre_connu "Nombre de membre connu"
	
	
	* in cases where they didnt recall all of them, we asked about the outstanding ones
	destring 	no_membre_dem, replace
	
	label var 	no_membre_dem	"Nombre de membre demandé"
	
	* add the 2 up t
	gen 		connu_total = no_membre_connu + no_membre_dem
	
	summ		connu_total, detail
	
	
	
	* Number of reunions - to discuss
	summ		b27, detail
	
	
	* Number of reunions - to maintain the parcelles	
	summ 		b28, detail
	

	

	summ 		b30, detail
	* replace 'dont know' with 0's in that case
	replace 	b30 = 0					if b30 == -999
	
	
	
	* B.34 Quelle est votre évaluation du niveau de collaboration entre vous et 
	*	   le reste de votre groupe dans la cadre des activités d'entretien des plants ?
	tab  		b34, sort

	
	* Distance to the parcelle
	summ    	b35, detail
	
	* replace 'don't know's' with the median
	replace 	b35 = `r(p50)'      	if b35 < 0
	
	
	* B.36 Evaluate the distance
	tab			b36, sort
	
	
	* Travel time
	* br  		b38 b38_unit
	* generate a travel time variable, and convert the travel time into minutes
	gen		 	travel_time = 0				if b38 !=.
	replace  	travel_time = b38				if b38 !=. & b38_unit == 1
	replace  	travel_time = b38 * 60			if b38 !=. & b38_unit == 2
	
	* replace the 'don't knows' again with the median
	summ 	 	travel_time, detail	
	replace  	travel_time = `r(p50)'			if travel_time < 0
	
	
	
	
	
	

	save "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionB_clean.dta", replace	
	
	

*******************************************************************************************
* SECTION C: ACTIVITES AGRICOLES ET NON-AGRICOLE DU MENAGE au cours des 12 derniers mois *
*******************************************************************************************

	
	use "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", clear	
	
	* keep only relevant variables
	keep $identifiers c1 - c21
	
	
	* in ownership of land
	tab 	c1
	
	
	* land surface
	summ 	c2, detail
	* replace the 'don't know's' with the median value
	replace c2 = `r(p50)'		if c2 < 0
	
	summ 	c2, detail
	
	
	* land cultivated
	summ 	c3, detail
	* replace the 'don't know's' with the median value
	replace c3 = `r(p50)'		if c3 < 0
	
	summ 	c3, detail
	
	
	* Clean values for different inputs
	foreach input of numlist   5,7,9,11,13 {		
		summ	 c`input', detail
		replace  c`input' = `r(p50)'		if c`input' < 0
		}
	
		* Winsorize values at 1st and 99th percentile
		foreach input of numlist   5,7,9,11,13 {		
			foreach value of numlist 1,3,5 {
			winsor  c`input', gen(W0`value'_c`input')	p(0.0`value')
				}
			}
			
		* Check the distributions again
		foreach input of numlist   5,7,9,11,13 {		
			summ	 c`input', detail
			}
		
		* -> how do these values compare with the revenue -> compute in the construct dofile
	
	
	
	
	
	* Investments
	summ 	c16, detail
	
	
	* Value of agric. production -> replace 'don't know's' with the median value
	summ 	c18, detail
	replace c18 = `r(p50)'		if c18 < 0
	
	
	* Value of non-agric. production
	summ 	c21, detail
	replace c21 = `r(p50)'		if c21 < 0
	
	

	
	
	

	save "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionC_clean.dta", replace	

	
	
********************************************************************************
* SECTION D: Sécurité Alimentaire des Ménages  								   *
********************************************************************************

	
	use "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", clear	
	
	
	* keep only relevant variables
	keep $identifiers 	da1 - db342
	
	
	
	* Check the binary food section
	* br da1-da42 if  found_participant == 1
	
	
	* Check the quantities
	* br db11 - db342 if  found_participant == 1
	
	
	
	
	save "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionD_clean.dta", replace	

	
* ------------------------------------------------------------------------------
* PART D2: MOIS AU COURS DESQUELS L’APPROVISIONNEMENT DU MENAGE EN NOURRITURE A ETE INSUFFISANT 
* ------------------------------------------------------------------------------

	
	use "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", clear	
	
	* keep only relevant variables
	keep $identifiers  d2_1 - d2_12b
	
	
		
	tab		d2_1 													if  found_participant == 1
	* -> 50 percent report Yes
	
	
	* br oct_2017 - sept_2018	d2_1a - d2_12b							if  found_participant == 1 & d2_1 == 1


	
	
	

	save "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionD2_clean.dta", replace	
	
	
* ------------------------------------------------------------------------------
* PART D3: ECHELLE DE LA FAIM DANS LE MENAGE (HOUSEHOLD HUNGER SCALE)   	   *
* ------------------------------------------------------------------------------

	
	use "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", clear	
	
	* keep only relevant variables
	keep $identifiers d3_1a - d3_10
	
	
	* Hunger scale  -> is there for all 556 

	* br d3_1a - d3_10						if found_participant == 1
	
	
	* Clean the those with -777 and -999
	
	* br 	d3_9 d3_10 				if  found_participant == 1
	
	summ 	d3_9, detail
	
	* replace those with no children to missing
	foreach var in d3_9 d3_10 {
		replace `var' = .			if `var' == -777
		}
		
		
	* replace the dont knows with the median
	foreach var in d3_9 d3_10 {
		
		summ 	`var' if `var' < 10, detail	
		
		replace `var' = `r(p50)' 		if inlist(`var',999,-999)
		}
	
	* for those above 7, assume that calculation errors were made and use 7
	foreach var in d3_9 d3_10 {
		replace `var' = 7		if `var' > 7	& `var'  !=.
		}
		

	
	
	save "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionD3_clean.dta", replace	
	

********************************************************************************
* SECTION E: CAPITAL SOCIAL - CONFIANCE AUX INSTITUTIONS LOCALES   	   		   *
********************************************************************************

	
	use "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", clear	
	
	
	* Keep only relevant variables
	keep $identifiers b25 no_membre_connu no_membre_dem e1 - e9
		
		
	destring no_membre_connu, replace
	destring no_membre_dem, replace
		

		
	
	* br e1 - e9								if found_participant == 1 
	
	
	
	
	
	
	
	
	save "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionE_clean.dta", replace	
	
		
	
********************************************************************************
* SECTION F: PERCEPTION DE LA VALEUR ENVIRONNEMENTALE ET PREFERENCES 	   	   *
********************************************************************************

	
	use "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", clear	
	
	
	* keep only relevant vars
	keep $identifiers f1 - f10
	
	
	* br f1 - f10								if found_participant == 1 
	
	
	

	

	save "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionF_clean.dta", replace	
	
		
********************************************************************************
* SECTION G: PREFERENCES PAR RAPPORT AU RISQUE 	   	   						   *
********************************************************************************
	
		
	use "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", clear	
	
	
	* keep only relevant variables
	keep $identifiers g1 - g3 
	
	* br g1 -g3								if found_participant == 1 



	
	
	save "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionG_clean.dta", replace	
	
	
********************************************************************************
* Fin d'enquete
********************************************************************************	
	
		
	use "$EDLREFOR_dt/Intermediate/PIF_Endline_corrected.dta", clear	
	
	
	* keep only relevant variables
	keep $identifiers stat_enq - lieu_pourquoi
	
	
	
	
	
	
	
	save "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_Fin_clean.dta", replace	
	
	
	
	
********************************************************************************
* End of the Do file														   *
********************************************************************************
	
	
	
	
	
	
	
	
	
	
