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
	   *cd "d:/Dropbox"										
	   cd "C:\Users\soest\Dropbox"
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

save "DataWork/III_Endline_Reforestation/DataSets/Intermediate/DaanSurvivalData2018_08_27", replace
* ANALYSIS BLOCK USED TO BE HERE...

* B. MERGE BASELINE PARTICIPANT SURVEY DATA AND THE ACTUAL PAYMENTS RECEIVED IN JULY 2018

use "DataWork/II_Baseline_Reforestation/DataSets/Intermediate/participant_survey_clean.dta", clear
/*sort region foret bloc parcelle nom prenom
by region foret bloc parcelle nom prenom:  gen dup = cond(_N==1,0,_n)
sort dup */
drop if objectid == 257 // BASSOLE YOMBIE has two records, 257 (control) and 258 (treatment). Shows up in payment file, so treatment. 
rename region region1
decode region1, gen(region)
decode foret, gen(site)
rename sexe sexe1
decode sexe1, gen(sexe)
decode enqueteur, gen(surveyorID_BasePart)
drop enqueteur

drop treatment

save "DataWork/II_Baseline_Reforestation/DataSets/Intermediate/Daan_participant_survey_clean.dta", replace

use "DataWork/III_endline_Reforestation/DataSets/Intermediate/actual paiement made_clean.dta", clear
generate TreatmentParticipant = 1
merge 1:1 region site bloc parcelle nom prenom using "DataWork/II_Baseline_Reforestation/DataSets/Intermediate/Daan_participant_survey_clean.dta", gen(mergeB)

* C. CONSTRUCTING THE JOINT DATA FILE
merge m:1 region site bloc parcelle using "DataWork/III_Endline_Reforestation/DataSets/Intermediate/DaanSurvivalData2018_08_27.dta", gen(mergeC)

save "DataWork/III_Endline_Reforestation/DataSets/Intermediate/DaanFullDataSet2018_08_27", replace
