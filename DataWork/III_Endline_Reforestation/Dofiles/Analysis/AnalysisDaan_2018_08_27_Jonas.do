* Verify directory path by running 

	dis "`c(username)'" // The text that shows up is the username of your computer (say XXX), and insert that into the code below
	
	
   * Root folder globals
   * ---------------------

   if c(username)=="WB495145" {
      cd "C:/SD Card/Cloud Docs/Dropbox\World Bank projects\PROJECTS\1-BURKINA FORESTRY"
   }

   if c(username)=="sergeadjognon" {
       global DataWork "/Volumes/My Passport for Mac/CloudDocs/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY/DataWork"  //Enter the file path to the projectfolder of next user here
   }
   
   if c(username)=="soest"  {
	   cd "C:\Users\soest\Dropbox"										
	}

  if c(username)=="jonasguthoff"  {
	   global DataWork "/Users/jonasguthoff/Dropbox/Burkina Faso Forestry/DataWork"										
	}
	
	
	global output "$DataWork/III_Endline_Reforestation/Output/Raw"
	



	** ANALYSIS OF TREATMENT DIFFERENCES IN SURVIVAL RATES -- OBSERVED, AND STATED

	use "$DataWork/III_Endline_Reforestation/DataSets/Intermediate/DaanSurvivalData2018_08_27", clear

	
** example program
capture program drop post_ttest
program define post_ttest, eclass
syntax, colnames(string)

// calculate statistics needed but not saved by ttest
matrix diff = r(mu_1) - r(mu_2)
matrix colnames diff = `colname'
ereturn matrix diff = diff

display "se_1 = " r(sd_1) / (r(N_1)^.5)
matrix se_1 = r(sd_1) / (r(N_1)^.5)
ereturn matrix se_1 = se_1
    
display "se_2 = " r(sd_2) / (r(N_2)^.5)
matrix se_2 = r(sd_2) / (r(N_2)^.5)
ereturn matrix se_2 = se_2

display "sd = " r(se) * (r(N_1)^.5)
matrix sd = r(se) * (r(N_1)^.5)
ereturn matrix sd = sd

// save them in matrix then -ereturn- them in e()
matrix obs    = r(N_1), r(N_1), r(N_1)
matrix mu 	  = r(mu_1), r(mu_2), e(diff)
matrix se 	  = e(se_1), e(se_2), r(se)
matrix sd 	  = r(sd_1), r(sd_2), e(sd)
matrix p  	  =  . , . , r(p)
matrix tstat  = . ,  ., r(t)


foreach var in obs mu se sd p tstat {
    matrix colnames `var' = `colnames'
    matrix list `var'
    ereturn matrix `var' = `var'
}

end
	

	* tests using within-block matching (paired t-tests)
		preserve /*only differences on shares of trees alive (especially for wellalive), no differences for reasons of death. */
		keep blocid treatment statedSR shalive shwellalive shdead_eaten shdead_draught shdead_unknown shdead_burnt
		drop if treatment == 3
		drop if blocid == .

		reshape wide statedSR shalive shwellalive shdead_eaten shdead_draught shdead_unknown shdead_burnt, i(blocid) j(treatment)

		local outcomevarssh statedSR shalive shwellalive shdead_eaten shdead_draught shdead_unknown shdead_burnt
		foreach var in `outcomevarssh' {
			* variables ending on 1 are bleu parcels (linear), on 2 are red ones (threshold payments)
			ttest `var'1 = `var'2
			*signrank `var'1 = `var'2 
		}
		
			* Label variables
			label var statedSR1		"Survival Rate - linear 1"
			label var shalive1		"Survival Rate - threshold 1"
			label var statedSR2		"Survival Rate - linear 2"
			label var shalive2 		"Survival Rate - threshold 2"
		
		
		eststo clear
		quietly estpost summarize statedSR1 shalive1 	
	
		ttest statedSR1 = shalive1 /* no significant difference self-reported and observed in linear... */
		
		post_ttest, colnames(statedSR1 shalive1 diff)
		eststo model1
		esttab using "$output/paired_test1.tex" , cells("obs mu(fmt(3)) se(fmt(3)) sd(fmt(3)) p(fmt(3)) tstat(fmt(3))") label nomtitle noobs  /// 
		addnotes("Ha: mean(diff) < 0   Pr(T < t) = `: display %6.4f r(p_l)'" 		///
				 "Ha: mean(diff) !=0   Pr(|T| > |t|) = `: display %6.4f r(p)'" 		///
                 "Ha: mean(diff) > 0   Pr(T > t) = `: display %6.4f r(p_u)'")		replace
		
		
		eststo clear
		quietly estpost summarize statedSR2 shalive2 	
		ttest statedSR2 = shalive2 /* but it is significantly higher in threshold... */
		post_ttest, colnames(statedSR2 shalive2 diff)
		eststo model2
		esttab using "$output/paired_test2.tex", cells("obs mu(fmt(3)) se(fmt(3)) sd(fmt(3)) p(fmt(3)) tstat(fmt(3))")  label nomtitle noobs 	/// 
		addnotes("Ha: mean(diff) < 0   Pr(T < t) = `: display %6.4f r(p_l)'" 				///
				 "Ha: mean(diff) !=0   Pr(|T| > |t|) = `: display %6.4f r(p)'"			   ///
                "Ha: mean(diff) > 0   Pr(T > t) = `: display %6.4f r(p_u)'")		replace

		
		
		restore
		* Paired t-tests: observed survival rates significantly higher in linear than in red, for both "alive" (p  = 0.0724) and for "in good state" (p = 0.0213"
		* No differences in the cause of death.
		* No significant difference in reported survival rates between treatments (p = 0.3364), but overreporting significant in threshold (p = 0.0421) and not in linear (p = 0.2351)

	
		
		
		* test of threshold effect	
		generate NumbTreesAliveObserved = int(shalive * arbres_plante)
		generate OverreportSR = 0
		replace OverreportSR = 1 if arbres_vivant > NumbTreesAliveObserved
		generate TreesAliveStated_Observed = arbres_vivant - NumbTreesAliveObserved
		generate BeneficialOverreportSR = 0 if treatment == 2 & OverreportSR == 1
		replace BeneficialOverreportSR = 1 if treatment == 2 & ((NumbTreesAlive < 100 & arbres_vivant >= 100) | (NumbTreesAlive < 200 & arbres_vivant >= 200) | (NumbTreesAlive < 300 & arbres_vivant >= 300) | (NumbTreesAlive < 400 & arbres_vivant >= 400))

		sort BeneficialOverreportSR OverreportSR arbres_vivant NumbTreesAliveObserved
		list parcelleid  NumbTreesAliveObserved arbres_vivant OverreportSR  BeneficialOverreportSR if treatment == 2

		list parcelleid  NumbTreesAliveObserved arbres_vivant if BeneficialOverreportSR == 1 & treatment == 2

		list parcelleid  NumbTreesAliveObserved arbres_vivant TreesAliveStated_Observed  if treatment == 2 & BeneficialOverreportSR == 1
		sort TreesAliveStated_Observed
		list parcelleid TreesAliveStated_Observed if treatment == 2 & OverreportSR == 1
		
		ttest TreesAliveStated_Observed if treatment == 2, by(BeneficialOverreportSR) 
		
		
		iebaltab TreesAliveStated_Observed if treatment == 2,  					///
				 grpvar(BeneficialOverreportSR) grplabels(1 Treat @ 0 Control)   ///
				 total rowvarlabels pftest 										///
				 savetex("$output/delete_me.tex") 						///
				 replace 

			filefilter  "$output/delete_me.tex" "$output/Balance_TreesAliveStated_Observed_treat2.tex",        ///                                                          
						from("/BShline") to("/BScline{1-8}") replace  
		
		
		
		* Amount of overreporting fairly substantial. Half (=18/31) of the threshold parcels reported higher numbers than observed, but for only 
		tab OverreportSR treatment if treatment != 3 & NumbTreesAliveObserved != ., exact // No difference in propensity to overreport
		tab OverreportSR BeneficialOverreportSR if treatment == 2 // 10 of the 18 that overreported benefitted from that
		ttest TreesAliveStated_Observed if treatment != 3 & OverreportSR == 1, by(treatment)
		
		iebaltab TreesAliveStated_Observed if treatment != 3 & OverreportSR == 1,		///
				 grpvar(treatment) grplabels(1 Parcelle Bleu @ 2 Parcelle Rouge)   					///
				 total rowvarlabels pftest 												///
				 savetex("$output/delete_me.tex") 										///
				 replace 

		filefilter  "$output/delete_me.tex" "$output/TreesAliveStated_Observed_No_Treat3.tex",        ///                                                          
						from("/BShline") to("/BScline{1-8}") replace  
		
		
		
		
		
		ttest TreesAliveStated_Observed = 0 if treatment == 1 // No significant overreporting in linear
		ttest TreesAliveStated_Observed = 0 if treatment == 2 // But significant in threshold
		
		
		reg TreesAliveStated_Observed treatment if treatment != 3
		
		eststo clear
		eststo: reg TreesAliveStated_Observed treatment if treatment != 3
		esttab using "$output/regression_table.tex", nolabel se star(* 0.10 ** 0.05 *** 0.01) replace
	
		
		
		
		
		
		
		use "$DataWork/III_Endline_Reforestation/Dofiles/Analysis/temp0.dta", clear
		* Test for bunching near threshold
			*Test for bunching of observed survival rates
			histogram NumbTreesAliveObserved if treatment == 2, fraction width(25) start(0)
			histogram NumbTreesAliveObserved if treatment == 1, fraction width(25) start(0)
			
			twoway histogram NumbTreesAliveObserved if treatment == 1, width(50) start(0) bfcolor(blue) blcolor(blue) barw(5)  freq ///
				|| histogram NumbTreesAliveObserved if treatment == 2, width(50) start(0) bfcolor(none) blcolor(red) freq legend(order(1 "Linear payments" 2 "Threshold payments"))
			graph export "$output/Histogram_Bunching.pdf", replace

			gen LastTwoDigitsTreesObsAlive=NumbTreesAliveObserved-int(NumbTreesAliveObserved/100)*100 if treatment == 2
		
			* Test for overrepresentation "just above the threshold" -- focusing on observed numbers in the bottom half of the range
			gen ObsCloseToThr_50 = 0  if treatment == 2
			replace ObsCloseToThr_50 = 1 if LastTwoDigitsTreesObsAlive < 50 & treatment == 2
			ttest ObsCloseToThr_50 = 0.5 if treatment == 2
			
			
				
			eststo clear
			quietly estpost summarize ObsCloseToThr_50 	
	
			ttest ObsCloseToThr_50 = 0.5	if treatment == 2 /* no significant difference self-reported and observed in linear... */
		
			post_ttest, colnames(ObsCloseToThr_50 diff)
			eststo model1
			esttab using "$output/paired_test1_slide11.tex" , cells("obs mu(fmt(3)) se(fmt(3)) sd(fmt(3)) p(fmt(3)) tstat(fmt(3))") label nomtitle noobs  /// 
			addnotes("Ha: mean(diff) < 0   Pr(T < t) = `: display %6.4f r(p_l)'" 		///
					"Ha: mean(diff) !=0   Pr(|T| > |t|) = `: display %6.4f r(p)'" 		///
					"Ha: mean(diff) > 0   Pr(T > t) = `: display %6.4f r(p_u)'")		replace

			
			
			
			
			
			* Test for overrepresentation "just above the threshold" -- focusing on observed numbers in the bottom half of the range
			gen ObsCloseToThr_25 = 0  if treatment == 2
			replace ObsCloseToThr_25 = 1 if LastTwoDigitsTreesObsAlive < 25 & treatment == 2
			ttest ObsCloseToThr_25 = 0.25 if treatment == 2
			* No evidence of bunching for observed 
			
			
			
		*Test for bunching of stated survival rates
			histogram arbres_vivant if treatment == 2, fraction width(25) start(0)
			
			twoway histogram arbres_plante if treatment == 2, width(25) start(0) bfcolor(blue) blcolor(blue) barw(5)  freq ///
				|| histogram NumbTreesAliveObserved if treatment == 2, width(25) start(0) bfcolor(none) blcolor(red) freq legend(title("Threshold payment treatment") order(1 "Trees alive (stated)" 2 "Trees alive (observed)"))
			graph export "$output/Bunching_treat2.pdf", replace

				
			twoway histogram arbres_plante if treatment == 1, width(25) start(0) bfcolor(blue) blcolor(blue) barw(5)  freq ///
				|| histogram NumbTreesAliveObserved if treatment == 1, width(25) start(0) bfcolor(none) blcolor(red) freq legend(title("Linear payment treatment") order(1 "Trees alive (stated)" 2 "Trees alive (observed)"))
			graph export "$output/Bunching_treat1.pdf", replace

			
			twoway histogram arbres_plante if treatment == 1, width(50) start(0) bfcolor(blue) blcolor(blue) barw(5)  freq ///
				|| histogram arbres_plante if treatment == 2, width(50) start(0) bfcolor(none) blcolor(red) freq legend(title("Stated number of trees alive") order(1 "Linear payment treatment" 2 "Threshold payment treatment"))
			graph export "$output/Bunchung_treat1-2.pdf", replace
				
				
				
			gen LastTwoDigitsTreesStatedAlive=arbres_vivant-int(arbres_vivant/100)*100 if treatment == 2
			* Test for overrepresentation "just above the threshold" -- focusing on observed numbers in the bottom half of the range
			gen StatedCloseToThr_50 = 0  if treatment == 2
			replace StatedCloseToThr_50 = 1 if LastTwoDigitsTreesStatedAlive < 50 & treatment == 2
			ttest StatedCloseToThr_50 = 0.5 if treatment == 2
			
			* Test for overrepresentation "just above the threshold" -- focusing on observed numbers in the bottom half of the range
			gen StatedCloseToThr_25 = 0  if treatment == 2
			replace StatedCloseToThr_25 = 1 if LastTwoDigitsTreesStatedAlive < 25 & treatment == 2
			ttest StatedCloseToThr_25 = 0.25 if treatment == 2
			* No evidence of bunching for stated survival rates either
	
		
		
		
		
		
	** ANALYSIS OF TREE SURVIVAL DATA -- ROLE OF BACKGROUND CHARACTERISTICS
	use "$DataWork/III_Endline_Reforestation/DataSets/Intermediate/DaanFullDataSet2018_08_27.dta", clear
	
	
	keep if TreatmentParticipant == 1 // TreatmentParticipant defined as all those who show up in the payment file, so all control hhs are removed
	drop if treatment == 3
	generate count_partic = 1 
	generate NumbTreesAliveObserved = int(shalive * arbres_plante)
	generate TreesAliveStated_Observed = arbres_vivant - NumbTreesAliveObserved
	rename sexe1 female
	rename sbq11 annualincome_prim
	rename sbq15 annualincome_sec
	rename sbq18 hhhead

	rename sbq21 educlevel
	rename sbq22 GGFmember
	rename sbq24 plotclose
	generate transport = 0 if sbq25 == 1
	replace transport = 1 if sbq25 == 2 | sbq25 == 3

	generate numbagricequip = scq1_100 + scq1_101 + scq1_102 + scq1_103 + scq1_104 + scq1_105 + scq1_106 + scq1_107 + scq1_108 + scq1_109 + scq1_110 + scq1_111 + scq1_112 + scq1_113 + scq1_114 + scq1_115 + scq1_116
	generate numbhomeluxuries = (2*30) - (scq3_200 + scq3_201 + scq3_202 + scq3_203 + scq3_204 + scq3_205 + scq3_206 + scq3_207 + scq3_208 + scq3_209 + scq3_210 + scq3_211 + scq3_212 + scq3_213 + scq3_214 + scq3_215 + scq3_216 + scq3_217 + scq3_218 + scq3_219 + scq3_220 + scq3_221 + scq3_222 + scq3_223 + scq3_224 + scq3_225 + scq3_226 + scq3_227 + scq3_228 + scq3_229) // oui =1, non =2

	replace scq6a_300 = 1500 if scq6a_300 < 1500 // price chicken
	replace scq6a_300 = 3000 if scq6a_300 > 30000 // price chicken
	replace scq6a_300 = 0 if scq6_300 == .
	replace scq6a_301 = 75000 if scq6a_301 < 75000 // price cow
	replace scq6a_301 = 300000 if scq6a_301 > 300000 // price cow
	replace scq6a_301 = 0 if scq6_301 == .
	replace scq6a_302 = 10000 if scq6a_302 < 10000 // price pig
	replace scq6a_302 = 30000 if scq6a_302 > 30000 // price pig
	replace scq6a_302 = 0 if scq6_302 == .
	replace scq6a_303 = 10000 if scq6a_303 < 10000 // price goat
	replace scq6a_303 = 30000 if scq6a_303 > 30000 // price goat
	replace scq6a_303 = 0 if scq6_303 == .
	replace scq6a_304 = 30000 if scq6a_304 < 30000 // price donkey
	replace scq6a_304 = 75000 if scq6a_304 > 75000 // price donkey
	replace scq6a_304 = 0 if scq6_304 == .
	replace scq6a_305 = 0 if scq6_305 == .
	foreach var of varlist scq6_30* {
		replace `var' = 0 if `var' == .
		}
	generate valuelivestock = (scq6_300 * scq6a_300) + (scq6_301 * scq6a_301) + (scq6_302 * scq6a_302) + (scq6_303 * scq6a_303) + (scq6_304 * scq6a_304) + (scq6_305 * scq6a_305)

	generate ownsmotorc = 2 - scq3_206
	rename sdq1 ownsland
	rename sdq2 landarea
	rename sdq6 fertilizer
	
	label variable female "Gender is female"
	label variable annualincome_prim "Primary annual income" 
	label variable annualincome_sec "Secondary annual income"
	label variable hhhead "Household Head"
	label variable educlevel  "Education level"
	label variable GGFmember  "GGF member"
	label variable plotclose "Plot proximity to homestead "
	label variable numbagricequip "count of ag equipements owned" 
	label variable numbhomeluxuries "Count of home luxuries owned"
	label variable valuelivestock "Value of livestock assets"
	label variable ownsmotorc "Ownership of motorcycle"
	label variable ownsland "Ownership of land"
	label variable landarea "Area of landholdings"
	label variable fertilizer "Purchased fertilizer during ag season"
	
	* BALANCE TEST
	orth_out female age annualincome_prim annualincome_sec hhhead educlevel GGFmember plotclose transport numbagricequip numbhomeluxuries valuelivestock ///
	ownsmotorc ownsland landarea fertilizer, by(treatment) se compare test count 

			iebaltab 	female age annualincome_prim annualincome_sec hhhead educlevel GGFmember plotclose					///
						transport numbagricequip numbhomeluxuries valuelivestock ownsmotorc ownsland landarea fertilizer,   ///
						grpvar(treatment) grplabels(1 Linear @ 2 Threshold)  ///
						/// vce(cluster forestid) ///
						total rowvarlabels pftest ///
						tblnote(".") ///
						savetex("$output/delete_me.tex") ///
						replace 

			filefilter  "$output/delete_me.tex" "$output/Balance_test.tex",        ///                                                          
						from("/BShline") to("/BScline{1-8}") replace  
	
	
	
	
	
	
	save "C:\Users\soest\Dropbox\DataWork\III_Endline_Reforestation\Dofiles\Analysis\temp.dta", replace

	
	
	
	
	
	use "$DataWork/III_Endline_Reforestation/Dofiles/Analysis/temp.dta",clear
	
	collapse (mean) shalive shwellalive shwellalive_red shwellalive_blue shalive_blue shalive_red statedSR statedSR_blue statedSR_red TreesAliveStated_Observed NumbTreesAliveObserved ///
	female hhhead arbres_plante annualincome_prim annualincome_sec educlevel GGFmember ///
	plotclose transport  numbagricequip numbhomeluxuries valuelivestock ownsmotorc ownsland landarea fertilizer  ///
	(max) age ///
	(firstnm) treatment, by(region site bloc parcelle)
	
	
	
	* ANALYSIS OF SURVIVAL RATES
	generate lnpriminc = ln(annualincome_prim)
	generate lnvallivest = ln(valuelivestock)
	generate treatthresh = treatment - 1 
	
	
	ttest shwellalive, by(treatthresh)
	
	reg shwellalive treatthresh lnpriminc GGFmember female age lnvallivest, robust cluster(bloc) // Not bad
	reg shwellalive treatthresh lnpriminc GGFmember lnvallivest, robust cluster(bloc) // Not bad

	eststo clear
	eststo: reg shwellalive treatthresh lnpriminc GGFmember female age lnvallivest, robust cluster(bloc)
	eststo: reg shwellalive treatthresh lnpriminc GGFmember lnvallivest, robust cluster(bloc)
	esttab using "$output/regression_table1.tex", nolabel se star(* 0.10 ** 0.05 *** 0.01) addnote("Standarderrors are robust and clustered at the bloc level.") replace

	

	label variable treatthresh "Threshold based contract"
	label variable lnpriminc "(Log) Primary Annual Income"
	label variable GGFmember "Proportion of GGF members in group"
	label variable female "Proportion of female in group"
	label variable age "Average age of group"
	label variable lnvallivest "(Log) Value of Livestock Assets"
	label variable shalive  "Share of trees alive"
	label variable shwellalive "Share of trees well alive"
	
	
	
			iebaltab 	shalive shwellalive,   ///
						grpvar(treatment) grplabels(1 Linear @ 2 Threshold)  ///
						vce(cluster bloc) ///
						total rowvarlabels pftest ///
						tblnote(".") ///
						savetex("$output/delete_me.tex") ///
						replace 

			filefilter  "$output/delete_me.tex" "$output/Outcome_test.tex",        ///                                                          
						from("/BShline") to("/BScline{1-8}") replace  	
	
	
	

	estimates clear
	
	
	***************	

	reg shwellalive treatthresh lnpriminc GGFmember female age lnvallivest, robust cluster(bloc)
		eststo
		estadd 	local Cluster 	     	"Bloc"
		
		
	reg shwellalive treatthresh lnpriminc GGFmember lnvallivest, robust cluster(bloc)
		eststo
		estadd 	local Cluster 	     	"Bloc"

		
		esttab using 	"$output/delete_me.tex", replace ///
						varwidth(5) modelwidth(1) width(0.6\hsize) bracket label r2 ar2 p(%9.3f) ///
						nobaselevels noomitted interaction(" X ") ///
						 nomtitles ///						
						star(+ 0.15  * 0.10  ** 0.05  *** 0.01) ///						
						scalars("Cluster Cluster") ///
						/// mtitles("1" "2" "3" "4") ///
						addnotes(Notes: P value in bracket. \sym{+} \(p<0.15\), \sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)) nonotes 
						
		filefilter 	"$output/delete_me.tex" "$output/regression_table1.tex", 	///				
                            from("\BShline") to("\BScline{1-3}") replace 
							

	
	/* TEST FOR INTERACTION EFFECTS; DOES NOT WORK
	generate thrlnpriminc = treatthresh * lnpriminc
	generate thrlnvallivest = treatthresh * lnvallivest
	generate thrGGFmember = treatthresh * GGFmember 
	generate thrfemale = treatthresh * female
	*/
	

	
