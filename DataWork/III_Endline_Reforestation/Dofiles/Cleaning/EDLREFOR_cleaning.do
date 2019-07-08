



	*************************
	*	SETTINGS DIRECTORY	*
	*************************
 
if (1) { 


	* Verify directory path by running 

	dis "`c(username)'" // The text that shows up is the username of your computer (say XXX), and insert that into the code below
	
	
   * Root folder globals
   * ---------------------

   if c(username)=="WB495145" {
       global projectfolder "C:\SD Card\Cloud Docs\Dropbox\World Bank projects\PROJECTS\1-BURKINA FORESTRY"
   }

   if c(username)=="sergeadjognon" {
       global projectfolder "/Volumes/My Passport for Mac/CloudDocs/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY"  //Enter the file path to the projectfolder of next user here
 
   }
   
   if c(username)=="soest"  {
	   global projectfolder "C:\Users\soest\Dropbox"										
	}


*These lines are used to test that name ois not already used (do not edit manually)
*round*I_RemoteSensing*STLDATA*II_Baseline_Reforestation*BSLREFOR*III_Endline_Reforestation*EDLREFOR
*untObs*************************************************************************
*subFld*************************************************************************
*iefolder will not work properly if the lines above are edited


   * Project folder globals
   * ---------------------

   global dataWorkFolder         "$projectfolder/DataWork"

*iefolder*1*FolderGlobals*subfolder*********************************************
*iefolder will not work properly if the line above is edited


*iefolder*1*FolderGlobals*master************************************************
*iefolder will not work properly if the line above is edited

   global mastData               "$dataWorkFolder/MasterData" 

*iefolder*1*FolderGlobals*encrypted*********************************************
*iefolder will not work properly if the line above is edited

   global encryptFolder          "$dataWorkFolder/EncryptedData" 


*iefolder*1*RoundGlobals*rounds*I_RemoteSensing*STLDATA*************************
*iefolder will not work properly if the line above is edited

   *I_RemoteSensing folder globals
   global STLDATA                "$dataWorkFolder/I_RemoteSensing" 
   global STLDATA_encrypt        "$encryptFolder/Round I_RemoteSensing Encrypted" 
   global STLDATA_dt             "$STLDATA/DataSets" 
   global STLDATA_do             "$STLDATA/Dofiles" 
   global STLDATA_out            "$STLDATA/Output" 


*iefolder*1*RoundGlobals*rounds*II_Baseline_Reforestation*BSLREFOR**************
*iefolder will not work properly if the line above is edited

   *II_Baseline_Reforestation folder globals
   global BSLREFOR               "$dataWorkFolder/II_Baseline_Reforestation" 
   global BSLREFOR_encrypt       "$encryptFolder/Round II_Baseline_Reforestation Encrypted" 
   global BSLREFOR_dt            "$BSLREFOR/DataSets" 
   global BSLREFOR_do            "$BSLREFOR/Dofiles" 
   global BSLREFOR_out           "$BSLREFOR/Output" 


*iefolder*1*RoundGlobals*rounds*III_Endline_Reforestation*EDLREFOR**************
*iefolder will not work properly if the line above is edited

   *III_Endline_Reforestation folder globals
   global EDLREFOR               "$dataWorkFolder/III_Endline_Reforestation" 
   global EDLREFOR_encrypt       "$encryptFolder/Round III_Endline_Reforestation Encrypted" 
   global EDLREFOR_dt            "$EDLREFOR/DataSets" 
   global EDLREFOR_do            "$EDLREFOR/Dofiles" 
   global EDLREFOR_out           "$EDLREFOR/Output" 

*iefolder*1*FolderGlobals*endRounds*********************************************
	
}
*


	*************************
	*     BASIC CLEANING    *
	*************************
	
if (1)  {	
use "$EDLREFOR_dt/raw/collector_app_data", clear

	sort region site bloc parcelle condition arrive
	

	
	encode bloc, gen(blocid) label(blocid)
	
	encode parcelle, gen (treatment) label(treatment)
	label define treatment 1"Parcelle Bleue - Lineaire" ///
						   2"Parcelle Rouge - Seuil" ///
						   3"Parcelle Verte - Cloture", replace
	label values treatment treatment					   
	
	encode site, gen(siteid) label(siteid)
	
	egen parcelleid=group(blocid treatment)
	
	
	* Generating weights per parcelleid				
	gen count=1
	egen total_count=sum(count)
	bysort parcelleid: egen parcelle_count=sum(count)
	drop count
	generate weights=parcelle_count/total_count
	label variable weights "weigths of each reforestation parcelle"
		
	* trees species
	replace espece= espece1 if espece==""
	
	replace espece="Unknown" if espece=="" | espece=="0" | espece=="1" | espece=="Autre" | espece=="a" 
	replace espece="Abzelia (Abelia grandiflora)" if espece=="Abzelia" | espece=="2"	
	replace espece="Epineux (Acacia Senegal)" if espece=="Epineux" | espece=="Acacia" | espece=="3"	| espece=="7"	
	replace espece="Anacarde (Anacardium Occidentale)" if espece=="Anacarde" | espece=="4"	
	replace espece="Baobab (Adansonia Digitata)" if espece=="Baobab" | espece=="5"	
	replace espece="Caiderat (Khaya Senegalensis)" if espece=="Caicedra" | espece=="6"	
	*replace espece="Acacia/Epineux (Acacia Senegal)" if espece=="7"	
	replace espece="Eucalyptus (Eucalyptus tereticornis)" if espece=="Eucalyptus" | espece=="8"	
	replace espece="Fromager (Ceiba pentandra)" if espece=="Fromager" | espece=="Kapokier" | espece=="9"	| espece=="10"
	*replace espece="Kapokier" if espece=="10"	
	replace espece="Manguier (Mangifera indica)" if espece=="Manguier" | espece=="11"
	replace espece="Moringa (Moringa oleifera)" if espece=="Moringa" | espece=="12"	
	replace espece="Neem (Azadirachta indica)" if espece=="Neem" | espece=="13"
	replace espece="Nere (Parkia biglobosa)" if espece=="Nere" | espece=="14"	
	replace espece="Noisette (Coryllus avellana)" if espece=="Noisette" | espece=="15"
	replace espece="Teck (Tectona grandis)" if espece=="Teck" | espece=="16"	

	encode espece, gen (espece_code) label(espece_code)
	label variable espece_code "Species of trees"
	
	recode espece_code (1=18) (6=18) (7=18) (8=18) (9=18) (10=18) (12=18) (13=18)
	label define espece_code 18"Autres Especes", modify	
				
				* Spitting out a quick graph on the distribution of species
				graph pie, over(espece_code) sort plabel(_all percent, ///
					format(%9.0f) color(black) size(vsmall)) pie(_all, explode) /// title(Taux moyen de survie, color(navy) size(medium)) ///
					legend(size(small)) title("Types d'especes utilises dans le reboisement")  ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) 						
				gr export 	"$EDLREFOR_out/tree_species.png", width(5000) replace
				

	* Keep only the survival rate sample data
	
	keep if condition!="" | arrive!="" | espece1!="" | enumerateu!=""
	order region site bloc parcelle condition arrive espece espece1 autre_espe enumerateu latitude longitude fixtime x y
	replace region = region[_n-1] if region==""
	replace site = site[_n-1] if site==""
	replace bloc = bloc[_n-1] if bloc==""
	replace parcelle = parcelle[_n-1] if parcelle==""

	* Tree condition
	replace condition="0" if condition=="" | condition=="a"
	destring condition, gen(condition_code)
	label define condition_code  0"Je ne sais pas" 	///
								 1"Disparu"       	///
								 2"Là mais mort" 	///
								 3"Mauvais état" 	///
								 4"Assez bon état" ///
								 5"Très bon état" , replace
	recode condition_code (6=0)
	label values condition_code condition_code
	
	* What happened to the trees
	replace arrive="0" if arrive=="a"
	destring arrive, gen(explication) 
	label define explication  0"Je ne sais pas"  ///
							  1"Mangé par les animaux" ///
							  2"Brulé par le feu"      ///
							  3"Manque d'eau"         ///
							  4"Autre" , replace
	label values explication explication




sort region site bloc parcelle objectid

save "$EDLREFOR_dt/Intermediate/collector_app_data_clean", replace

}
*

