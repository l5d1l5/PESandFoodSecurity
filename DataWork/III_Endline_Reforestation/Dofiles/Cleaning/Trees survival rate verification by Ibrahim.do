
    
	/* This do file compile the data from the survival rate verification done 
			by Ibrahim half way through  */
	
	
	*******************************************************
	*Preparing the relevant settings
	*******************************************************
	
	* Settings globals
	
	* Verify directory path by running 

	dis "`c(username)'" // The text that shows up is the username of your computer (say XXX), and insert that into the code below 

	*change to working directory 

	if c(username)=="WB495145" {
			cd "C:/Users/WB495145/Dropbox/World Bank projects/PROJECTS\1-BURKINA FORESTRY\Burkina Forests\Doc cemes pif\Data"
            }
	*
	
	if c(username)=="sergeadjognon" {
            cd "/Volumes/My Passport for Mac/CloudDocs/Dropbox/World Bank projects/PROJECTS\1-BURKINA FORESTRY\Burkina Forests\Doc cemes pif\Data"

            }
	*	

	

	* Install ietoolkit
	*ssc install ietoolkit, replace

	*Set standardized settings
	*ieboilstart, v(11.1)
	*`r(version)'
	
	********************************************************************************



cd "C:\Users\WB495145\Dropbox\World Bank projects\PROJECTS\1-BURKINA FORESTRY\Burkina Forests\Doc cemes pif\Data"

preserve
		
		*Import the Excel sheet with treatment status
		import excel using "COORDONNEES_PLANTS_REBOISEMENT_PIF_2018_0.xls", firstrow clear


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
	
	restore
	

	
* survival rate data	
	
		import excel using "estimation taux de survie.xls",  sheet("Sheet1")  firstrow clear
		
		* Create the label for the treatment dummy
		*label define treatment 1 "Parcelle Bleue"  2 "Parcelle Rouge"  3 "Parcelle Verte"
		
		* Encode the tmt variable and apply the label
		encode 	parcelle , gen(tmt) label(treatment)
		encode bloc, gen(blocid) label(blocid)
		*label values tmt treatment
drop if tmt==3
generate tmt_thresh=tmt==1 //(blue parcelle - linear)
tab tmt		
ritest tmt_thresh _b[tmt_thresh], seed (278) kdensityplot  reps(5000) strata(blocid):  regress tx_survie tmt_thresh
