* Verify directory path by running 

	dis "`c(username)'" // The text that shows up is the username of your computer (say XXX), and insert that into the code below
	
	
   * Root folder globals
   * ---------------------

   if c(username)=="WB495145" {
       global projectfolder "C:\Users\WB495145\Dropbox\World Bank projects\PROJECTS\1-BURKINA FORESTRY"
   }

   if c(username)=="sergeadjognon" {
       global projectfolder "/Volumes/My Passport for Mac/CloudDocs/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY"  //Enter the file path to the projectfolder of next user here
   }
   
   if c(username)=="soest"  {
	   cd "C:\Users\soest\Dropbox"										
	}



** MERGE DATA SETS 
* Merge in three steps; A. merge observed and reported survival data, B. merge baseline participant data with payment data, and C. merge them all

* A. MERGE OBSERVED SURVIVAL RATE DATA WITH THE REPORTED ONES
use "DataWork\III_Endline_Reforestation\DataSets\Intermediate\collector_app_data_construct.dta", clear

drop latitude fixtime longitude x y date heure globalid x2 y2 creationdate creator editdate editor objectid_1

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

collapse (sum) alive wellalive dead_eaten dead_draught dead_unknown dead_burnt count (firstnm) enqueteur region site bloc parcelle treatment, by(siteid blocid parcelleid)
encode enqueteur, gen(surveyorID)

local outcomevarsabs alive wellalive dead_eaten dead_draught dead_unknown dead_burnt
foreach var in `outcomevarsabs' {
	generate sh`var' = `var' / count
}

sort siteid blocid treatment

* Merge with self-reported survival rates
merge 1:1 region site bloc parcelle using "DataWork\III_Endline_Reforestation\DataSets\Intermediate\self reported survival_clean.dta", gen(mergeA)

save "DataWork\III_Endline_Reforestation\DataSets\Intermediate\DaanSurvivalData2018-08-26", replace
* ANALYSIS BLOCK USED TO BE HERE...



* B. MERGE BASELINE PARTICIPANT SURVEY DATA AND THE ACTUAL PAYMENTS RECEIVED IN JULY 2018

use "DataWork\II_Baseline_Reforestation\DataSets\Intermediate\participant_survey_clean.dta", clear
/*sort region foret bloc parcelle nom prenom
by region foret bloc parcelle nom prenom:  gen dup = cond(_N==1,0,_n)
sort dup */
drop if objectid == 257 // BASSOLE YOMBIE has two records, 257 (control) and 258 (treatment). Shows up in payment file, so treatment. 
rename region region1
decode region1, gen(region)
decode foret, gen(site)
rename sexe sexe1
decode sexe1, gen(sexe)
save "DataWork\II_Baseline_Reforestation\DataSets\Intermediate\Daan_participant_survey_clean.dta", replace

use "DataWork\III_endline_Reforestation\DataSets\Intermediate\actual paiement made_clean.dta", clear
merge 1:1 region site bloc parcelle nom prenom using "DataWork\II_Baseline_Reforestation\DataSets\Intermediate\Daan_participant_survey_clean.dta", gen(mergeB)

