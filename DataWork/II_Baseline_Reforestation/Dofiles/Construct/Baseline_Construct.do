* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *		
*          CONSTRUCT DO FILE 					  	   						   *
*          This do file contains CLEANING of the 				 			   *
*          Burkina Faso Forestry Baseline  						   			   *
*                                                                      		   *
* **************************************************************************** *
* **************************************************************************** *
		
	* Author: 	Jonas Guthoff (jguthoff@worldbank.org)
	* Created:  12/09/2018


	
	* Unique identifiers: hhid
	* OUTLINE: CONSTRUCT DATA, Module-by-Module	
	* This do file uses the "clean" data Baseline_raw_nodups.dta generated in the Cleaning.do
	* Here we construct the variables and indicators that will be used in the 
	* Analysis.do

	
	* requires : Run II_Baseline_Reforestation_MasterDofile.do first to set all the globals
	
	
		
********************************************************************************
** SECTION A - IDENTIFICATION OF THE PARTICIPANT
********************************************************************************


		use "$BSLREFOR_dt/Intermediate/SectionA_clean.dta" , clear
	
 
 
 
		save "$BSLREFOR_dt/Intermediate/SectionA_construct.dta" , replace


********************************************************************************
** SECTION B - SOCIO - DEMOGRAPHIC CHARACTERISTCS
********************************************************************************


		use "$BSLREFOR_dt/Intermediate/SectionB_clean.dta" , clear
	
	
		* Construct Binary Variables to display descriptives on the households surveyed
		
				* Age
				tab age
				label variable age "Age of respondent"
		 
				* Gender
				generate female=sexe==2
				label variable female "Female respondent (1/0)"		
				tab female
		 
				* PRIMARY Activity
				tab sbq9
				
				gen farmer = 0
				replace farmer= 1			if sbq9==1
				label var farmer "Agriculture as primary activity (1/0)"
				
				gen revenu1=sbq11/1000
				replace revenu1=0 if sbq9==0
				gen Lrevenu1= log(revenu1+0.000000001)
				label variable revenu1  "Annual revenu from primary activity (*1000 FCFA)"
				label variable Lrevenu1 "Annual revenu from primary activity (LOG)"
								
				* Overall annual revenu
				gen revenu_tot=revenu1*10/sbq12*1000
				winsor revenu_tot, gen(Wrevenu_tot) highonly p(0.01)
				gen Lrevenu_tot= log(revenu_tot+0.000000001)
				label variable revenu_tot  "Annual total revenu (*1000 FCFA)"
				label variable Wrevenu_tot  "Annual total revenu (*1000 FCFA)†"		
				label variable Lrevenu_tot "Annual total revenu (LOG)"	
				
				* Secondary activity
				gen sec_activity=sbq14!=. & sbq14!=0 & sbq9!=sbq13
				label variable sec_activity "Has a secondary activity (1/0)"
				
				* Matrimonial situation
				generate married=sbq16==2 | sbq16==3
				label variable married "Married (1/0)"
				
				gen monogamous = sbq16==2 & married==1
				label var monogamous	"Married monogamous (1/0)"		
				
				gen polygamous =sbq16==3 & married==1
				label var polygamous	"Married ploygamous (Yes = 1, No = 0)"				
				
				* Household size
				gen hsize=sbq17
				label variable hsize "Household size"
				
				* Respondent is chef du menage
				gen chief=sbq18==1 
				label var chief 	"Respondent is the Head of the household (1/0)"				
				
				* Education
				gen schooling=sbq21!=1
				label variable schooling "Some formal schooling (1/0)"
				
				* GGF membership
				gen GGF_member=sbq22==1
				label variable GGF_member "Member of a forest management group (1/0)"
				
				* Distance to parcelle
				gen dist_far=sbq24==1 | sbq24==2
				label variable dist_far "Homestead far from the reforestation site (1/0)"
				
				gen motor=sbq25==3 
				label variable motor "Motorcycle as primary means of transportation (1/0)"

	
	
		save "$BSLREFOR_dt/Intermediate/SectionB_construct.dta" , replace



********************************************************************************
** SECTION C - ASSETS
********************************************************************************



		use "$BSLREFOR_dt/Intermediate/SectionC_clean.dta" , clear
			
			
		** Generate the Asset Indices
		
		* 1) Simpel Sums
		* 2) Using Principal Component Analysis
		
			
		* Generate Asset Index
		
			* a) Agricultural Asssets Indicator
			* br scq1_100 scq1_101 scq1_102 scq1_103 scq1_104 scq1_105 scq1_106 scq1_107 scq1_108 scq1_109 scq1_110 scq1_111 scq1_112 scq1_113 scq1_114 scq1_115 		
		
			egen assets_agri_sum = rowtotal(scq1_100 scq1_101 scq1_102 scq1_103 scq1_104 scq1_105 scq1_106 scq1_107 scq1_108 scq1_109 scq1_110 scq1_111 scq1_112 scq1_113 scq1_114 scq1_115)

			* br scq1_100 scq1_101 scq1_102 scq1_103 scq1_104 scq1_105 scq1_106 scq1_107 scq1_108 scq1_109 scq1_110 scq1_111 scq1_112 scq1_113 scq1_114 scq1_115 		 if assets_agri_sum==0
			
			* French label
			* label var assets_agri_sum 		"Indice des actifs agricoles (sum)"
			
			* English label
			label var assets_agri_sum 		"Asset Index (sum)"
			
			
			
 	
			* b) Household Assets
			* br scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228 
		
			egen assets_house_sum = rowtotal(scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228)

			* br scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228  if assets_house_sum==0
			
			
			* French label
			*label var assets_house_sum 		"Indice des actifs du ménage (sum)"
			
			* English label
			label var assets_house_sum 		"Household Asset Index (sum)"
 
 
 
 
 			* c) Livestock
			* br scq5_300 scq5_301 scq5_302 scq5_303 scq5_304 scq5_305

			egen assets_livestock_sum = rowtotal(scq5_300 scq5_301 scq5_302 scq5_303 scq5_304 scq5_305)
			
			* French
			*label var assets_livestock_sum "Indice des actifs du bétail (sum)"
			
			* English
			label var assets_livestock_sum "Livestock Asset Index (sum)"
			
			
			
				
	* a) Agricultural Asssets Indicator
	* br scq1_100 scq1_101 scq1_102 scq1_103 scq1_104 scq1_105 scq1_106 scq1_107 scq1_108 scq1_109 scq1_110 scq1_111 scq1_112 scq1_113 scq1_114 scq1_115 		

	
		pca scq1_100 scq1_101 scq1_102 scq1_103 scq1_104 scq1_105 scq1_106 scq1_107				///
			scq1_108 scq1_109 scq1_110 scq1_111 scq1_112 scq1_113 scq1_114 scq1_115, comp(2)
	
	
		* Analyse en composantes principales
		rotate	
		
		predict 	asset_agr_index
		sum 		asset_agr_index
		* screeplot 
		label var	asset_agr_index 	"PCA analysis - First component"
		tab 		asset_agr_index	
 	
		* screeplot, ci(asympt level(95)) mean scheme(lean2)

		* loadingplot
	
		tab asset_agr_index

		ttest asset_agr_index, by(treatment)
		
		* French
		*label var asset_agr_index		"Indice des actifs agricoles (ACP)"
	
		* English
		label var asset_agr_index		"Agric. Asset Index (PCA)"
		
			
			
		
	* b) Household Assets
	* br scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228 
		
	
	
		pca scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 scq3_209 	///
			scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 scq3_218 scq3_219 	///
			scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228, comp(2) 
			
			
	
		rotate	
		
		predict 	asset_hh_index
		sum 		asset_hh_index
		* screeplot 
		*label var	asset_hh_index 		"ACP des actifs - Premiere composante"
		tab 		asset_hh_index	
 	
		* screeplot, ci(asympt level(95)) mean scheme(lean2)

		* loadingplot
	
		tab asset_hh_index

		ttest asset_hh_index, by(treatment)
		
		* French label
		*label var asset_hh_index		"Indice des actifs du ménage (ACP)"

		
		* English label
		label var asset_hh_index		"Household Asset Index (PCA)"
		

	
	
	* c) Livestock
	* br scq5_300 scq5_301 scq5_302 scq5_303 scq5_304 scq5_305
	
		pca scq5_300 scq5_301 scq5_302 scq5_303 scq5_304 scq5_305, comp(2)
			
	
		rotate	
		
		predict 	asset_live_index
		sum 		asset_live_index
		* screeplot 
		label var	asset_live_index 	"ACP des actifs - Premiere composante"
		tab 		asset_live_index	
 	
		* screeplot, ci(asympt level(95)) mean scheme(lean2)

		* loadingplot
	
		tab asset_live_index

		ttest asset_live_index, by(treatment)
		
		* French label
		label var asset_live_index		"Indice des actifs du bétail (ACP)"
	
		* English label
		*label var asset_live_index		"Livestock Asset Index (PCA)"
		

 
		save "$BSLREFOR_dt/Intermediate/SectionC_construct.dta" , replace


********************************************************************************
** SECTION D - ECONOMIC ACTIVITY
********************************************************************************



		use "$BSLREFOR_dt/Intermediate/SectionD_clean.dta" , clear
	
	
		* Compute land superficies
		gen lanholdings=Wsdq2 
		label variable lanholdings "Household landholdings (ha)"
		
		gen land_cultivated=Wsdq3  
		label variable land_cultivated "Land area cultivated (ha)"
		
		
		* Compute the share of land cultivated
		
		gen share_cult = round(sdq3 / sdq2,.01)  
		
		* French label
		label var share_cult "Part de terre cultivée (in pct)"
		
		* English label
		* label var share_cult "Share of surface cultivated (in pct)"
	 
	 
		* Total amount spent on Inputs and share for each Input
		* br Wsdq5 Wsdq7 sdq9 Wsdq11 Wsdq13
		
			* generate an indicator of inputs used
			gen use_inputs  =.

			foreach var in sdq4 sdq6 sdq8 sdq10 sdq12 {
				replace use_inputs = 1			if `var'!=.
				}
			
			tab use_inputs
			
			
		
		egen total_inputs =  rowtotal(Wsdq5 Wsdq7 sdq9 Wsdq11 Wsdq13)		if use_inputs==1
		
		
			sum total_inputs, detail
			
			* French label
			label var total_inputs 			"Valeur totale des intrants (en FCFA)"
		
			* English label
			*label var total_inputs 			"Total value of inputs used (in FCFA)"
			
		
		
		
		* Compute the share of each Input factor
			foreach var in Wsdq5 Wsdq7 sdq9 Wsdq11 Wsdq13	{
				gen share_`var' = round(`var' / total_inputs,.01)
				}
		
		
		*sdq4 Wsdq5 share_Wsdq5 sdq6 Wsdq7 share_Wsdq7 sdq8 sdq9 share_sdq9 sdq10 Wsdq11 share_Wsdq11 sdq12 Wsdq13 share_Wsdq13
		
		
		
				* French label 
				label var share_Wsdq5		"Part de semances améliorée"
				label var share_Wsdq7		"Part de engrais chimiques"
				label var share_sdq9		"Part de engrais organiques"
				label var share_Wsdq11		"Part de produits phytosanitaires"
				label var share_Wsdq13		"Part de la main d'œuvre"
				
				
				/* English label 
				label var share_Wsdq5		"Share of improved seeds"
				label var share_Wsdq7		"Share of non-organic fertilizer"
				label var share_sdq9		"Share of organic fertilizer"
				label var share_Wsdq11		"Sahre of pesticides"
				label var share_Wsdq13		"Share of hired labor"
				*/
			
 
 
 
		save "$BSLREFOR_dt/Intermediate/SectionD_construct.dta" , replace


********************************************************************************
** SECTION E - FOOD CONSUMPTION
********************************************************************************


		use "$BSLREFOR_dt/Intermediate/SectionE_clean.dta" , clear
	
	

	* 1.) Compute the Food Consumption Score
		* br seq1_1 seq1_2 seq1_3 seq1_4 seq1_5 seq1_6 seq1_7 seq1_8 seq1_9 seq1_10 seq1_11 		///
		   seq1_13 seq1_14 seq1_15 seq1_16 seq1_17 seq1_18 seq1_19 seq1_20 seq1_21 seq1_22 		///
		   seq1_23 seq1_24 seq1_25 seq1_26 seq1_27 seq1_28 seq1_29 seq1_30 seq1_31 seq1_32 		///
		   seq1_33 seq1_34 seq1_35 seq1_36 seq1_37 seq1_38 seq1_39 seq1_40 seq1_41
		
		
		* Recode such that we can compute rates -> replace 2's with 0's
			foreach var in seq1_1 seq1_2 seq1_3 seq1_4 seq1_5 seq1_6 seq1_7 seq1_8 seq1_9 seq1_10 seq1_11 			///
							seq1_13 seq1_14 seq1_15 seq1_16 seq1_17 seq1_18 seq1_19 seq1_20 seq1_21 seq1_22 		///
							seq1_23 seq1_24 seq1_25 seq1_26 seq1_27 seq1_28 seq1_29 seq1_30 seq1_31 seq1_32 		///
							seq1_33 seq1_34 seq1_35 seq1_36 seq1_37 seq1_38 seq1_39 seq1_40 seq1_41 {
		   
				replace `var' = 0		if `var' == 2
			}	
			
		
		
	********************************************************************************
	
		
	* Here we compute a couple Food Consumption Scores	
				
	* Food Conusmption Scores: https://www.dropbox.com/s/dopgy5moow6kf64/5.WFP_IndicatorsFSandNutIntegration.pdf?dl=0


	********************************************************************************
	* FOOD CONSUMPTION SCORE (FCS)
	
	
	* Steps for th Food Consumption Score
	* 1.) Using standard 7-day food frequency data, group all the food items into specific food groups
	* 2.) Sum all the consumption frequencies of food items of the same group, and recode the value of each group above 7 as 7
	* 3.) Multiply the value obtained for each food group by its weight and create new weighted food group scores.
	* 4.) Sum the weighed food group scores, thus creating the food consumption score 
	* 5.) Using the appropriate thresholds, recode the variable food consumption score, from a continuous variable to a categorical variable.
	

		* Group the products:
		
		* foodgroup1 "Céréales, racines, et tubers"		: Mais, Mill, Riz, Sorgho, Fonio, Manioc, Pâtes, Igname, Pomme de terre, Patate douce
		* foodgroup2 "Gousses / fruits à pericarpes"	: Arachide, Noix de cola
		* foodgroup3 "Légumes"							: Gombo, Oignon, Tomate, Poivron, Feuilles de baobab,  Autre légumes frais n.d.a.(12)
		* foodgroup4 "Fruits" 							: Mangue, Orange, Banane
		* foodgroup5 "Viande et poisson" 				: Viande de bœuf, Viande de mouton, Viande de chèvre, Volailles, Gibier, Poisson, Œufs
		* foodgroup6 "Produits laitiers" 				: Lait
		* foodgroup7 "Huiles" 							: Huile alimentaire, Beurre de karité
		* foodgroup8 "Sucre"							: Sucre, Miel
	 	
		* other - Condiments: Sel, Piment, Soumbala	
	
		* Generate the food groups
		foreach foodgroup of numlist 1/8 {
			gen foodgroup`foodgroup' = 0		
			gen expfoodgroup`foodgroup' = 0			
			}
		
			
		* Label Food groups
		label var foodgroup1 	"Céréales, racines, et tubers"
		label var foodgroup2 	"Gousses / fruits à pericarpes"
		label var foodgroup3 	"Légumes"
		label var foodgroup4 	"Fruits"
		label var foodgroup5 	"Viande et poisson"
		label var foodgroup6	"Produits laitiers"
		label var foodgroup7	"Huiles"
		label var foodgroup8	"Sucre"
		
		label var expfoodgroup1 	"Expenditure on Céréales, racines, et tubers"
		label var expfoodgroup2 	"Expenditure on Gousses / fruits à pericarpes"
		label var expfoodgroup3 	"Expenditure on Légumes"
		label var expfoodgroup4 	"Expenditure on Fruits"
		label var expfoodgroup5 	"Expenditure on Viande et poisson"
		label var expfoodgroup6		"Expenditure on Produits laitiers"
		label var expfoodgroup7		"Expenditure on Huiles"
		label var expfoodgroup8		"Expenditure on Sucre"		
			

			
/********************************



seq1_1          byte    %11.0g     d_yesno    Mais
seq1_2          byte    %11.0g     d_yesno    Mill
seq1_3          byte    %11.0g     d_yesno    Riz
seq1_4          byte    %11.0g     d_yesno    Sorgho
seq1_5          byte    %11.0g     d_yesno    Fonio
seq1_6          byte    %11.0g     d_yesno    Manioc
seq1_7          byte    %11.0g     d_yesno    Pâtes alimentaires
seq1_8          byte    %11.0g     d_yesno    Oignon frais
seq1_9          byte    %11.0g     d_yesno    Gombo
seq1_10         byte    %11.0g     d_yesno    Tomate
seq1_11         byte    %11.0g     d_yesno    Poivron
seq1_13         byte    %11.0g     d_yesno    Consommation de l'arrachide par le menage au cour des7 derniers jours
seq1_14         byte    %11.0g     d_yesno    Soumbala
seq1_15         byte    %11.0g     d_yesno    Feuilles de baobab
seq1_16         byte    %11.0g     d_yesno    Sel
seq1_17         byte    %11.0g     d_yesno    Piment
seq1_18         byte    %11.0g     d_yesno    Igname
seq1_19         byte    %11.0g     d_yesno    Pomme de terre
seq1_20         byte    %11.0g     d_yesno    Patate douce
seq1_21         byte    %11.0g     d_yesno    Mangue
seq1_22         byte    %11.0g     d_yesno    Orange
seq1_23         byte    %11.0g     d_yesno    Banane
seq1_24         byte    %11.0g     d_yesno    Noix de cola
seq1_25         byte    %11.0g     d_yesno    Viande de bœuf
seq1_26         byte    %11.0g     d_yesno    Viande de mouton
seq1_27         byte    %11.0g     d_yesno    Viande de chèvre
seq1_28         byte    %11.0g     d_yesno    Volailles
seq1_29         byte    %11.0g     d_yesno    Gibier
seq1_30         byte    %11.0g     d_yesno    Poisson
seq1_31         byte    %11.0g     d_yesno    Huile alimentaire
seq1_32         byte    %11.0g     d_yesno    Beurre de karité
seq1_33         byte    %11.0g     d_yesno    Œufs
seq1_34         byte    %11.0g     d_yesno    Lait
seq1_35         byte    %11.0g     d_yesno    Sucre
seq1_36         byte    %11.0g     d_yesno    Miel
seq1_37         byte    %11.0g     d_yesno    Tabac
seq1_38         byte    %11.0g     d_yesno    Cigarette
seq1_39         byte    %11.0g     d_yesno    Café
seq1_40         byte    %11.0g     d_yesno    Thé
seq1_41         byte    %11.0g     d_yesno    Boissons alcooliques


seq2c_1 Valeur en FCFA de cette quantite consommee
			
********************************/			
			
		* Count/add the consumption of foods for the respective group
		
		* 1. Cereals and Tubers:	Maïs (1), Mil(2), Riz(3), Sorgho(4), Fonio(5), Manioc(6), Pâtes alimentaires(7), Igname (18), Pomme de terre(19), Patate douce(20)
		foreach food of numlist 1,2,3,4,5,6,7,18,19,20 {
			replace foodgroup1	= foodgroup1 + 1				if seq1_`food' == 1
			replace expfoodgroup1 = expfoodgroup1 + seq2c_`food'   if seq2c_`food' !=.
			}
		
		
		* 2. Pulses:				Arachide (13), Soumbala(14), , Noix de cola(24)
		foreach food of numlist 13,14,24 {
			replace foodgroup2	= foodgroup2 + 1				if seq1_`food' == 1
			replace expfoodgroup2 = expfoodgroup2 + seq2c_`food'   if seq2c_`food' !=.		
			}
		
		
		* 3. Vegetables: 			Oignon frais(8), Gombo (Okra)(9), Tomate fraiche (10), Poivron (11), 
		*							Feuilles de baobab(15), 
		
		foreach food of numlist 8,9,10,11,15 {
			replace foodgroup3	= foodgroup3 + 1				if seq1_`food' == 1
			replace expfoodgroup3 = expfoodgroup3 + seq2c_`food'   if seq2c_`food' !=.		
			}
			
		
		
		* 4. Fruit:					Mangue(21), Orange(22), Banane(23), 
		foreach food of numlist 21, 22, 23 {	
			replace foodgroup4	= foodgroup4 + 1				if seq1_`food' == 1
			replace expfoodgroup4 = expfoodgroup4 + seq2c_`food'   if seq2c_`food' !=.		
			}
		
		
		
		* 5. Meat and fish:			Viande de bœuf (25), Viande de mouton (26), Viande de chèvre (27), Volailles (28),Gibier(29), Posson(30),Œufs (33)
		foreach food of numlist 25,26,27,28,29,30,33 {
			replace foodgroup5	= foodgroup5 + 1				if seq1_`food' == 1
			replace expfoodgroup5 = expfoodgroup5 + seq2c_`food'   if seq2c_`food' !=.		
			}
		
		
		* 6. Milk:					Lait(34)
		replace 	foodgroup6	= 1			if seq1_34 == 1
		replace expfoodgroup6 = expfoodgroup6 + seq2c_34   if seq2c_34!=.		
		
		
		* 7. Oil:					Huile alimentaire(31), Beurre de karité(32)
		foreach food of numlist 31,32 {
			replace foodgroup7 	= foodgroup7 + 1				if seq1_`food' == 1
			replace expfoodgroup7 = expfoodgroup7 + seq2c_`food'   if seq2c_`food' !=.		
			}
		
		
		* 8. Sugar:					Sucre (35), Miel (36)
		foreach food of numlist 35,36 {		
			replace foodgroup8 	= foodgroup8 + 1				if seq1_`food' == 1
			replace expfoodgroup8 = expfoodgroup8 + seq2c_`food'   if seq2c_`food' !=.		
			}

			
		* 8. Other: Condiments, alcool, tabac
		egen FoodExp_base=rowtotal(seq2c_*)
		label variable FoodExp_base "Total (nominal) food consumption expenditures in FCFA (past 7 days)"	
		
		gen LFoodExp_base=log(FoodExp_base)
		label variable LFoodExp_base "(LOG) Total (nominal) food consumption expenditures in FCFA (past 7 days)"	
		
		egen FoodExpMain=rowtotal(expfoodgroup*)
		generate expfoodgroup9 = FoodExp_base - FoodExpMain 
		drop FoodExpMain
		label var expfoodgroup9	"Expenditure on other items - tabac, alcool, condiments"
		
		
		* Computing Expenditure shares
		
		forvalues g=1/9  {
			gen  expshr_foodgroup`g'=expfoodgroup`g'*100/FoodExp_base
		}
			
		label var expshr_foodgroup1 	"Expenditure share on Céréales, racines, et tubers"
		label var expshr_foodgroup2 	"Expenditure share on Gousses / fruits à pericarpes"
		label var expshr_foodgroup3 	"Expenditure share on Légumes"
		label var expshr_foodgroup4 	"Expenditure share on Fruits"
		label var expshr_foodgroup5 	"Expenditure share on Viande et poisson"
		label var expshr_foodgroup6		"Expenditure share on Produits laitiers"
		label var expshr_foodgroup7		"Expenditure share on Huiles"
		label var expshr_foodgroup8		"Expenditure share on Sucre"
		label var expshr_foodgroup9		"Expenditure share on other items - tabac, alcool, condiments"
		
		

			foreach num of numlist 1/7 {
				gen 	foodgroup`num'_bin =foodgroup`num' > 0
				}
		
		* Generate the HDDS score by summing those vars
			egen 	  HDDS_base = rowtotal(foodgroup1_bin-foodgroup7_bin)
		
			label var HDDS_base "Household Dietary Diversity Score (HDDS)"	

			tab 	  HDDS_base
		
		drop seq*
		save "$BSLREFOR_dt/Intermediate/SectionE_construct.dta" , replace

 
 

********************************************************************************
** 
********************************************************************************




