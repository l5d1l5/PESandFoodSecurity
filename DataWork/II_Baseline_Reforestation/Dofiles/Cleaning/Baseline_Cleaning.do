
* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *		
*          DATA CLEANING & DETECTING OF ISSUES DO FILE 					  	   *
*          This do file contains CLEANING of the 				 			   *
*          Burkina Faso Forestry Baseline  						   			   *
*                                                                      		   *
* **************************************************************************** *
* **************************************************************************** *
	

	* Project: 	Additional data cleaning steps for the Burkina Faso Baseline Report
	* Author: 	Jonas Guthoff (jguthoff@worldbank.org)
	* Date: 	September-October, 2018

	* Content: 	This do file contains the cleaning from the Burkina Faso Forestry project.
	*			The cleaned data will be pulled again in the Baseline_Construct.do for 
	*			the construction of indicators that will be outsheeted in the Baseline_Analysis.do				

	*			We proceed in this do file in a Section-by-Section approach 

	
	* OUTLINE: 1. Load data
	*		   2. Section A - Identification of the participant 
	*		   3. Section B - Socio-demographic characteristics
	*		   4. Section C - Assets
	*		   5. Section D - Economic Activity
	*		   6. Section E - Food Consumption
			 
			 
			   
	* Data:  				participant_survey_raw.dta  
	* Unique Identifier: 	objectid		   
	
	* Requires : Run II_Baseline_Reforestation_MasterDofile.do first to set all the globals


	

********************************************************************************
** INTRO
********************************************************************************

	
		use "$BSLREFOR_dt/raw/participant_survey_raw.dta" , clear
	
		
		duplicates list objectid
	
	
		decode village, gen(village_str)
	
		
		
		
	

	/* Save the data to merge to the Endline to track progress
	preserve
	keep   objectid region region foret bloc traitement parcelle village nom prenom age sexe contact_tr contact1 contact2
	rename objectid hhid 
	save "$BSLREFOR_dt/raw/baseline_sample.dta", replace
	restore
	*/
	

********************************************************************************
** Intro - Baseline Survey
********************************************************************************


		use "$BSLREFOR_dt/raw/participant_survey_raw.dta" , clear
	
		
		* generate hhig
		rename objectid hhid
	
		* Generate 1 treatment indicator	
		tab traitement, miss nolabel
		
		* Parcelle
		tab parcelle, miss
		
		tab parcelle  traitement
		
		tab traitement parcelle  
		
		rename  	statut treatment 
		label 	variable treatment "Respondent's treatment status"
		
		tab treatment 
		
		
		* Region
		tab region, miss
		
				
		* Foret 
		tab foret, miss
		
		* Bloc
		encode bloc, gen(blocid)
		order blocid, a(bloc)
		label variable blocid "Foret bloc id"
		tab blocid, nol
		
		* Parcelle
		encode parcelle, gen(parcelid)
		order parcelid, a(parcelle)
		label variable parcelid "Parcel id"
		tab parcelid, nol
		
		
		* Village
		tab village, miss

		
		* Set a global with the key variables
		global BSLREFOR_ID "hhid region foret bloc parcelle village treatment"
		
		
		save "$BSLREFOR_dt/raw/participant_survey_clean.dta" , replace
		
	
	
********************************************************************************
** SECTION A - IDENTIFICATION OF THE PARTICIPANT
********************************************************************************


		use "$BSLREFOR_dt/raw/participant_survey_clean.dta" , clear
	
		
		* Keep only relevant variables
		keep $BSLREFOR_ID  date_enq
		
		
 
		save "$BSLREFOR_dt/Intermediate/SectionA_clean.dta" , replace


********************************************************************************
** SECTION B - SOCIO - DEMOGRAPHIC CHARACTERISTCS
********************************************************************************


		use "$BSLREFOR_dt/raw/participant_survey_clean.dta" , clear
	
		
		* Keep only relevant variables
		keep $BSLREFOR_ID age sexe sbq9 - sbq25_autre
		
 
		* Age
		summ age, detail
			
		tab sexe	
 
		tab sexe, nolabel
	
	 
		* Occupation 
		tab sbq9, nol
	
		* br sbq9 sbq9_autre if sbq9_autre!=""
			
			
		* Revenue from primary activity in the last 30 days/ 12 months
		summ sbq10, detail
		summ sbq11, detail
		
		codebook sbq10, detail
		codebook sbq11, detail
		

		* Share revenu principale in total revenu
		replace sbq12=. if sbq12<1 | sbq12>10
		summ sbq12, detail
		replace sbq12 = `r(p50)'		if sbq12 ==.		
		
		tab sbq12
		
		
		* Secondary occupation
		tab sbq13, miss
		* -> missing
		
		* br sbq13 sbq13_autre if sbq13_autre!=""
		* -> some Jardaniers, project related?
		
		
		* Revenue total, secondary activity
		tab sbq14, miss
		
		
		* Winsorize monetary values at the highest 1 percent
		foreach var in sbq10 sbq11 sbq14 sbq15 {
				
				summ `var', detail
				replace `var' = `r(p50)'			if `var'<0
				
				winsor `var', gen(W`var') highonly p(0.01)
			}	
				
				* French labels
				label var Wsbq10 "Revenu total de l'occupation principale (30 derniers jours)†"
				label var Wsbq11 "Revenu total de l'occupation principale (12 derniers mois)†"
				label var Wsbq14 "Revenue total de l'occupation secondaire (30 derniers jours)†"
				label var Wsbq15 "Revenue total de l'occupation secondaire (12 derniers mois)†"
		
				/* English labels
				label var Wsbq10 "Total income from primary occupation (last 30 days)†"
				label var Wsbq11 "Total income from primary occupation  (last 12 months)†"
				label var Wsbq14 "Total income from secondary occupation (last 30 days)†"
				label var Wsbq15 "Total income from secondary occupation (last 12 months)†"
				*/
			
		
	 	
	
		* br sbq9 sbq10 Wsbq10 Wsbq11 if sbq10 == 0
		
		* Married
		tab sbq16
 
	
		* Nomber de membre de menage
		tab sbq17
		* -> one with zero members
		replace sbq17 = 1		if sbq17==0
		
		
		
		* Issue with the transport variables
		tab sbq24 
		
		tab sbq24 
		tab sbq24   if treatment==1
		tab sbq24 	if treatment==0
		
			
		tab sbq25
	
		tab sbq25	if treatment==1
		tab sbq25	if treatment==0
		
		
		foreach var in sbq24  sbq25 {
			
			summ `var', detail
			replace `var' = `r(p50)'		if `var' ==.
			
		}	
		
		
		
		
		save "$BSLREFOR_dt/Intermediate/SectionB_clean.dta" , replace



********************************************************************************
** SECTION C - ASSETS
********************************************************************************


		use "$BSLREFOR_dt/raw/participant_survey_clean.dta" , clear
	
	
	
		* Keep only relevant variables
		keep $BSLREFOR_ID  scq1_100 - scq6a_307
	
	
		* Clean Assets to form an Asset Index
			* Clean by Asset Group - code to binary 0/1 variables
			
			* a) Agricultural Asssets
			*  br scq1_100 scq1_101 scq1_102 scq1_103 scq1_104 scq1_105 scq1_106 scq1_107 scq1_108 scq1_109 scq1_110 scq1_111 scq1_112 scq1_113 scq1_114 scq1_115 

			tab scq1_100, nolabel
			
				* Replace the No's to zeros to compute the Asset Indicator
				foreach var in scq1_100 scq1_101 scq1_102 scq1_103 scq1_104 scq1_105 scq1_106 scq1_107 scq1_108  ///
							   scq1_109 scq1_110 scq1_111 scq1_112 scq1_113 scq1_114 scq1_115 {
			
					replace `var' = 0			if `var' == 2
					}
			
		
			
			* b) Household Assets
			*  br scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228 
			
				* Replace the No's to zeros to compute the Asset Indicator
				foreach var in scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 					///
							   scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 					///
							   scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228	{
							   
					replace `var' = 0			if  `var' == 2 
					}		   
							   
			
			
			* c) Livestock
			*  br scq5_300 scq5_301 scq5_302 scq5_303 scq5_304 scq5_305
		
					* Replace the No's to zeros to compute the Asset Indicator
				foreach var in 	scq5_300 scq5_301 scq5_302 scq5_303 scq5_304 scq5_305 {
							   
					replace `var' = 0			if  `var' == 2 
					}		   
									

				

 
		save "$BSLREFOR_dt/Intermediate/SectionC_clean.dta" , replace



********************************************************************************
** SECTION D - ECONOMIC ACTIVITY
********************************************************************************


		use "$BSLREFOR_dt/raw/participant_survey_clean.dta" , clear
	
	
		* Keep only relevant variables
		keep $BSLREFOR_ID sdq1 - sdq19_h 
	
	
		* 1.) Agricultural Production
		
			* a) Land
			*  br sdq1 sdq2 sdq3  if sdq1==.
			
				* replace No's to zero's for rates
				replace sdq1 = 0		if sdq1==2
				
			
			tab sdq1
			
			* English
			*label var sdq1 "Houshold owned land (within last 12 months)"
				
			* French
			label var sdq1 "Ménage posséde des terres (pendant ces 12 derniers mois)"
			
				
				
				* Winsorize the land owned and the surface cultivated
				summ sdq2, detail
			
				summ sdq3, detail
				
					winsor sdq2, gen(Wsdq2) highonly p(0.01)
			
					winsor sdq3, gen(Wsdq3) highonly p(0.01)
				
					summ Wsdq2, detail
					
					summ Wsdq3, detail
					
					* label french
					label var Wsdq2 "Superficie totale de terres à disposition du ménage (in ha)†"
					label var Wsdq3 "Superficie totale cultivé par le ménage au cours de la saison agricole en cours (in ha)†"
					
					
					/* label English
					label var Wsdq2 "Surface owned by household (in ha)†"
					label var Wsdq3 "Surface cultivated during the current season (in ha)†"
					*/
					
			
			* Valeur production totale
					summ sdq18, detail
			
		
					winsor sdq18, gen(Wsdq18) highonly p(0.01)
		
						summ Wsdq18, detail
						
						* French
						label var Wsdq18 "Valeur totale de la production agricole au cours de la saison agricole passée (en FCFA)†"
						
						
						* English
						*label var Wsdq18 "Total value of agricultural production in the last season (en FCFA)†"
					
		
			* b) Input Use
			* br  sdq4 sdq5 sdq6 sdq7 sdq8 sdq9 sdq10 sdq11 sdq12 sdq13 
				
				* Improved Seeds
					tab sdq4
					
					summ sdq5, detail
					
				* Non-organic fertilizer
					tab sdq6
					
					summ sdq7, detail
					
					*  br sdq6  sdq7		if sdq6==2 & sdq7!=.
					* 1 household said not, but recorded value 0 -> switch to missing
					replace sdq7 = .	if sdq6==2 & sdq7!=.
					
			
				* Organic fertilizer
					tab sdq8 
					
					summ sdq9, detail
					
									
				* Pesticides
					tab sdq10 
					
					summ sdq11, detail
					
					
							
					
				* Labor
					tab sdq12 
					
					summ sdq13, detail 
				
					* br  sdq12  sdq13		if sdq13==0
					* 1 household says Labor was hired, but for value 0 -> recode response to NO
					replace sdq12 = 2		if sdq13==0
					replace sdq13 =. 		if sdq12==2 & sdq13==0
					
					
						* Winsorize all input values
						foreach var in sdq5  sdq7  sdq11 sdq13 {
							winsor `var', gen(W`var') highonly p(0.01)
							}
					
			
						* Label values and translate -> everything referred to the current saison
						
						* French
						label var sdq4   	"Utilise des semances améliorée (Oui = 1, Non = 0)"
						label var Wsdq5   	"Valeur totale des semances améliorée (en FCFA)†"
						label var sdq6   	"Utilise des engrais chimiques (Oui = 1, Non = 0)"
						label var Wsdq7 	"Valeur totale des engrais chimiques (en FCFA)†"
						label var sdq8 		"Utilise des engrais organiques (Oui = 1, Non = 0)"
						label var sdq9 		"Valeur totale des engrais organiques(en FCFA)"
						label var sdq10 	"Utilise des produits phytosanitaires (Oui = 1, Non = 0)"
						label var Wsdq11 	"Valeur totale des produits phytosanitaires (en FCFA)†"
						label var sdq12 	"Loué/acheté de la main d'œuvre (Oui = 1, Non = 0)"
						label var Wsdq13 	"Valeur totale de la main d'œuvre (en FCFA)†"
			
						
						/* English
						label var sdq4   	"Use improved seeds (Yes = 1, No = 0)"
						label var Wsdq5   	"Total value of improved seeds (in FCFA)†"
						label var sdq6   	"Use non-organic fertilizer (Yes = 1, No = 0)"
						label var Wsdq7 	"Total value of non-organic fertilizer (in FCFA)†"
						label var sdq8 		"Use organic fertilizer (Yes = 1, No = 0)"
						label var sdq9 		"Total value of non-organic fertilizer (in FCFA)"
						label var sdq10 	"Use pesticides (Yes = 1, No = 0)"
						label var Wsdq11 	"Total value of pesticides (in FCFA)†"
						label var sdq12 	"Labor hired (Yes = 1, No = 0)"
						label var Wsdq13 	"Total value of labor hired (in FCFA)†"
						*/
						
			
			
			
			
			
						* Code the No's to zero to compute rates
						foreach var in sdq4 sdq6 sdq8 sdq10 sdq12  {
							replace `var' = 0		if `var'==2
							}	
						
						* We replace the values with median 
						foreach var in Wsdq5 Wsdq7 sdq9 Wsdq11 Wsdq13 {
							summ `var', detail
							replace `var' = `r(p50)'		if `var' == 0
							}
						
						
						

				* Main source of financing: 
					tab sdq17
		
					* French
					label define financement 1 "Epargne du ménage" 2 "Cadeau d’un parent" 3 "Prêt d’un autre ménage" 4 "Prêt d’une tontine" 5 "Prêt bancaire ou IMF" 6 "Prêt/Appui d’une coopérative" 7 "Prêt/Appui d’une ONG" 8 "Autres"
					label values sdq17	financement	
					
					/* English
					label define financement 1 "Savings of the HH" 2 "Gift by a parent" 3 "Loan from anothe HH" 4 "Savings club" 5 "Bank credit or IMF" 6 "Loan from a cooperative" 7 "Loan from an NGO" 8 "Other"
					label values sdq17	financement	
					*/
					
					
 
		* 2.) Non-Agricultural prodcution
			
			tab sdq19_a, miss
			
			* br sdq19_a  sdq19_b sdq19_c sdq19_d sdq19_e sdq19_f sdq19_g sdq19_h
 
			* Generate (0/1) Indicators for each of the activities
			foreach letter in a b c d e f g h {
				replace sdq19_`letter' = 0 			if sdq19_`letter'==2
				}
		
				* French variables label 
				label var sdq19_a   "Transformation de produits agricoles ou animaux"     
				label var sdq19_b 	"Confection/ Réparation des tissus ou vêtements, chaussures"
				label var sdq19_c	"Construction de maisons, menuiserie, forge, confection de briques"
				label var sdq19_d	"Commerce"
				label var sdq19_e 	"Professions libérales pour son propre compte"
				label var sdq19_f	"Domaine du transort"
				label var sdq19_g	"Domaine des Hôtels, Bars, restaurants"
				label var sdq19_h	"Autres activités non agricoles"
				
				
				/*  English variables label
				label var sdq19_a   "Transformation of agricultural products and livestock"     
				label var sdq19_b 	"Tailor, shoemaker"
				label var sdq19_c	"Construction"
				label var sdq19_d	"Trade"
				label var sdq19_e 	"Self-employed"
				label var sdq19_f	"Transort"
				label var sdq19_g	"Hotel, bar, restaurant"
				label var sdq19_h	"Other non-agricultural activities"
				*/ 
 
 
 


 
		save "$BSLREFOR_dt/Intermediate/SectionD_clean.dta" , replace




********************************************************************************
** SECTION E - FOOD CONSUMPTION
********************************************************************************


		use "$BSLREFOR_dt/raw/participant_survey_clean.dta" , clear
	
	
		* Keep only relevant variables
		keep $BSLREFOR_ID 	 seq1_1 - seq4c_41
		
		
		
		
		* 1.) Food Consumption

		/* Check for completeness of variables and label vars to English
		br seq1_1 seq1_2 seq1_3 seq1_4 seq1_5 seq1_6 seq1_7 seq1_8 seq1_9 seq1_10 seq1_11 		///
		   seq1_13 seq1_14 seq1_15 seq1_16 seq1_17 seq1_18 seq1_19 seq1_20 seq1_21 seq1_22 		///
		   seq1_23 seq1_24 seq1_25 seq1_26 seq1_27 seq1_28 seq1_29 seq1_30 seq1_31 seq1_32 		///
		   seq1_33 seq1_34 seq1_35 seq1_36 seq1_37 seq1_38 seq1_39 seq1_40 seq1_41
		*/
			
			
			* FRENCH LABELS
			* Relabel + Translate
			label var seq1_1 	"Mais"
			label var seq1_2 	"Mill"
			label var seq1_3 	"Riz"
			label var seq1_4 	"Sorgho"
			label var seq1_5 	"Fonio"
			label var seq1_6 	"Manioc"
			label var seq1_7 	"Pâtes alimentaires"
			label var seq1_8 	"Oignon frais"
			label var seq1_9 	"Gombo"
			label var seq1_10 	"Tomate"
		
		
			label var seq1_11 	"Poivron"
			*label var seq1_12  "Autre légumes frais n.d.a." 	/// Missing
			label var seq1_13 	"Arachide"
			label var seq1_14 	"Soumbala"
			label var seq1_15 	"Feuilles de baobab"
			label var seq1_16 	"Sel"
			label var seq1_17 	"Piment"
			label var seq1_18 	"Igname"
			label var seq1_19 	"Pomme de terre"
			label var seq1_20 	"Patate douce"
		

			label var seq1_21 	"Mangue"
			label var seq1_22 	"Orange"
			label var seq1_23 	"Banane"
			label var seq1_24 	"Noix de cola"
			label var seq1_25 	"Viande de bœuf"
			label var seq1_26 	"Viande de mouton"
			label var seq1_27 	"Viande de chèvre"
			label var seq1_28 	"Volailles"
			label var seq1_29 	"Gibier"
 			label var seq1_30 	"Poisson"

 
 
 			label var seq1_31 	"Huile alimentaire"
			label var seq1_32 	"Beurre de karité"
			label var seq1_33 	"Œufs"
			label var seq1_34 	"Lait"
			label var seq1_35 	"Sucre"
			label var seq1_36 	"Miel"
			label var seq1_37 	"Tabac"
			label var seq1_38 	"Cigarette"
			label var seq1_39 	"Café"
			label var seq1_40 	"Thé"

 			label var seq1_41 	"Boissons alcooliques"

 
			
			/* English labels
			label var seq1_1 	"Maize"
			label var seq1_2 	"Millet"
			label var seq1_3 	"Rice"
			label var seq1_4 	"Sorghom"
			label var seq1_5 	"Fonio"
			label var seq1_6 	"Cassava"
			label var seq1_7 	"Pasta"
			label var seq1_8 	"Onions"
			label var seq1_9 	"Okra"
			label var seq1_10 	"Tomatoes"
		
		
			label var seq1_11 	"Bell pepper"
			*label var seq1_12  "Local vegetables" 	/// Missing
			label var seq1_13 	"Groundnut"
			label var seq1_14 	"Soumbala"
			label var seq1_15 	"Leaves of baobab"
			label var seq1_16 	"Salt"
			label var seq1_17 	"Piment"
			label var seq1_18 	"Yam"
			label var seq1_19 	"Patato"
			label var seq1_20 	"Sweet Patato"
		

			label var seq1_21 	"Mango"
			label var seq1_22 	"Orange"
			label var seq1_23 	"Banana"
			label var seq1_24 	"Kola nut"
			label var seq1_25 	"Beef"
			label var seq1_26 	"Sheep"
			label var seq1_27 	"Goat"
			label var seq1_28 	"Poultry"
			label var seq1_29 	"Game"
 			label var seq1_30 	"Fish"

 
 
 			label var seq1_31 	"Oil"
			label var seq1_32 	"Butter"
			label var seq1_33 	"Eggs"
			label var seq1_34 	"Milk"
			label var seq1_35 	"Sugar"
			label var seq1_36 	"Honey"
			label var seq1_37 	"Tobacco"
			label var seq1_38 	"Cigarettes"
			label var seq1_39 	"Café"
			label var seq1_40 	"Tea"

 			label var seq1_41 	"Alcoholic beverages"
			*/
			
 
 

 
		save "$BSLREFOR_dt/Intermediate/SectionE_clean.dta" , replace

 
 


********************************************************************************
** 
********************************************************************************




	
	
