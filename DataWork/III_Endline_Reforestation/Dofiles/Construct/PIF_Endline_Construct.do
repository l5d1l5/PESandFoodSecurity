/* *************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
*         				PIF Burkina Faso		  					           *
*		  				Construct PIF Endline data					   		   *
*																	   		   *
* **************************************************************************** *
* **************************************************************************** *



** WRITTEN BY: Jonas Guthoff 			(jguthoff@worldbank.org)
			   Guigonan Serge Adjognon  (gadjognon@worldbank.org)

			   
** CREATED:    06/12/2018

	** OUTLINE:		For each section load in the cleaned data and construct
					the variables for the analysis
					
	
					0. Load data					
					
					1. Clean the data and save construct data set
					
		
		
	** Requires:  	III_Endline_Reforestation_MasterDofile.do to set the globals
	
	
	** Unique identifier: hhid
	
	
*/
********************************************************************************
* SECTION A:  Identification du participant 			   					   *
********************************************************************************

		
	use "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionA_clean.dta", clear	

	
	* To show attrition by region, enumerator, etc
	tab			found_participant
	
	* to compute proper rates
	replace 	found_participant = 0 			if found_participant == 2
	
	* label var 	found_participant "Participant trouvé (Oui=1, Non=0)"
	
	label var 	found_participant "Respondent found (Yes=1, No=0)"
	
	
	label define found 0 "Pas trouvé" 1 "Trouvé"
	label values found_participant found
	
	label define found_eng 0 "Attrited" 1 "Endline"
	label values found_participant found_eng
	
	
	

	generate age=b5
	label variable age "age of respondent"	
	
	generate female=.
	replace female=0 if b6=="Homme"
	replace female=1 if b6=="Femme"
	label variable female "female respondent (1/0)"
	
	rename b7 ethnicity
	label variable ethnicity "ethnicity of respondent"
	

	encode a1_region, gen(region)
	encode a2_site, gen(site)
	encode a4_bloc, gen(bloc)
	encode a5_parcelle, gen(parcelle)
	
	label variable date "Endline survey date"
	
	generate month=month(date)

	keep  found_participant date month hhid region site bloc parcelle  age female ethnicity statut treatment
	order found_participant date month hhid region site bloc parcelle  age female ethnicity statut treatment 

	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", replace 



********************************************************************************
* SECTION B: Caractéristiques socio-démographique du participant  			   *
********************************************************************************


	use "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionB_clean.dta", clear	
	
	
	
	* br b6 b6_confirm b6_correct

	gen 		sexe 			= 0
	replace		sexe			= 1			if b6 == "Femme"|b6_correct == 2
	
	label var	sexe	"Le répondent est une femme (Oui=1, Non=0)"
	
	
	* generate indicator for each occupation	
	tab 		b9
	
	* generate a binary indicator, whether the respondent has a primary occupation
	gen			prim_occ 		= 0
 	replace		prim_occ		= 1 				if b9 > 0 & b9 !=. 
	
	
	gen 		b9_Agriculteur 	= 0
	replace 	b9_Agriculteur 	= 1					if b9 ==  1
	
	gen 		b9_Eleveur		= 0	
	replace 	b9_Eleveur 		= 1					if b9 ==  2
	
	gen 		b9_Agropasteur	= 0
	replace 	b9_Agropasteur	= 1 				if b9 ==  3
	
	gen 		b9_Commercant	= 0
	replace 	b9_Commercant	= 1 				if b9 ==  4
	
	gen 		b9_Macon		= 0
	replace		b9_Macon		= 1 				if b9 ==  6
	
	gen 		b9_Autre 		= 0
	replace 	b9_Autre 		= 1 				if b9 ==  8
	
	gen 		b9_Menagere		= 0
	replace 	b9_Menagere		= 1 				if b9 ==  9
	
	
	* label variables
	label var 	prim_occ			"Participant a une occupation principale (Oui=1, Non=0)"
	label var 	b9_Agriculteur		"Agriculteur (Oui=1, Non=0)"
	label var 	b9_Eleveur			"Eleveur (Oui=1, Non=0)"
	label var 	b9_Agropasteur		"Agro-pasteur (Oui=1, Non=0)"
	label var 	b9_Commercant 		"Commercant (Oui=1, Non=0)"
	label var 	b9_Macon			"Maçon (Oui=1, Non=0)"
	label var 	b9_Autre			"Autre (Oui=1, Non=0)"
	label var 	b9_Menagere			"Ménagère (Oui=1, Non=0)"
	
	summ		b9_autre b9_Agriculteur b9_Eleveur b9_Agropasteur b9_Commercant b9_Macon b9_Autre b9_Menagere
	

	* More general -> code if the respondent is a farmer or not
	gen 		agriculteur 	= 0
	replace 	agriculteur 	= 1					if b9 ==  1
	
	label var   agriculteur 		"Le participant est agriculteur (Oui=1, Non=0)"
	
	
 	
	* Revenue Occupation principale
	summ		b10 W01_b10 W03_b10 W05_b10 
	
	label var 	W01_b10 "Revenu total de l'occupation principale des 30 derniers jours (en FCFA)†"
	
	summ		b11 W01_b11 W03_b11 W05_b11
	
	label var 	W01_b11	"Revenu total de l'occupation principale des 12 derniers mois (en FCFA)†"
	
	
	
	

	
	
	
	* Secondary occupation (Yes/No)
	tab 		b13
	
	gen 		sec_occup 		= 0					if b13 !=. 
	replace		sec_occup		= 1					if b13 > 0 & b13 !=.
	
	tab 		sec_occup
	
	label var 	sec_occup			"Participant a une occupation secondaire (Oui=1, Non=0)"
	
	
	* Revenue Occupation secondaire
	summ		b14 W01_b14 W03_b14 W05_b14
	
	label var 	W01_b14	"Revenu total de l'occupation secondaire des 30 derniers jours (en FCFA)†"
	
	
	summ		b15 W01_b15 W03_b15 W05_b15
	
	label var 	W01_b15	"Revenu total de l'occupation secondaire des 30 derniers jours (en FCFA)†"
	
	
	* revenue total
	
	gen rev_total_12mois=b11*100/b12
	winsor rev_total_12mois, gen(W01_rev_total_12mois) p(0.1) highonly
	gen Lrev_total_12mois=log(rev_total_12mois + 0.000000000000000001)
	label variable rev_total_12mois "Revenu total 12 derniers mois in FCFA"
	label variable W01_rev_total_12mois "(winsorized)Revenu total 12 derniers mois"
	label variable Lrev_total_12mois "(log) Revenu total 12 derniers mois"
	
	
	
	
	
	*------------------------------------------------------------------------- *
	
	* Participation au program PIF  (statut == 1) *
	
 	
	tab 		b21, nolabel
	
	* recode to calculate rates (0/1)
	replace 	b21 = 0			if b21 == 2 | b21 == .
	
	tab 		b21, nolabel
	
	label var 	b21 "Reçu un paiement dans le cadre de reforestation du PIF (Oui=1, Non=0)"
	
	
	
	
	* Paiement recu
	
	mvencode b22 W01_b22 W03_b22 W05_b22, mv(0) override
	
	summ		b22 W01_b22 W03_b22 W05_b22
	
	label var	W01_b22 "Reçu individuellement (en FCFA)†" 
	
	

	
	* Generate 0/1 indicators for each usage
	* br b23_1 b23_2 b23_3 b23_4

	* label all
	foreach usage of numlist 2/4 {
		label 	values b23_`usage' b23_1
		}
	
	foreach usage of numlist 1/9 {
		gen 	usage_item_`usage'	= 0		
		}
	
	* replace them with a zero in case the participant cited one of them
	foreach usage of numlist 1/9 {
		foreach item of numlist 1/4 {
		replace usage_item_`usage'	= 1				if 	b23_`item' == `usage'
			}
		}
		
	* label variables
	label var 	usage_item_1	"Acheter des habits (Oui=1, Non=0)"
	label var 	usage_item_2	"acheter des intrants agricoles (Oui=1, Non=0)"
	label var 	usage_item_3	"Acheter des médicaments pour se soigner (Oui=1, Non=0)"
	label var 	usage_item_4	"Acheter des produits cosmétiques (Oui=1, Non=0)"
	label var 	usage_item_5	"Acheter des vivres (Oui=1, Non=0)"
	label var 	usage_item_6	"Dépenses scolaire (Oui=1, Non=0)"
	label var 	usage_item_7	"Faire de l'élevage (Oui=1, Non=0)"
	label var 	usage_item_8	"Réparer son engin de déplacement (Oui=1, Non=0)"
	label var 	usage_item_9	"Autres dépenses familiales (Oui=1, Non=0)"
	
		
	summ		usage_item_1 - usage_item_9
	
	
	* Generate similar variables that capture the expenditures 
	* br b23_montant_1 b23_montant_2 b23_montant_3 b23_montant_4
	
	foreach usage of numlist 1/9 {
		gen 	montant_usage_`usage' = .
		}
		
	foreach usage of numlist 1/9 {
		foreach item of numlist 1/4 {
		replace montant_usage_`usage' = b23_montant_`item' 		if b23_`item' == `usage' 
			}
		}
	
	* label expenditure variables for the different usages
	label var 	montant_usage_1		"Montant - Acheter des habits (en FCFA)"
	label var 	montant_usage_2		"Montant - Acheter des intrants agricoles (en FCFA)"
	label var 	montant_usage_3		"Montant - Acheter des médicaments pour se soigner (en FCFA)"
	label var 	montant_usage_4		"Montant - Acheter des produits cosmétiques (en FCFA)"
	label var 	montant_usage_5		"Montant - Acheter des vivres (en FCFA)"
	label var 	montant_usage_6		"Montant - Dépenses scolaire (en FCFA)"
	label var 	montant_usage_7		"Montant - Faire de l'élevage (en FCFA)"
	label var 	montant_usage_8		"Montant - Réparer son engin de déplacement (en FCFA)"
	label var 	montant_usage_9		"Montant - Autres dépenses familiales (en FCFA)"
	
	summ		montant_usage_1 - montant_usage_9
	
	* Clean the those amounts relative to the respective usage
	
	foreach usage of numlist 1/9 {
		
		summ	montant_usage_`usage', detail
		
		replace montant_usage_`usage' = `r(p50)'		if montant_usage_`usage' < 0
			
	}		
	
	* recheck the distribution
	summ		montant_usage_1 - montant_usage_9
			
	
	summ		b24, detail
	
	label var 	b24	"Montant qui reste (en FCFA)"
	
	
	* ------------------------------------------------------------------------ *
 	
	
	* 1.) Generate on group level an ethnic composition index which reflects how
	*	  heterogenous-/homogenous the group is
	
	
	* check the ethnicities
	tab 	b7
	
	* check the "other" ethnicities
	tab 	b7_autre
	
	* clean some of the ethnicities
	replace b7_autre = "Dafi"		if b7_autre == "Dafing"
	
	replace b7_autre = "Koh"		if inlist(b7_autre,"Ko","Kô")
	
	replace b7_autre = "Nounouma"	if b7_autre == "Nounouman"
	
	tab 	b7_autre
	
	
 	
	* recode b7 by including also the other categories
	
	replace b7 = 14		if b7_autre == "Dafi"
	
	replace b7 = 15 	if b7_autre == "Koh"
	
	replace b7 = 16 	if b7_autre == "Nounouma"
	
	replace b7 = 17		if b7_autre == "Yadega"
	
	 
	#delimit ;

	label define b7_update 
		 1 "Mossi"
		 2 "Gourmatche"
		 3 "Samo"
		 4 "Gourounsi"
         5 "Bobo"
         6 "Bwaba"
         7 "Lobi"
         8 "Dagara"
         9 "Birifor"
        10 "Peul"
        11 "Touareg"
        12 "Senoufo"
		13 "Autre"
		14 "Dafi"
		15 "Koh"
		16 "Nounouma"
		17 "Yadega";
	 #delimit cr
	
	label values b7 b7_update
	
	 
	tab b7
	
	

		
	
	* ------------------------------------------------------------------------ *
	
	

	* Repeat group regarding known members
	* simply generate counts for the 5 categories 
	* br b26_1_1 b26_1_2 b26_1_3 b26_1_4
	
	foreach effort of numlist 1/5 {
		gen 	effort_`effort' = 0									if b25 == 1		
		}
	
	foreach member of numlist 1/4 {
		foreach effort of numlist 1/5 {
		replace effort_`effort' = effort_`effort' + 1				if b26_1_`member' == `effort'
			}
		}
	
	
	* label variables
	label var 	effort_1 		"On a fourni le même effort de travail"
	label var 	effort_2 		"J’ai fourni un peu plus d’effort que  ${mem_na_conn}"
	label var 	effort_3 		"J’ai fourni beaucoup plus d’effort que  ${mem_na_conn}"
	label var 	effort_4 		"${mem_na_conn} a fourni beaucoup plus d’effort que moi"
	label var 	effort_5 		"Nous avions fourni assez d’effort"
	
	* Check most replies for the 5 categories
	summ		effort_1 - effort_5
	
	
 

	
	
	* b.29) b29_1 Principal Activités to mantain
	summ		b29_1_1 b29_1_2 b29_1_3 b29_1_4 b29_1_5 b29_1_autre
	
	* label the binary variables
	label var 	b29_1_1			"Arrosage (Oui=1, Non=0)"
	label var 	b29_1_2			"Nettoyage (Oui=1, Non=0)"
	label var 	b29_1_3			"Par-feu (Oui=1, Non=0)"
	label var 	b29_1_4			"Surveillance contre les animaux(Oui=1, Non=0)"
	label var 	b29_1_5			"Autres activités (Oui=1, Non=0)"

		
	 
	* b31_1 Quelles activités avez-vous entreprises principalement à titre individuel ?
	 
	summ 		b31_1_1 b31_1_2 b31_1_3 b31_1_4 b31_1_5 
	
	* label the binary variables of the multiple choice set
	label var	b31_1_1			"Arrosage (Oui=1, Non=0)"
	label var	b31_1_2			"Nettoyage (Oui=1, Non=0)"
	label var	b31_1_3			"Par-feu (Oui=1, Non=0)"
	label var	b31_1_4			"Surveillance contre les animaux(Oui=1, Non=0)"
	label var	b31_1_5			"Autres activités (Oui=1, Non=0)"
	
	
	* b32 	- Reasons for why the team did not visit the plots before the final PIF visit
	summ		b33_2_1 b33_2_2 b33_2_3 b33_2_4
	
	* label var 
	label var	b33_2_1			"préoccupés à faire la maintenance et pas eu le temps de compter les plants"
	label var	b33_2_2			"Connaitre le nombre de plants n’aurait rien changé à nos efforts de maintenance"
	label var	b33_2_3			"la survie des plants ne dépend pas des humains"
	label var 	b33_2_4			"autres raison"
	
	
	
	
		
	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", replace	

	use  "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", clear


*******************************************************************************************
* SECTION C: ACTIVITES AGRICOLES ET NON-AGRICOLE DU MENAGE au cours des 12 derniers mois *
*******************************************************************************************


	use "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionC_clean.dta", clear	

	tab 		c1

	label var 	c1 "Possédé des terres ces 12 derniers mois"
	
	
	summ 		c2, detail
	
	label var	c2 "Superficie totale de terres à dispose du ménage (en ha)"
	
	
	summ		c3, detail
	
	label var 	c3 "Superficie totale de terre cultivées par le ménage (en ha)"
            
	* Input Questions, label and generate shares
	tab			c4
	label var	c4	"Acheté des semences améliorée (Oui=1, Non=0)"
	
	tab 		c6	
	label var	c6	"Acheté des engrais chimiques (Oui=1, Non=0)"
	
	tab			c8	
	label var 	c8	"Acheté des engrais organiques (Oui=1, Non=0)"

	tab 		c10
	label var	c10	"Acheté des produits phytosanitaires (Oui=1, Non=0)"
	
	tab 		c12
	label var 	c12	"Acheté/loué de la main d’œuvre agricole (Oui=1, Non=0)"
	
	tab 		c14
	label var 	c14	"Réalisé d’autres investissements (Oui=1, Non=0)"
	
	
	tab 		c19b
	
	
	* generate an input total and then generate the the shares by inputs
	* br c5 c7 c9 c11 c13 c16
	
	egen 		input_total = rowtotal(c5 c7 c9 c11 c13 c16)	
	* clean the zeros to missing
	replace		input_total = .			if input_total == 0
	
	label var 	input_total "Depenses totales des intrants (en FCFA)"
	
	* Compute the share for each input
	foreach input of numlist   5,7,9,11,13 {		
		gen share_input_`input'	= round(c`input' /input_total,.01)
		}
	
	* Label variables of the shares
	label var share_input_5		"Part depensée - semences améliorées (en pct)"
	label var share_input_7		"Part depensée - engrais chimiques (en pct)"
	label var share_input_9		"Part depensée - engrais organiques (en pct)"
	label var share_input_11	"Part depensée - produits phytosanitaires (en pct)"
	label var share_input_13	"Part depensée - de la main d’œuvre (en pct)"
	
	
		

	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionC_construct.dta", replace	

	

	
********************************************************************************
* SECTION D: Sécurité Alimentaire des Ménages  								   *
********************************************************************************

	use "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionD_clean.dta", clear	
	
	keep hhid found_participant treatment d* 
	keep if found_participant == 1
	
* Generate Food consumption expenditures
	
	*br da1-db342 if found_participant == 1
	*order da1 db11 db21 db21_autre db31 da2 db12 db22 db22_autre db32, a(found_participant)
	
	* replacing the -999 with missing values
	forvalues x=1/42 {
		replace da`x' =0 if da`x'==2
		replace db3`x'=. if db3`x'<0
		sum  db3`x', detail
*		replace db3`x'=`r(p50)' if db3`x'==. & 	found_participant == 1
	}
	*

	
	
	* Food Consumption Score (FCS)
	* We cannot calculate FCS because we do not have the frequency of consumption of each food item
	
	
	* Creating Food groups: add 1 for each food that was consumed that belonged to a certain group
	*							Weight
	* 1. Cereals and Tubers:		2
	* 2. Pulses						3
	* 3. Vegetables					1
	* 4. Fruit						1
	* 5. Meat and fish				4
	* 6. Milk						4
	* 7. Oil						0.5
	* 8. Sugar						0.5
	
	
	* Group the products:
		
	* foodgroup1 "Céréales, racines, et tubers"		: Mais, Mill, Riz, Sorgho, Fonio, Manioc, Pâtes, Igname, Pomme de terre, Patate douce
	* foodgroup2 "Gousses / fruits à pericarpes"	: Arachide, Noix de cola
	* foodgroup3 "Légumes"							: Gombo, Oignon, Tomate, Poivron, Feuilles de baobab -> leave out Tomate en boîte (11) since it wasnt asked in Baseline
	* foodgroup4 "Fruits" 							: Mangue, Orange, Banane
	* foodgroup5 "Viande et poisson" 				: Viande de bœuf, Viande de mouton, Viande de chèvre, Volailles, Gibier, Poisson, Œufs
	* foodgroup6 "Produits laitiers" 				: Lait
	* foodgroup7 "Huiles" 							: Huile alimentaire, Beurre de karité
	* foodgroup8 "Sucre"							: Sucre, Miel
	
	* other - Condiments, alcool, tabac
	
	
	foreach foodgroup of numlist 1/8 {
		gen foodgroup`foodgroup' = 0			if found_participant == 1
		gen expfoodgroup`foodgroup' = 0			if found_participant == 1
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
	
	
	* Count/add the consumption of foods for the respective group
	
	* 1. Cereals and Tubers:	Maïs (1), Mil(2), Riz(3), Sorgho(4), Fonio(5), Manioc(6), Pâtes alimentaires(7), Igname (19), Pomme de terre(20), Patate douce(21)
	foreach food of numlist 1,2,3,4,5,6,7,19,20 {
		replace foodgroup1	= foodgroup1 + 1				if da`food' == 1
		replace expfoodgroup1 = expfoodgroup1 + db3`food'   if db3`food' !=.
		}
	
	
	* 2. Pulses:				Arachide (14), Soumbala(15), , Noix de cola(25)
	foreach food of numlist 14,15,25 {
		replace foodgroup2	= foodgroup2 + 1				if da`food' == 1
		replace expfoodgroup2 = expfoodgroup2 + db3`food'   if db3`food' !=.		
		}
	
	
	* 3. Vegetables: 			Oignon frais(8), Gombo (Okra)(9), Tomate fraiche (10), Poivron (12), 
	*							Autre légumes frais (13), Feuilles de baobab(16), 
	
	foreach food of numlist 8,9,10,12,13,16 {
		replace foodgroup3	= foodgroup3 + 1				if da`food' == 1
		replace expfoodgroup3 = expfoodgroup3 + db3`food'   if db3`food' !=.		
		}
		
	
	
	* 4. Fruit:					Mangue(22), Orange(23), Banane(24), 
	foreach food of numlist 22,23, 24 {	
		replace foodgroup4	= foodgroup4 + 1				if da`food' == 1
		replace expfoodgroup4 = expfoodgroup4 + db3`food'   if db3`food' !=.		
		}
	
	
	
	* 5. Meat and fish:			Viande de bœuf (26), Viande de mouton (27), Viande de chèvre (28), Volailles (29),Gibier(30), Posson(31),Œufs (34)
	foreach food of numlist 26,27,28,29,30,31,34 {
		replace foodgroup5	= foodgroup5 + 1				if da`food' == 1
		replace expfoodgroup5 = expfoodgroup5 + db3`food'   if db3`food' !=.		
		}
	
	
	* 6. Milk:					Lait(35)
	replace 	foodgroup6	= 1			if da35 == 1
	replace expfoodgroup6 = expfoodgroup6 + db335   if db335!=.		
	
	
	* 7. Oil:					Huile alimentaire(32), Beurre de karité(33)
	foreach food of numlist 32,33 {
		replace foodgroup7 	= foodgroup7 + 1				if da`food' == 1
		replace expfoodgroup7 = expfoodgroup7 + db3`food'   if db3`food' !=.		
		}
	
	
	* 8. Sugar:					Sucre (36), Miel (37)
	foreach food of numlist 36,37 {		
		replace foodgroup8 	= foodgroup8 + 1				if da`food' == 1
		replace expfoodgroup8 = expfoodgroup8 + db3`food'   if db3`food' !=.		
		}

		
	* 8. Other: Condiments, alcool, tabac
	egen FoodExp=rowtotal(db3*)
	label variable FoodExp "Total (nominal) food consumption expenditures in FCFA (past 7 days)"	
	
	gen LFoodExp=log(FoodExp)
	label variable LFoodExp "(LOG) Total (nominal) food consumption expenditures in FCFA (past 7 days)"	
	
	egen FoodExpMain=rowtotal(expfoodgroup*)
	generate expfoodgroup9 = FoodExp - FoodExpMain 
	drop FoodExpMain
	label var expfoodgroup9	"Expenditure on other items - tabac, alcool, condiments"
	
	
	* Computing Expenditure shares
	
	forvalues g=1/9  {
		gen  expshr_foodgroup`g'=expfoodgroup`g'*100/FoodExp
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
	
	
	/* Topcode every foodgroup at 7 
	foreach group of numlist 1(1)8 {
		replace foodgroup`group' = 7						if foodgroup`group' >7 & foodgroup`group' !=.		
		}
	* -> none are above 7 actually
	
		
	* 3.) Multiply the value obtained for each food group by its weight and create new weighted food group scores.	
	* 	  generate the weighted foodgroups
	
	gen foodgroup1_w = 	foodgroup1 * 2
	gen foodgroup2_w = 	foodgroup2 * 3
	gen foodgroup3_w = 	foodgroup3
	gen foodgroup4_w = 	foodgroup4 
	gen foodgroup5_w = 	foodgroup5 * 4
	gen foodgroup6_w = 	foodgroup6 * 4
	gen foodgroup7_w = 	foodgroup7 * 0.5
	gen foodgroup8_w = 	foodgroup8 * 0.5
		
	
	
	* 4.) Sum the weighed food group scores, thus creating the food consumption score 
	br foodgroup1_w-foodgroup8_w
	
	egen 		fcs = rowtotal(foodgroup1_w - foodgroup8_w)
	
	label var	fcs "Food Consumption Score (FCS) - Weighted"
	
	tab 		fcs
	
	* Generate the 3 categories: Poor (fcs < 21) - Borderline (21.5 < fcs < 35) - Acceptable (> 35)
	gen 		fcs_cat = .
	replace		fcs_cat = 1			if fcs <= 21
	replace		fcs_cat = 2			if fcs > 21 & fcs <= 35
	replace		fcs_cat = 3			if fcs > 35
	
	
	label var 	 fcs_cat	"Food Consumption Score - Thresholds"
				
	label define fcs 1 "Poor" 2 "Borderline" 3 "Acceptable"
	label values fcs_cat fcs

	tab 		 fcs_cat, gen(fcs_catVar)
	
	label variable fcs_catVar1 "Score de consommation alimentaire == faible"
	label variable fcs_catVar2 "Score de consommation alimentaire == limite"
	label variable fcs_catVar3 "Score de consommation alimentaire == acceptable"
	
	
	*/
	
	
	* HOUSEHOLD DIETARY SCORE
	  * Simple Summ 
	  * Categorical 

		
	* 1) For each of the foodgroups 1-7, have a binary 0/1 variable whether any of the
	* 	 foods was consumed over the course of the last 7 days;
	* 2) Simply sum up those binary variables
	
		foreach num of numlist 1/7 {
			gen 	foodgroup`num'_bin =foodgroup`num' > 0
			}
	
	* Generate the HDDS score by summing those vars
		egen 	  HDDS = rowtotal(foodgroup1_bin-foodgroup7_bin)
	
		label var HDDS "Household Dietary Diversity Score (HDDS)"	

		tab 	  HDDS
	
	
	drop d*
	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", replace	
	
 	
**************************************************************************************************
* PART D2: MOIS AU COURS DESQUELS L’APPROVISIONNEMENT DU MENAGE EN NOURRITURE A ETE INSUFFISANT  *
**************************************************************************************************


	use "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionD2_clean.dta", clear	
	
	
	keep hhid found_participant treatment d* oct_2017 - sept_2018
	keep if found_participant == 1
	
	* Construct 2 variables here:		1.) The number of months with insufficient food provision
	*									2.) The maximum number of consecutive months with insufficient food provision
	

	* 1.) Count the number of months in total with insufficient food provision
		
	
	* br oct_2017 - sept_2018 							if  found_participant == 1 & d2_1 == 1
	
	foreach month of varlist oct_2017 - sept_2018	{
		replace `month' = 0 if `month' != 1
		}
		
	egen 		MonthInsuffFood =  rowtotal(oct_2017 - sept_2018)
	label var 	MonthInsuffFood "Number of Months with insufficient food"
	summ		MonthInsuffFood 									if  found_participant == 1 & d2_1 == 1, detail
	
	
	gen hunger=MonthInsuffFood>0
	label variable hunger  "At least one month with insufficient food (0/1)"
	sum hunger
	
	* br oct_2017 - sept_2018  MonthInsuffFood			if  found_participant == 1 & d2_1 == 1 & MonthInsuffFood == 0
	/* There is one observation who said then No to all months, clean by coding d2_1 to 2 and setting the section to missing
	
	foreach var of varlist oct_2017 - sept_2018 d2_1a - d2_12b	{
		replace `var' = .											if found_participant == 1 & d2_1 == 1 & MonthInsuffFood == 0
		}
	
	* set the d2_1 to No
	replace 	d2_1 = 2											if found_participant == 1 & d2_1 == 1 & MonthInsuffFood == 0	
	*/
	

	/* 2.) Count the total consecutive months with insufficient food provision
		
	gen 		MonthInsuffFood_consec = 0							if  found_participant == 1 & d2_1 == 1
		
		
		
	* Construct a consecutive months indicator
	br d2_1 oct_2017 - sept_2018 MonthInsuffFood_consec				if  found_participant == 1 & d2_1 == 1
	
	
	* Work in LONG and then run the spell command and recode the months variables
	
	* generate first the month variables 
	foreach x of numlist 1/12 {
		gen hunger_month`x' = 0 									if d2_1 == 1
	}	
	
	* Then recode them to 1 in case the household didnt have enough food
	
	* br  oct_2017 nov_2017 dec_2017 jan_2018 feb_2018 mar_2018 april_2018 may_2018 june_2018 jul_2018 aug_2018 sept_2018
	
	replace hunger_month1 	= 1 					if oct_2017	  == 1  & d2_1 == 1
	replace hunger_month2 	= 1 					if nov_2017	  == 1  & d2_1 == 1
	replace hunger_month3 	= 1 					if dec_2017	  == 1 	& d2_1 == 1
	replace hunger_month4 	= 1 					if jan_2018	  == 1 	& d2_1 == 1
	replace hunger_month5 	= 1 					if feb_2018	  == 1 	& d2_1 == 1
	replace hunger_month6 	= 1 					if mar_2018	  == 1 	& d2_1 == 1
	replace hunger_month7 	= 1 					if april_2018 == 1 	& d2_1 == 1
	replace hunger_month8 	= 1 					if may_2018	  == 1 	& d2_1 == 1
	replace hunger_month9 	= 1 					if june_2018  == 1 	& d2_1 == 1
	replace hunger_month10  = 1 					if jul_2018	  == 1 	& d2_1 == 1
	replace hunger_month11  = 1 					if aug_2018	  == 1 	& d2_1 == 1
	replace hunger_month12  = 1 					if sept_2018  == 1 	& d2_1 == 1
	
	
	sort hhid
	br   hhid hunger_month*							if  found_participant == 1 & d2_1 == 1				
	
	* generate a new id
	gen id = _n
		
	* reshape 
	reshape long hunger_month, i(key hhid) j(number)
	
	sort 	id number
	tsset 	id number
	
	* br hhid id number hunger_month		if  found_participant == 1 & d2_1 == 1
	
	tsspell, cond(hunger_month > 0 & hunger_month < .)
	
	bys id: egen maxrun = max(_seq) 
	 
	drop _seq _spell _end _merge
	 
	* reshape back 
	reshape wide hunger_month, i(hhid key) j(number)
	
	
	* Those that did not reply, set to missing
	replace maxrun = . 					if d2_1 == 2
	
	
	* br hhid d2_1 oct_2017 - sept_2018 maxrun	if  found_participant == 1 & d2_1 == 1
	
	rename maxrun hunger_duration
	
	*** Recode the d2_1 to have a proper rate
	
	tab 	d2_1, nolabel
	replace d2_1 = 0					if d2_1 == 2	
	*/

	*global monthlist "oct_2017 - sept_2018"
	foreach var in oct_2017 nov_2017 dec_2017 jan_2018 feb_2018 mar_2018 april_2018 may_2018 june_2018 jul_2018 aug_2018 sept_2018  {
	replace `var'=`var'*100
	}
	
	keep hhid found_participant treatment oct_2017 - sept_2018 MonthInsuffFood hunger date

	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta", replace	
	
		
********************************************************************************
* PART D3: ECHELLE DE LA FAIM DANS LE MENAGE (HOUSEHOLD HUNGER SCALE)   	   *
********************************************************************************


	use "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionD3_clean.dta", clear	

	keep hhid found_participant treatment d3* 
	keep if found_participant == 1	
	
	*br  d3_6a - d3_8b							if  found_participant == 1

	
	* recode the No's to 0's and relabel
	label define yesno 0 "Non" 1 "Oui"
	
	foreach question of numlist 1(1)8 {
		replace 	 d3_`question'a = 0			if d3_`question'a == 2
		label values d3_`question'a yesno
		}
	

	
	* Household Food Insecurity Access Scale (HFIAS) (0-24) -> since we only have 8 out 9 questions
	
	* the HFIAS is a simple sum of all the Oui replies to the Oui/Non questions
	*br d3_1a d3_2a d3_3a d3_4a d3_5a d3_6a d3_7a d3_8a	if found_participant == 1
	
	
	egen 		HFIAS_score = rowtotal(d3_1a d3_2a d3_3a d3_4a d3_5a d3_6a d3_7a d3_8a)	if found_participant == 1
	
	label var 	HFIAS_score "Household Food Insecurity Access Scale (HFIAS) Score"
	
	summ 		HFIAS_score, detail
	
	
	* Household Food Insecurity Access Prevelance (HFIA category) -> 

	*br d3_1a - d3_8b				if found_participant == 1
	
	
	gen 		HFIA_cat = .
	
	replace 	HFIA_cat = 1		if (d3_1a == 0 | d3_1b == 1) & d3_2a == 0 & d3_3a == 0 & d3_4a == 0 & d3_5a == 0 & d3_6a == 0 & d3_7a == 0 & d3_8a == 0
	
	replace		HFIA_cat = 2		if (inlist(d3_1b,2,3) |  inlist(d3_2b,1,2,3) | inlist(d3_3b,1)     | inlist(d3_4b,1))   & d3_5a == 0 & d3_6a == 0 & d3_7a == 0 & d3_8a == 0
		
	replace		HFIA_cat = 3		if (inlist(d3_3b,2,3) |  inlist(d3_4b,2,3) 	 | inlist(d3_5b,1,2)   | inlist(d3_6b,1,2))	& d3_7a == 0 & d3_8a == 0
	
	replace		HFIA_cat = 4		if (inlist(d3_5b,3)   |  inlist(d3_6b,3) 	 | inlist(d3_7b,1,2,3) | inlist(d3_8b,1,2,3))
	
	label var	HFIA_cat 	"Household Food Insecurity Access Prevalence (HFIAP) - cat"
	
	
	label define HFIA 1 "Food secure" 2 "Mildly food insecure" 3 "Moderately food insecure" 4 "Severely food insecure"
	label values HFIA_cat HFIA
	
	tab HFIA_cat, gen(HFIA_cat_)
	
	label variable HFIA_cat_1 "HFIA_cat==Food secure (0/1)" 
	label variable HFIA_cat_2 "HFIA_cat==Mildly food insecure (0/1)" 
	label variable HFIA_cat_3 "HFIA_cat==Moderately food insecure (0/1)" 
	label variable HFIA_cat_4 "HFIA_cat==Severely food insecure (0/1)"
	
	
	summ 		HFIAS_score HFIA_cat HFIA_cat*, detail	
	
	
	
	* Household Hunger Scale -> 3 questions! The Questions 6,7,8 in our Endline

	
	* Recode the occurences: recode the occurences
	* Rarement (1-2 fois)			- 1
	* Quelques fois (3-10 fois)		- 1
	* Souvent (plus de 10 fois) 	- 2
	
	foreach question of numlist 6,7,8 {
		gen 	newQ`question' = .
		}
	
	foreach question of numlist 6,7,8 {
		* Rarement, quelques fois
		replace newQ`question' = 1			if inlist(d3_`question'b,1,2)
		
		* Souvent
		replace newQ`question' = 2			if d3_`question'b == 3
		
		* Those that replied Non -> code to zero	
		replace newQ`question' = 0			if d3_`question'a == 0
		
		}
	
	* Sum them up
	egen 		HHS = rowtotal(newQ6 newQ7 newQ8)	if  found_participant == 1
	
	tab 		HHS
	
	gen 		HHS_cat = .
	replace 	HHS_cat = 1			if inlist(HHS,0,1)
	replace 	HHS_cat = 2			if inlist(HHS,2,3)
	replace		HHS_cat = 3			if inlist(HHS,4,5,6)
	
	
	label var 	HHS		"Household Hunger Scale (HHS) Score"
	label var 	HHS_cat "HHS Categorical Indicator"
	
	label define HHS	1 "Little to no hunger in hh" 2 "Moderate hunger in hh" 3 "Severe hunger in hh"
	label values HHS_cat HHS
		
		
	tab			HHS_cat, gen(HHScat)		
	
	
	label var 	HHScat1 "HHScat == little/no hunger in household (0/1)"
	label var 	HHScat2 "HHScat == moderate hunger in household  (0/1)"
	
	
	summ 		HHS HHS_cat HHScat1 HHScat2
	
	
	
	* Check coding bugs
	*br d3_1a d3_2a d3_3a d3_4a d3_5a d3_6a d3_7a d3_8a	if found_participant == 1 & HFIA_cat == .
	
	
	keep hhid found_participant treatment HHS HHS_cat HHScat1 HHScat2 HFIAS_score HFIA_cat HFIA_cat* 	

	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta", replace	

	
********************************************************************************
* SECTION E: CAPITAL SOCIAL - CONFIANCE AUX INSTITUTIONS LOCALES   	   		   *
********************************************************************************

	
	use "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionE_clean.dta", clear	
	
	

	* br 	 e1 e2 e4 - e9								if found_participant == 1 
	
	summ e1 e2 e4 - e9 if found_participant == 1 
	
/*	
1	Aucune confiance
2	Peu de confiance
3	Confiance moyenne
4	Assez de confiance
5	Confiance totale	
*/	
	
	* Standardize each variable and then add them up
	foreach question of numlist 1,2,4/9 {
		
		summ e`question', detail
		 
		 gen e`question'_z = (e`question' - `r(mean)') / `r(sd)'
		}
	
	
	* Add all confidence variables up to obtain an overall level of confidence
	* br e1_z e2_z e4_z e5_z e6_z e7_z e8_z e9_z
	

	egen 		confid_index = rowtotal(e1_z e2_z e4_z e5_z e6_z e7_z e8_z e9_z)		if found_participant == 1 
	
	label var	confid_index "Confidence Z-Score"
	
	
	* kdensity 	confid_index
	
	
	
	
	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_construct.dta", replace	
	
	
	
********************************************************************************
* SECTION F: PERCEPTION DE LA VALEUR ENVIRONNEMENTALE ET PREFERENCES 	   	   *
********************************************************************************

	use "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionF_clean.dta", clear	
		


		
		
		
		
		
		
		
		
		
		

	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionF_construct.dta", replace	
	
		
********************************************************************************
* SECTION G: PREFERENCES PAR RAPPORT AU RISQUE 	   	   						   *
********************************************************************************


	use "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionG_clean.dta", clear	
	
	



	
	

	
	
	
	
	

	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionG_construct.dta", replace	
	
	
	
********************************************************************************
** END OF THE DO FILE
********************************************************************************

	
	
	
	
	










