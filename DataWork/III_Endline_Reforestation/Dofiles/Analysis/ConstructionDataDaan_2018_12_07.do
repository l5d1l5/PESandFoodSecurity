* Verify directory path by running 

	dis "`c(username)'" // The text that shows up is the username of your computer (say XXX), and insert that into the code below
	
	
   * Root folder globals
   * ---------------------

   if c(username)=="WB495145" {
       cd "C:/SD Card/Cloud Docs/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY"
   }

   if c(username)=="sergeadjognon" {
       cd "/Volumes/My Passport for Mac/CloudDocs/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY"  //Enter the file path to the projectfolder of next user here
   }
   
   if c(username)=="soest"  {
	   cd "d:/Dropbox"										
	   *cd "C:\Users\soest\Dropbox"
	}	
*

** 1. MERGE DATA SETS 
* Merge in three steps; A. merge observed and reported survival data, B. merge baseline participant data with payment data, and C. merge them all

* A. MERGE OBSERVED SURVIVAL RATE DATA WITH THE REPORTED ONES
use "DataWork/III_Endline_Reforestation/DataSets/Intermediate/collector_app_data_construct.dta", clear

drop latitude fixtime longitude x y date heure globalid x2 y2 creationdate creator editdate editor objectid_1

* Create indicators for tree species
generate Baobab = 0
replace Baobab = 1 if espece_code == 4
generate Epineux = 0
replace Epineux  = 1 if espece_code == 6

tab Baobab if bloc == "BISSANDEROU"

** Histograms
generate ParcelleBleue = 1 if parcelle == "Parcelle BLEU"
histogram condition_code if ParcelleBleue == 1, fraction discrete xlabel(0/5, valuelabel) scale(0.8) title("Paiements lineaires") xtitle("") yscale(range(0 0.6))
generate ParcelleRouge = 1 if parcelle == "Parcelle ROUGE"
histogram condition_code if ParcelleRouge == 1, fraction discrete xlabel(0/5, valuelabel) scale(0.8) title("Paiements seuils") xtitle("") yscale(range(0 0.6))
generate ParcelleVerte = 1 if parcelle == "Parcelle VERTE"
histogram condition_code if ParcelleVerte == 1, fraction discrete xlabel(0/5, valuelabel) scale(0.8) title("Paiements lineaires, chef CGF") xtitle("") yscale(range(0 0.6))
**

generate wellalive = 0
replace wellalive = 1 if vivant1 == 100
sum wellalive

generate alive = 0
replace alive = 1 if vivant2 == 100
sum alive

generate dead_burnt = 0
replace dead_burnt = 1 if explication == 2
sum dead_burnt

generate dead_eaten = 0
replace dead_eaten = 1 if explication == 1
sum dead_eaten

generate dead_unknown = 0
replace dead_unknown = 1 if explication == 0
sum dead_unknown

generate dead_draught = 0
replace dead_draught = 1 if explication == 3
sum dead_draught

collapse (sum) alive wellalive dead_eaten dead_draught dead_unknown dead_burnt Baobab Epineux count (firstnm) enqueteur region site bloc parcelle treatment, by(siteid blocid parcelleid)
rename enqueteur SurveyID_Surrv

local outcomevarsabs alive wellalive dead_eaten dead_draught dead_unknown dead_burnt Baobab Epineux
foreach var in `outcomevarsabs' {
	generate sh`var' = `var' / count
}

sort siteid blocid treatment

* Merge with self-reported survival rates
merge 1:1 region site bloc parcelle using "DataWork/III_Endline_Reforestation/DataSets/Intermediate/self reported survival_clean.dta", gen(mergeA)

** There are stated survival rates for 99 blocks (3 blocks in 11 forests), but observed rates are available for jus 93 blocks
** There is no observed data for NOSEBOU forest, and also not for the MATIACOALI block in TAPOABOOPO forest
** Get rid of these by dropping them:
	* drop if mergeA == 2
	* drop mergeA
	
	* Create treatment variable for obs in stated survival data for which treatment is missing (parcelle gives the treatment names)
	replace treatment = 1 if treatment == . & parcelle == "Parcelle BLEU"
	replace treatment = 2 if treatment == . & parcelle == "Parcelle ROUGE"
	replace treatment = 3 if treatment == . & parcelle == "Parcelle VERTE"
	
	*Create StatedSurvivalRates
	
	generate statedSR = arbres_vivant/arbres_plante
	generate statedSR_blue = statedSR if treatment == 1  /* lineair */
	label variable statedSR_blue "stated survival rate, Lineair"
	
	generate statedSR_red = statedSR if treatment == 2  /* lineair */
	label variable statedSR_red "stated survival rate, threshold"
	
	generate shwellalive_blue = shwellalive if treatment == 1  /* en bonne etat, lineair */
	label variable shwellalive_blue "Lineair, plant vivant en bonne etat"
	
	generate shwellalive_red = shwellalive if treatment == 2  /* en bonne etat, seuil */
	label variable shwellalive_red "Seuil, plant vivant en bonne etat"
	
	generate shalive_blue = shalive if treatment == 1  /* en vie, quelque soit l'etat, lineair */
	label variable shalive_blue "Lineair, plant vivant quelque soit l'etat"

	generate shalive_red = shalive if treatment == 2  /* en vie, quelque soit l'etat, seuil */
	label variable shalive_blue "Seuil, plant vivant quelque soit l'etat"

save "DataWork/III_Endline_Reforestation/DataSets/Intermediate/DaanSurvivalData2018_12_07", replace

* B. MERGE BASELINE PARTICIPANT SURVEY DATA AND THE ACTUAL PAYMENTS RECEIVED IN JULY 2018

use "DataWork/II_Baseline_Reforestation/DataSets/Intermediate/participant_survey_clean.dta", clear // Baseline survey
* Check for duplicates. BAKO VROUBIE has two records, 334 (control ROUGE) and 335 (control BLEU ). Does not show up in payment file, so observation is in control. Randomly chose 334. 
* BASSOLE YOMBIE has two records, 257 (control) and 258 (treatment). Shows up in payment file, so observation is in treatment (=258), and not control (=257). 
* LOUE ADAMA has two records, 204 (treatment bleue) and 205 (treatment rouge). Shows up in payment file twice (rouge and blue), but is just one individual. So which of the two is correct???
* ZANTE LASSINA has two records, 73 (control rouge) and 74 (treatment bleu). Shows up in payment file in BLEU, so observation is in treatment (=74), and not control (=73). 
/*
sort region foret bloc statut parcelle nom prenom
by region foret bloc nom prenom:  gen dup = cond(_N==1,0,_n)
sort dup 
sum dup
sort  nom prenom region foret bloc parcelle \\ there are still records that are very similar (same location, different parcelle), but seem different individuals
*/

drop if objectid == 335 // BAKO VROUBIE has two records. Does not show up in payment file, so control. Maybe Controle Rouge (=334) or Controle Bleue (=335)
drop if objectid == 257 // BASSOLE YOMBIE has two records, 257 (control) and 258 (treatment). Shows up in payment file, so treatment. 
drop if objectid == 73 // ZANTE LASSINA has two records. Shows up in payment file in BLEU, so observation is in treatment (=74), and not control (=73). 


rename region region1
decode region1, gen(region)
decode foret, gen(site)
rename sexe sexe1
decode sexe1, gen(sexe)
decode enqueteur, gen(surveyorID_BasePart)
drop enqueteur

rename treatment TreatmentParticipantBaseline // forest and site identical labels

save "DataWork/II_Baseline_Reforestation/DataSets/Intermediate/Daan_participant_survey_clean.dta", replace

*Actual payments received
use "DataWork/III_endline_Reforestation/DataSets/Intermediate/actual paiement made_clean.dta", clear // those who received payments; all treatment.
sort nom prenom region site bloc 

generate TreatmentParticipantPayment = 1
/* Check for duplicates
sort region site bloc nom prenom
by region site bloc nom prenom:  gen dup = cond(_N==1,0,_n)
sort dup 
sum dup
sort  nom prenom region site bloc parcelle // there are still records that are very similar (same location, different parcelle), but seem different individuals
*/


merge 1:1 region site bloc parcelle nom prenom using "DataWork/II_Baseline_Reforestation/DataSets/Intermediate/Daan_participant_survey_clean.dta", gen(mergeB)
replace TreatmentParticipantPayment = 0 if TreatmentParticipantPayment == .

* Poor matching -- why???
sort region site bloc nom prenom 
*keep region site bloc parcelle nom prenom sexe region1 foret statut sexe1 mergeB TreatmentParticipantPayment TreatmentParticipantBaseline
drop if mergeB == 1


* C. CONSTRUCTING THE JOINT DATA FILE
merge m:1 region site bloc parcelle using "DataWork/III_Endline_Reforestation/DataSets/Intermediate/DaanSurvivalData2018_12_07.dta", gen(mergeC)

save "DataWork/III_Endline_Reforestation/DataSets/Intermediate/DaanFullDataSet2018_08_27", replace
