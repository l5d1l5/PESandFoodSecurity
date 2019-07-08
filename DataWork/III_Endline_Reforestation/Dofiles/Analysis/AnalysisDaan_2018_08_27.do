* Verify directory path by running 

	dis "`c(username)'" // The text that shows up is the username of your computer (say XXX), and insert that into the code below
	
	
   * Root folder globals
   * ---------------------

   if c(username)=="WB495145" {
      cd "C:/SD Card/Cloud Docs/Dropbox\World Bank projects\PROJECTS\1-BURKINA FORESTRY"
   }

   if c(username)=="sergeadjognon" {
       cd "/Volumes/My Passport for Mac/CloudDocs/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY"  //Enter the file path to the projectfolder of next user here
   }
   
   if c(username)=="soest"  {
	   *cd "D:\Dropbox"										
	   cd "C:\Users\soest\Dropbox"
	}




** ANALYSIS OF TREATMENT DIFFERENCES IN SURVIVAL RATES -- OBSERVED, AND STATED

use "DataWork\III_Endline_Reforestation\DataSets\Intermediate\DaanSurvivalData2018_08_27", clear

encode parcelle, gen(parcel)
tab bloc, gen(block)

reg shwellalive i.parcel i.blocid, robust
	
	XXX
	* Power test; Minimum detectable effect = 0.0723 with 80% power
	
		preserve
		keep blocid treatment statedSR shalive shwellalive shdead_eaten shdead_draught shdead_unknown shdead_burnt
		drop if treatment == 3
		drop if blocid == .

		reshape wide statedSR shalive shwellalive shdead_eaten shdead_draught shdead_unknown shdead_burnt, i(blocid) j(treatment)
		
		sum shalive1 // Linear payment scheme
		global meanshalive1 = r(mean)
		global sdshalive1 = r(sd)
		di $meanshalive1
		di $sdshalive1

		sum shalive2 // Threshold payment scheme
		global meanshalive2 = r(mean)
		global sdshalive2 = r(sd)
		di $meanshalive2
		di $sdshalive2
	
		pwcorr shalive1 shalive2
		global corr = r(rho)
		di $corr
	
		power pairedmeans $meanshalive2, n(62) alpha(0.05) sd(0.2) corr(0.5) power(0.8) direction(lower)
		* Parameter values based on average observed standard deviation, on the observed mean for one of the treatments, and the rough correlation between linear and threshold
		restore
	
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
		ttest statedSR1 = shalive1 /* no significant difference self-reported and observed in linear... */
		ttest statedSR2 = shalive2 /* but it is significantly higher in threshold... */
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
		/*list parcelleid  NumbTreesAliveObserved arbres_vivant OverreportSR  BeneficialOverreportSR if treatment == 2

		list parcelleid  NumbTreesAliveObserved arbres_vivant if BeneficialOverreportSR == 1 if treatment == 2

		list parcelleid  NumbTreesAliveObserved arbres_vivant TreesAliveStated_Observed  if treatment == 2 & BeneficialOverreportSR == 1
		sort TreesAliveStated_Observed
		list parcelleid TreesAliveStated_Observed if treatment == 2 & OverreportSR == 1
		*/
		
		ttest TreesAliveStated_Observed if treatment == 2, by(BeneficialOverreportSR) 
		* Amount of overreporting fairly substantial. Half (=18/31) of the threshold parcels reported higher numbers than observed, but for only 
		tab OverreportSR treatment if treatment != 3 & NumbTreesAliveObserved != ., exact // No difference in propensity to overreport
		tab OverreportSR BeneficialOverreportSR if treatment == 2 // 10 of the 18 that overreported benefitted from that
		ttest TreesAliveStated_Observed if treatment != 3 & OverreportSR == 1, by(treatment)
		ttest TreesAliveStated_Observed = 0 if treatment == 1 // No significant overreporting in linear
		ttest TreesAliveStated_Observed = 0 if treatment == 2 // But significant in threshold
		
		reg TreesAliveStated_Observed treatment if treatment != 3
		
		use "DataWork\III_Endline_Reforestation\Dofiles\Analysis\temp0.dta", clear
		* Test for bunching near threshold
			*Test for bunching of observed survival rates
			histogram NumbTreesAliveObserved if treatment == 2, fraction width(25) start(0)
			histogram NumbTreesAliveObserved if treatment == 1, fraction width(25) start(0)
			
			twoway histogram NumbTreesAliveObserved if treatment == 1, width(50) start(0) bfcolor(blue) blcolor(blue) barw(5)  freq ///
				|| histogram NumbTreesAliveObserved if treatment == 2, width(50) start(0) bfcolor(none) blcolor(red) freq legend(order(1 "Linear payments" 2 "Threshold payments"))

			gen LastTwoDigitsTreesObsAlive=NumbTreesAliveObserved-int(NumbTreesAliveObserved/100)*100 if treatment == 2
		
			* Test for overrepresentation "just above the threshold" -- focusing on observed numbers in the bottom half of the range
			gen ObsCloseToThr_50 = 0  if treatment == 2
			replace ObsCloseToThr_50 = 1 if LastTwoDigitsTreesObsAlive < 50 & treatment == 2
			ttest ObsCloseToThr_50 = 0.5 if treatment == 2
			
			* Test for overrepresentation "just above the threshold" -- focusing on observed numbers in the bottom half of the range
			gen ObsCloseToThr_25 = 0  if treatment == 2
			replace ObsCloseToThr_25 = 1 if LastTwoDigitsTreesObsAlive < 25 & treatment == 2
			ttest ObsCloseToThr_25 = 0.25 if treatment == 2
			* No evidence of bunching for observed 
			
		*Test for bunching of stated survival rates
			histogram arbres_vivant if treatment == 2, fraction width(25) start(0)
			
			twoway histogram arbres_plante if treatment == 2, width(25) start(0) bfcolor(blue) blcolor(blue) barw(5)  freq ///
				|| histogram NumbTreesAliveObserved if treatment == 2, width(25) start(0) bfcolor(none) blcolor(red) freq legend(title("Threshold payment treatment") order(1 "Trees alive (stated)" 2 "Trees alive (observed)"))

				
			twoway histogram arbres_plante if treatment == 1, width(25) start(0) bfcolor(blue) blcolor(blue) barw(5)  freq ///
				|| histogram NumbTreesAliveObserved if treatment == 1, width(25) start(0) bfcolor(none) blcolor(red) freq legend(title("Linear payment treatment") order(1 "Trees alive (stated)" 2 "Trees alive (observed)"))

			twoway histogram arbres_plante if treatment == 1, width(50) start(0) bfcolor(blue) blcolor(blue) barw(5)  freq ///
				|| histogram arbres_plante if treatment == 2, width(50) start(0) bfcolor(none) blcolor(red) freq legend(title("Stated number of trees alive") order(1 "Linear payment treatment" 2 "Threshold payment treatment"))

				
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
use "DataWork\III_Endline_Reforestation\DataSets\Intermediate\DaanFullDataSet2018_08_27", clear
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
	
	orth_out female age annualincome_prim annualincome_sec hhhead educlevel GGFmember plotclose transport numbagricequip numbhomeluxuries valuelivestock ///
	ownsmotorc ownsland landarea fertilizer, by(treatment) se compare test count 

	save "C:\Users\soest\Dropbox\DataWork\III_Endline_Reforestation\Dofiles\Analysis\temp.dta", replace

	
	
	use "C:\Users\soest\Dropbox\DataWork\III_Endline_Reforestation\Dofiles\Analysis\temp.dta",clear
	
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

	
	/* TEST FOR INTERACTION EFFECTS; DOES NOT WORK
	generate thrlnpriminc = treatthresh * lnpriminc
	generate thrlnvallivest = treatthresh * lnvallivest
	generate thrGGFmember = treatthresh * GGFmember 
	generate thrfemale = treatthresh * female
	*/
	

	
