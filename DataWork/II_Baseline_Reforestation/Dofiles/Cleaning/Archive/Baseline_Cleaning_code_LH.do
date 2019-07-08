
 **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *		
*          DATA CLEANING & DETECTING OF ISSUES DO FILE 					  	   *
*          This do file contains CLEANING of the 				 			   *
*          Burkina Faso Forestry Baseline  						   			   *
*                                                                      		   *
* **************************************************************************** *
* **************************************************************************** *
	

* Project: 	Additional data cleaning steps for the Burkina Faso Baseline Report
* Author: 	Loredana Horezeanu
* Date: 	April-May, 2018



/*	

***-----------------------------------------------------------------------------
* 	CODE LOREDANA
***-----------------------------------------------------------------------------		
	

*** Generate new variables for the key variables whose labels are not spelt right (due to French accents)
			
				gen sbq192 = sbq19 
							label var sbq192 "Relation avec le chef du menage"
							drop sbq19 
							rename sbq192 sbq19 
							order sbq19, after(sbq18)
			
				descr sbq22
							gen sbq222 = sbq22 
							label var sbq222 "Membre d'un groupement de gestion forestiere (GGF)"
							drop sbq22 
							rename sbq222 sbq22
							describe sbq22
							order sbq22, after(sbq21)
	
				descr sdq3 
							gen sdq32 = sdq3
							label var sdq32 "Superficie totale de terre cultivee du menage -  de la saison agricole en cours"
							drop sdq3 
							rename sdq32 sdq3
							describe sdq3
							order sdq3, after(sdq2)
	
				descr sdq4 
							gen sdq42 = sdq4
							label var sdq42 "Achat de semences ameliorees pour utilisation sur champs pendant saison agricole"
							drop sdq4 
							rename sdq42 sdq4
							describe sdq4
							order sdq4, after(sdq3)
	
	
				descr sdq5 
							gen sdq52 = sdq5
							label var sdq52 "Valeur totale des semences ameliorees achetees "
							drop sdq5 
							rename sdq52 sdq5
							describe sdq5
							order sdq5, after(sdq4)
	
* Recode binary variables so that 0 "non" and 1 "oui"
	
				local binary sbq18 sbq22 scq1_100 scq1_101 scq1_102 scq1_103 scq1_104 scq1_105 ///
							scq1_106 scq1_107 scq1_108 scq1_109 scq1_110 scq1_111 scq1_112 scq1_113 ///
							scq1_114 scq1_115 scq5_300 scq5_301 scq5_302 scq5_303 scq5_304 scq5_305 ///
							scq5_306 sdq1 sdq4 sdq6 sdq8 sdq10 sdq12 sdq14 seq1_1 seq1_2 ///
							seq1_3 seq1_4 seq1_5 seq1_6 seq1_7 seq1_8 seq1_9 seq1_10 seq1_11 seq1_13 ///
							seq1_14 seq1_15 seq1_16 seq1_17 seq1_18 seq1_19 seq1_20 seq1_21 seq1_22 ///
							seq1_23 seq1_24 seq1_25 seq1_26 seq1_27 seq1_28 seq1_29 seq1_30 seq1_31 ///
							seq1_32 seq1_33 seq1_34 seq1_35 seq1_36 seq1_37 seq1_38 seq1_39 seq1_40 seq1_41
	
	
				foreach varAux of local binary {
							recode `varAux' (2 =0)
							label define `varAux'_label 0 "Non" 1 "Oui"
							label values `varAux' `varAux'_label
				}
	
	*

* Recode the gender variable so that it is 0 "homme" 1 "female"
				replace sexe=0 if sexe==1
				replace sexe=1 if sexe==2
							label define sexe_label 0 "Homme" 1 "Femme"
							label values sexe sexe_label
	
	
*** Generate the treatment variable
				gen treatment = 1 if traitement==1 | traitement==3
							replace treatment = 0 if traitement==2 | traitement==4
							tab treatment
							lab def treatment ///
							0 "Control" ///
							1 "Treatment", replace
							lab val treatment treatment
	
	
*** Generate a categorical variable for "age" 

				gen participant_age=.
							replace participant_age=1 if age<18
							replace participant_age=2 if age>=18 & age<=24
							replace participant_age=3 if age>=25 & age<=34
							replace participant_age=4 if age>=35 & age<=44
							replace participant_age=5 if age>=45 & age<=54
							replace participant_age=6 if age>=55 & age<=64
							replace participant_age=7 if age>64
							label var participant_age "L'age du participant"
							label define participant_age_label 1 "Moins que 18" 2 "18-24" 3 "25-34" 4 "35-44" 5 "45-54" 6 "55-64" 7 "over 64"
							label values participant_age participant_age_label

*** Calculate total income as sum of primary and secondary incomes (and paying attention to 0s and missing values)
			
							egen total_inc= rowtotal(sbq11 sbq15)
							br sbq11 sbq15 if total_inc==0
							replace total_inc=. if sbq11==. & sbq15==.
					
		*Check outliers and if necessary, winsorize
							winsor total_inc, gen(wtotal_inc) p(0.01)
			
		*Convert into 1000s FCFA
							gen total_income=wtotal_inc/1000


							
*** Approach to estimate total income using the pebble method			
			///replace sbq12=10 if sbq12==65
			///gen total_inc= (sbq11*10)/ sbq12
			///winsor total_inc, gen(wtotal_inc) p(0.01)
			///label var wtotal_inc "Revenu total au cours des 12 derniers mois"

*** Assets - deal with a few outliers, 0s and missings in the livestock data

							replace scq6_301=. if scq6_301 >400
							replace scq6_301=. if scq5_301==0
	
							replace scq6_302=. if scq5_302==0
							replace scq6_303=. if scq6_303>300
		

*** Agricultural assets - dealing with 0s and missings

							replace scq2_102=. if scq1_102==0	
							replace scq2_103=. if scq1_103==0
							replace scq1_103=0 if scq2_103==0
							replace scq2_103=. if scq1_103==0
							replace scq2_105=. if scq2_105>1000
							replace scq1_105=0 if scq2_105==0
							replace scq2_105=. if scq1_105==0
							replace scq2_106=. if scq1_106==0
							replace scq2_107=. if scq1_107==0
							replace scq2_111=. if scq1_111==0
		
	
	*Asset index by principal component analysis	

*Construct the index 

		global assets scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 ///
				scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 ///
				scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228
		
		pca $assets if foret==1
				rotate
				predict f1_index
		
		
		global assets scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 ///
				scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 ///
				scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228
		
		pca $assets if foret==2
				rotate
				predict f2_index
		
		
		global assets scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 ///
				scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 ///
				scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228
		
		pca $assets if foret==3
				rotate
				predict f3_index
		
		
		global assets scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 ///
				scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 ///
				scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228
		
		pca $assets if foret==4
				rotate
				predict f4_index
		
		
		global assets scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 ///
				scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 ///
				scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228
		
		pca $assets if foret==5
				rotate
				predict f5_index
		
		
		global assets scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 ///
				scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 ///
				scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228
		
		pca $assets if foret==6
				rotate
				predict f6_index
		
		
		global assets scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 ///
				scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 ///
				scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228
		
		pca $assets if foret==7
				rotate
				predict f7_index
		
		
		global assets scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 ///
				scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 ///
				scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228
		
		pca $assets if foret==8
				rotate
				predict f8_index
		
		global assets scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 ///
				scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 ///
				scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228
		
		pca $assets if foret==9
				rotate
				predict f9_index
		
		
		global assets scq3_200 scq3_201 scq3_202 scq3_203 scq3_204 scq3_205 scq3_206 scq3_207 scq3_208 ///
				scq3_209 scq3_210 scq3_211 scq3_212 scq3_213 scq3_214 scq3_215 scq3_216 scq3_217 ///
				scq3_218 scq3_219 scq3_220 scq3_221 scq3_222 scq3_223 scq3_224 scq3_225 scq3_226 scq3_227 scq3_228
		
		pca $assets if foret==10
				rotate
				predict f10_index
	
	
		gen asset_index=.
				replace asset_index= f1_index if foret==1
				replace asset_index= f2_index if foret==2
				replace asset_index= f3_index if foret==3
				replace asset_index= f4_index if foret==4
				replace asset_index= f5_index if foret==5
				replace asset_index= f6_index if foret==6
				replace asset_index= f7_index if foret==7
				replace asset_index= f8_index if foret==8
				replace asset_index= f9_index if foret==9
				replace asset_index= f10_index if foret==10
	
*** Livestock index

* Generate a new variable "sheep"

				encode scq5_307, gen( scq5_307num)
				gen sheep= scq6_307 if  scq5_307num==3

	
* Construct the Livestock holding index 

				gen chicken= scq6_300*0.01
				gen cattle= scq6_301*0.5
				gen pig= scq6_302*0.2
				gen goat= scq6_303*0.1
				gen horse= scq6_305*0.8
				gen mouton=sheep*0.1
				egen tlu= rowtotal(chicken cattle pig goat horse mouton)
	
*** Deal with the outliers in the land variables sdq2, sdq3 - winsorize (5%)

				winsor sdq2, gen(win_sdq2) p(0.05)
				winsor sdq3, gen(win_sdq3) p(0.05)
				sort sdq2 win_sdq2 sdq3 win_sdq3
				br sdq2 win_sdq2 sdq3 win_sdq3
	
				drop sdq2 sdq3 
				rename win_sdq2 sdq2
				rename win_sdq3 sdq3
					label var sdq2 "Superficie totale de terres du menage, en ha"
					label var sdq3 "Superficie totale de terre cultivee du menage, en ha"
			
*** Dealing with 0s and missings for agricultural inputs
				replace sdq7=. if sdq6==0
				replace sdq6=0 if sdq7==0
				replace sdq7=. if sdq6==0
				replace sdq10=0 if sdq11==0
				replace sdq11=. if sdq10==0
				replace sdq12=0 if sdq13==0
				replace sdq13=. if sdq12==0
	
	
*** Convert the values of agricultural inputs in 1000s FCFA

				replace sdq5 = sdq5/1000
				replace sdq7 = sdq7/1000
				replace sdq9 = sdq9/1000
				replace sdq11= sdq11/1000
				replace sdq13 = sdq13/1000
	
*** Deal with the outliers in the agricultural production
				winsor sdq18 , gen(win_sdq18 ) p(0.05)
				drop sdq18
	
				gen sdq18=win_sdq18/1000
					label var sdq18 "Valeur totale de la production agricole, en 1000s FCFA"
	
		*	
*** Generate yield as the ratio of monetary value of agricultural production and cultivated land			
				gen yield=sdq18/sdq3	
		
* generate the proportion of land cultivated from total land	
				gen landprop= sdq3/ sdq2*100
					label var landprop "Proportion of land that is cultivated"
	
	
*** Generate new variables for the average of total expenditure on agricultural inputs by forest type

				forvalues i=1/10 {
					egen f`i'_sdq2=mean(sdq2) if foret==`i'
					egen f`i'_sdq3=mean(sdq3) if foret==`i'
					egen f`i'_sdq5=mean(sdq5) if foret==`i'
					egen f`i'_sdq7=mean(sdq7) if foret==`i'
					egen f`i'_sdq9=mean(sdq9) if foret==`i'
					egen f`i'_sdq11=mean(sdq11) if foret==`i'
					egen f`i'_sdq13=mean(sdq13) if foret==`i'
  
				}

					egen totavg_sdq2=mean(sdq2)
					egen totavg_sdq3=mean(sdq3)
					egen totavg_sdq5=mean(sdq5)
					egen totavg_sdq7=mean(sdq7)
					egen totavg_sdq9=mean(sdq9)
					egen totavg_sdq11=mean(sdq11)
					egen totavg_sdq13=mean(sdq13)
	

*** Labeling the new variables 

* superficie de terre totale "sdq2"
					label var f1_sdq2	"KARI"
					label var f2_sdq2	"TOROBA"
					label var f3_sdq2	"NOSEBOU"
					label var f4_sdq2	"OUALOU"
					label var f5_sdq2	"SOROBOULI"
					label var f6_sdq2	"TISSE"
					label var f7_sdq2	"NAZINON"
					label var f8_sdq2	"TIOGO"
					label var f9_sdq2	"BONTIOLI"
					label var f10_sdq2	"TAPOABOOPO"
					label var totavg_sdq2 "TOTAL AVERAGE"

* superficie de terre cultivee "sdq3"

					label var f1_sdq3	"KARI"
					label var f2_sdq3	"TOROBA"
					label var f3_sdq3	"NOSEBOU"
					label var f4_sdq3	"OUALOU"
					label var f5_sdq3	"SOROBOULI"
					label var f6_sdq3	"TISSE"
					label var f7_sdq3	"NAZINON"
					label var f8_sdq3	"TIOGO"
					label var f9_sdq3	"BONTIOLI"
					label var f10_sdq3	"TAPOABOOPO"
					label var totavg_sdq3	"TOTAL AVERAGE"

* Semences ameliorees "sdq5"	
	
					label var f1_sdq5	"KARI"
					label var f2_sdq5	"TOROBA"
					label var f3_sdq5	"NOSEBOU"
					label var f4_sdq5	"OUALOU"
					label var f5_sdq5	"SOROBOULI"
					label var f6_sdq5	"TISSE"
					label var f7_sdq5	"NAZINON"
					label var f8_sdq5	"TIOGO"
					label var f9_sdq5	"BONTIOLI"
					label var f10_sdq5	"TAPOABOOPO"
					label var totavg_sdq5	"TOTAL AVERAGE"
	
* engrais chimiques sdq7

					label var f1_sdq7	"KARI"
					label var f2_sdq7	"TOROBA"
					label var f3_sdq7	"NOSEBOU"
					label var f4_sdq7	"OUALOU"
					label var f5_sdq7	"SOROBOULI"
					label var f6_sdq7	"TISSE"
					label var f7_sdq7	"NAZINON"
					label var f8_sdq7	"TIOGO"
					label var f9_sdq7	"BONTIOLI"
					label var f10_sdq7	"TAPOABOOPO"
					label var totavg_sdq7 "TOTAL AVERAGE"
	
* engrais organiques sdq9
					label var f1_sdq9	"KARI"
					label var f2_sdq9	"TOROBA"
					label var f3_sdq9	"NOSEBOU"
					label var f4_sdq9	"OUALOU"
					label var f5_sdq9	"SOROBOULI"
					label var f6_sdq9	"TISSE"
					label var f7_sdq9	"NAZINON"
					label var f8_sdq9	"TIOGO"
					label var f9_sdq9	"BONTIOLI"
					label var f10_sdq9	"TAPOABOOPO"
					label var totavg_sdq9 "TOTAL AVERAGE"
	

* produits phytosanitaires sdq11
					label var f1_sdq11	"KARI"
					label var f2_sdq11	"TOROBA"
					label var f3_sdq11	"NOSEBOU"
					label var f4_sdq11	"OUALOU"
					label var f5_sdq11	"SOROBOULI"
					label var f6_sdq11	"TISSE"
					label var f7_sdq11	"NAZINON"
					label var f8_sdq11	"TIOGO"
					label var f9_sdq11	"BONTIOLI"
					label var f10_sdq11	"TAPOABOOPO"
					label var totavg_sdq11 "TOTAL AVERAGE"
	

* main d'oeuvre sdq13
					label var f1_sdq13	"KARI"
					label var f2_sdq13	"TOROBA"
					label var f3_sdq13	"NOSEBOU"
					label var f4_sdq13	"OUALOU"
					label var f5_sdq13	"SOROBOULI"
					label var f6_sdq13	"TISSE"
					label var f7_sdq13	"NAZINON"
					label var f8_sdq13	"TIOGO"
					label var f9_sdq13	"BONTIOLI"
					label var f10_sdq13	"TAPOABOOPO"
					label var totavg_sdq13 "TOTAL AVERAGE"

	
*** Food consumption

*** Dealing with 0s and missings in the food consumption module

* One variable in the food module is missing from the sequence, we create it artificially so that it's easier to run the forvalues commands below; we drop it afterwards.  
	
					gen seq1_12=.
					gen seq2a_12=.
					gen seq2c_12=.
					gen seq3a_12=.
					gen seq3c_12=.
					gen seq4a_12=.
					gen seq4c_12=.
	

* There are several scenarios of 0s and missings that require an approach:

* 1. Participation is NO; there are 0s across the three sources of food consumption (bought, own production, gifted)
*Approach: change 0s to missing wherever applicable. 
	
					forvalues i=1/41 {
			
						replace seq2a_`i'=. if seq1_`i'==0
						replace seq2c_`i'=. if seq1_`i'==0
						replace seq3a_`i'=. if seq1_`i'==0
						replace seq3c_`i'=. if seq1_`i'==0
						replace seq4a_`i'=. if seq1_`i'==0
						replace seq4c_`i'=. if seq1_`i'==0
					}
   

* 2. Participation is YES. One or two out three sources of food consumption are marked as 0. The others are integers.
* Approach: change these 0s to missing and leave the integers unchanged.
* This means that just the food quantities with integers >0 actually apply for a given participant; 
*The participant did not consume food from all sources (hence the others are not applicable); 

* 3. Participation is YES. Quantity consumed is an integer >0 and value of quantity consumed is 0. 
*Approach: change the 0s to missing. 

* For 2. and 3. the code below will make all changes. 
	
				forvalues i=1/41 {
			
					replace seq2a_`i'=. if  seq2a_`i'==0 & seq1_`i'==1
					replace seq2c_`i'=. if  seq2c_`i'==0 & seq1_`i'==1
					replace seq3a_`i'=. if  seq3a_`i'==0 & seq1_`i'==1
					replace seq3c_`i'=. if  seq3c_`i'==0 & seq1_`i'==1
					replace seq4a_`i'=. if  seq4a_`i'==0 & seq1_`i'==1
					replace seq4c_`i'=. if  seq4c_`i'==0 & seq1_`i'==1
			
				}
	*
	
* 4. Participation is YES, all other follow up questions are missings. 
* Approach: We change participation to NO. 
	
				forvalues i=1/41 {
	
					replace seq1_`i'=0 if  seq2a_`i'==. & seq2c_`i'==. & seq3a_`i'==. & seq3c_`i'==. &  seq4a_`i'==. & seq4c_`i'==. 
		
				}
	*
	
				drop seq1_12 seq2a_12 seq2c_12 seq3a_12 seq3c_12 seq4a_12 seq4c_12
	

*** Generate new variables that denote the value of food consumption by source: purchased, own production or gifted. 

				egen food_purchval = rowtotal(seq2c_1 seq2c_2 seq2c_3 seq2c_4 seq2c_5 seq2c_6 seq2c_7 ///
						seq2c_8 seq2c_9 seq2c_10 seq2c_11 seq2c_13 seq2c_14 seq2c_15 seq2c_16 ///
						seq2c_17 seq2c_18 seq2c_19 seq2c_20 seq2c_21 seq2c_22 seq2c_23 seq2c_24 ///
						seq2c_25 seq2c_26 seq2c_27 seq2c_28 seq2c_29 seq2c_30 seq2c_31 seq2c_32 ///
						seq2c_33 seq2c_34 seq2c_35 seq2c_36 seq2c_37 seq2c_38 seq2c_39 seq2c_40 seq2c_41)
			
						replace food_purchval = food_purchval/1000
						label var food_purchval "Monetary value of consumed food purchased over the past 7 days, in 1000s FCFA"
	
	
				egen food_ownprodval=rowtotal(seq3c_1 seq3c_2 seq3c_3 seq3c_4 seq3c_5 seq3c_6 seq3c_7 ///
						seq3c_8 seq3c_9 seq3c_10 seq3c_11 seq3c_13 seq3c_14 seq3c_15 seq3c_16 ///
						seq3c_17 seq3c_18 seq3c_19 seq3c_20 seq3c_21 seq3c_22 seq3c_23 seq3c_24 ///
						seq3c_25 seq3c_26 seq3c_27 seq3c_28 seq3c_29 seq3c_30 seq3c_31 seq3c_32 ///
						seq3c_33 seq3c_34 seq3c_35 seq3c_36 seq3c_37 seq3c_38 seq3c_39 seq3c_40 seq3c_41)
		
						replace food_ownprodval = food_ownprodval/1000
						label var food_ownprodval "Monetary value of consumed food from own production over the past 7 days, in 1000s FCFA"
	
	
				egen food_giftval=rowtotal(seq4c_1 seq4c_2 seq4c_3 seq4c_4 seq4c_5 seq4c_6 seq4c_7 ///
						seq4c_8 seq4c_9 seq4c_10 seq4c_11 seq4c_13 seq4c_14 seq4c_15 seq4c_16 ///
						seq4c_17 seq4c_18 seq4c_19 seq4c_20 seq4c_21 seq4c_22 seq4c_23 seq4c_24 ///
						seq4c_25 seq4c_26 seq4c_27 seq4c_28 seq4c_29 seq4c_30 seq4c_31 seq4c_32 ///
						seq4c_33 seq4c_34 seq4c_35 seq4c_36 seq4c_37 seq4c_38 seq4c_39 seq4c_40 seq4c_41)
		
						replace food_giftval = food_giftval/1000
						label var food_giftval "Monetary value of consumed food gifted over the past 7 days, in 1000s FCFA"
	
				egen food_totalval=rowtotal( food_purchval food_ownprodval food_giftval)
						label var food_totalval "Total monetary value of consumed food over the past 7 days"
		
	* Generate proportions for food purchased and food from own production
				gen fdpurch_prop= food_purchval/ food_totalval
				gen fdown_prop= food_ownprodval/ food_totalval
	
	*
* Generate food groups for the calculation of the HDDS scores 

				gen group1=.
						replace group1=1 if seq1_1==1 | seq1_2==1 | seq1_3==1 | seq1_4==1 | seq1_5==1 | seq1_6==1
						label var group1 "cereals"
	
				gen group2=.
						replace group2=1 if seq1_18==1 | seq1_19==1
						label var group2 "white roots"
	
				gen group3=.
						replace group3=1 if  seq1_8==1 | seq1_9==1 | seq1_10==1 | seq1_11==1 | seq1_15==1 
						label var group3 "vegetables"
	
				gen group4=.
						replace group4=1 if seq1_21==1 | seq1_22==1 | seq1_23==1
						label var group4 "fruits"
	
				gen group5=.
						replace group5=1 if seq1_25==1 | seq1_26==1 | seq1_27==1 | seq1_28==1 | seq1_29==1
						label var group5 "meats"
	
				gen group6=1 if seq1_33==1
						label var group6 "eggs"
	
				gen group7=1 if seq1_30==1
						label var group7 "fish"
	
				gen group8=.
						replace group8=1 if seq1_13==1 | seq1_14==1 | seq1_24==1
						label var group8 "legumes, nuts and seeds"
	
				gen group9=.
						replace group9=1 if seq1_32==1
						label var group9 "milk and milk products"
	
				gen group10=1 if seq1_31==1 | seq1_34==1
						label var group10 "oils and fats"
	
				gen group11=.
						replace group11=1 if seq1_35==1 | seq1_36==1
						label var group11 "sweets"
	
				gen group12=.
						replace group12=1 if seq1_16==1 | seq1_17==1 | seq1_39==1 | seq1_40==1 | seq1_41==1
						label var group12 "spices, condiments, beverages"
	
	
				egen hdds=rowtotal( group1- group12)
						label var hdds "household dietary diversity score"
	
	
	
	save "$BSLREFOR_dt/Intermediate/participant_survey_clean.dta", replace
	
	
	
	
	
	
	
	
	
	
	
