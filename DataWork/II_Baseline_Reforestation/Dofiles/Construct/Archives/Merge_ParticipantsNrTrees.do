





	*******************************************************
	*Preparing the relevant settings
	*******************************************************
	
	* Settings globals
	
	* Verify directory path by running 

	dis "`c(username)'" // The text that shows up is the username of your computer (say XXX), and insert that into the code below 

	*change to working directory 

	if c(username)=="WB495145" {
            cd "C:/Users/WB495145/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY/"
            }
	*
	
	if c(username)=="sergeadjognon" {
            cd "/Volumes/My Passport for Mac/CloudDocs/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY/"

            }
	*
	
		if c(username)=="soest" {
            cd "C:/Users/soest/Dropbox/"

            }
	*
	
	
	* Install ietoolkit
	*ssc install ietoolkit, replace

	*Set standardized settings
	*ieboilstart, v(11.1)
	*`r(version)'
	
	********************************************************************************
	

import excel "BF_PIFCemes/DATA/participants survey/tracking_list.xls", sheet("tracking") firstrow clear

drop if groupe == 2 | groupe == 4

rename groupe treatment

#delimit ;
label define treatment_label
1 "Treatment group payment linear"
2 "Control group payment linear"
3 "Treatment linear individual payments"
4 "Controle linear individual payments";
label value treatment treatment_label;
#delimit cr

import excel "BF_PIFCemes/DATA/reforestation Data/COORDONNEES_PLANTS_REBOISEMENT_PIF_2018_0.xls", sheet("COORDONNEES_PLANTS_REBOISEMENT_") firstrow clear

		* Create the label for the treatment dummy
		label define treatment 0 "control" 1 "treatment"
		
		* Encode the tmt variable and apply the label
		rename 	tmt tmt_string 
		encode 	tmt_string , gen(tmt) label(treatment)
		drop 	tmt_string		
		
		** Use a temporary file instead of saving a .dta file in the folder. 
		*  Otherwise the project folder will be cluttered with intermediate 
		*  data sets
		tempfile tmtStatusMerge
		save	`tmtStatusMerge', replace
	
