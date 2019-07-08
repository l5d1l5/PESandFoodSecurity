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
merge 1:1 region site bloc parcelle using "DataWork\III_Endline_Reforestation\DataSets\Intermediate\self reported survival_clean.dta", gen(merge1)
drop if merge1 == 2

* generate 
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

ttest shwellalive if treatment != 3, by(treatment)
sdtest shwellalive_red = shwellalive_blue

regress shwellalive i.treatment i.blocid i.surveyorID if treatment!=3, robust cluster(blocid) /* Hm, impact of surveyor not clear */
regress shalive i.treatment i.blocid if treatment!=3, robust cluster(blocid)

* How bad have we been cheated?
pwcorr statedSR shalive
ttest statedSR = shalive
ttest statedSR = shalive if treatment == 1
ttest statedSR = shalive if treatment == 2

* tests using within-block matching

preserve /*only differences on shares of trees alive (especially for wellalive), no differences for reasons of death. */
keep blocid treatment statedSR shalive shwellalive shdead_eaten shdead_draught shdead_unknown shdead_burnt
drop if treatment == 3
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


use "DataWork\II_Baseline_Reforestation\DataSets\Intermediate\participant_survey_clean.dta", clear







