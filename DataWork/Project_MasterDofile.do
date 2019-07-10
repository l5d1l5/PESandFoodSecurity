   * ******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
   *               your_project_name                                      *
   *               MASTER DO_FILE                                         *
   *                                                                      *
   * ******************************************************************** *
   * ******************************************************************** *

       /*
       ** PURPOSE:      Write intro to project here

       ** OUTLINE:      PART 0: Standardize settings and install packages
                        PART 1: Set globals for dynamic file paths
                        PART 2: Set globals for constants and varlist
                               used across the project. Intall custom
                               commands needed.
                        PART 3: Call the task specific master do-files 
                               that call all do-files needed for that 
                               tas. Do not include Part 0-2 in a task
                               specific master do-file


       ** IDS VAR:      list_ID_var_here         //Uniquely identifies households (update for your project)

       ** NOTES:

       ** WRITEN BY:    names_of_contributors

       ** Last date modified:  9 Apr 2018
       */

*iefolder*0*StandardSettings****************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
   *
   *           -Install packages needed to run all dofiles called
   *            by this master dofile.
   *           -Use ieboilstart to harmonize settings across users
   *
   * ******************************************************************** *

*iefolder*0*End_StandardSettings************************************************
*iefolder will not work properly if the line above is edited

       *Install all packages that this project requires:
       ssc install ietoolkit, replace
	
	   ssc install mvtobit, replace
		
	   ssc install forest, replace	
	   
	   ssc install avg_effect, replace
	   
	   
       *Standardize settings accross users
       ieboilstart, version(12.1)      //Set the version number to the oldest version used by anyone in the project team
       `r(version)'                    //This line is needed to actually set the version from the command above

	   
	   
	   *set varabbrev on
	   
	   
*iefolder*1*FolderGlobals*******************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 1:  PREPARING FOLDER PATH GLOBALS
   *
   *           -Set the global box to point to the project folder
   *            on each collaborators computer.
   *           -Set other locals that point to other folders of interest.
   *
   * ******************************************************************** *
   

	* Verify directory path by running 

	dis "`c(username)'" // The text that shows up is the username of your computer (say XXX), and insert that into the code below 

	*change to working directory 

	if c(username)=="WB495145" {
            *global projectfolder "C:\SD Card\Cloud Docs\Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY"
			global projectfolder "C:\Users\WB495145\Documents\GitHub\PESandFoodSecurity"
            }
	*
	if c(username)=="sergeadjognon" {
            global projectfolder "/Volumes/My Passport for Mac/CloudDocs/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY"
            }
	*	
	
	if c(username)=="ALEXIS" {
            global projectfolder "~/Dropbox/DataWork/I_RemoteSensing"
            }
			*

*These lines are used to test that name ois not already used (do not edit manually)
*round*I_RemoteSensing*STLDATA*II_Baseline_Reforestation*BSLREFOR*III_Endline_Reforestation*EDLREFOR*GDT_Baseline*GDT_Endline*GDT_Monitoring
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


*iefolder*1*RoundGlobals*rounds*GDT_Baseline*GDT_Baseline***********************
*iefolder will not work properly if the line above is edited

   *GDT_Baseline folder globals
   global GDT_Baseline           "$dataWorkFolder/GDT_Baseline" 
   global GDT_Baseline_encrypt   "$encryptFolder/Round GDT_Baseline Encrypted" 
   global GDT_Baseline_dt        "$GDT_Baseline/DataSets" 
   global GDT_Baseline_do        "$GDT_Baseline/Dofiles" 
   global GDT_Baseline_out       "$GDT_Baseline/Output" 


*iefolder*1*RoundGlobals*rounds*GDT_Endline*GDT_Endline*************************
*iefolder will not work properly if the line above is edited

   *GDT_Endline folder globals
   global GDT_Endline            "$dataWorkFolder/GDT_Endline" 
   global GDT_Endline_encrypt    "$encryptFolder/Round GDT_Endline Encrypted" 
   global GDT_Endline_dt         "$GDT_Endline/DataSets" 
   global GDT_Endline_do         "$GDT_Endline/Dofiles" 
   global GDT_Endline_out        "$GDT_Endline/Output" 

   
   
   
   * set up ipafolder to check the "other" responses entered
   *ipacheck new, folder("My project")

   
   

*iefolder*1*RoundGlobals*rounds*GDT_Monitoring*GDT_Monitoring*******************
*iefolder will not work properly if the line above is edited

   *GDT_Monitoring folder globals
   global GDT_Monitoring         "$dataWorkFolder/GDT_Monitoring" 
   global GDT_Monitoring_encrypt "$encryptFolder/Round GDT_Monitoring Encrypted" 
   global GDT_Monitoring_dt      "$GDT_Monitoring/DataSets" 
   global GDT_Monitoring_do      "$GDT_Monitoring/Dofiles" 
   global GDT_Monitoring_out     "$GDT_Monitoring/Output" 

*iefolder*1*FolderGlobals*endRounds*********************************************
*iefolder will not work properly if the line above is edited


*iefolder*1*End_FolderGlobals***************************************************
*iefolder will not work properly if the line above is edited


*iefolder*2*StandardGlobals*****************************************************
*iefolder will not work properly if the line above is edited

   * Set all non-folder path globals that are constant accross
   * the project. Examples are conversion rates used in unit
   * standardization, differnt set of control variables,
   * ado file paths etc.

   *do "$dataWorkFolder/global_setup.do" 


*iefolder*2*End_StandardGlobals*************************************************
*iefolder will not work properly if the line above is edited


*iefolder*3*RunDofiles**********************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 3: - RUN DOFILES CALLED BY THIS MASTER DO FILE
   *
   *           -When survey rounds are added, this section will
   *            link to the master dofile for that round.
   *           -The default is that these dofiles are set to not
   *            run. It is rare that all round specfic master dofiles
   *            are called at the same time, the round specific master
   *            dofiles are almost always called individually. The
   *            exception is when reviewing or replicating a full project.
   *
   * ******************************************************************** *


*iefolder*3*RunDofiles*I_RemoteSensing*STLDATA**********************************
*iefolder will not work properly if the line above is edited

   if (0) { //Change the 0 to 1 to run the I_RemoteSensing master dofile
       do "$STLDATA/I_RemoteSensing_MasterDofile.do" 
   }


*iefolder*3*RunDofiles*II_Baseline_Reforestation*BSLREFOR***********************
*iefolder will not work properly if the line above is edited

   if (1) { //Change the 0 to 1 to run the II_Baseline_Reforestation master dofile
       do "$BSLREFOR/II_Baseline_Reforestation_MasterDofile.do" 
   }


*iefolder*3*RunDofiles*III_Endline_Reforestation*EDLREFOR***********************
*iefolder will not work properly if the line above is edited

   if (1) { //Change the 0 to 1 to run the III_Endline_Reforestation master dofile
       do "$EDLREFOR/III_Endline_Reforestation_MasterDofile.do" 
   }


*iefolder*3*RunDofiles*GDT_Baseline*GDT_Baseline********************************
*iefolder will not work properly if the line above is edited

   if (0) { //Change the 0 to 1 to run the GDT_Baseline master dofile
       do "$GDT_Baseline/GDT_Baseline_MasterDofile.do" 
   }


*iefolder*3*RunDofiles*GDT_Endline*GDT_Endline**********************************
*iefolder will not work properly if the line above is edited

   if (0) { //Change the 0 to 1 to run the GDT_Endline master dofile
       do "$GDT_Endline/GDT_Endline_MasterDofile.do" 
   }


*iefolder*3*RunDofiles*GDT_Monitoring*GDT_Monitoring****************************
*iefolder will not work properly if the line above is edited

   if (0) { //Change the 0 to 1 to run the GDT_Monitoring master dofile
       do "$GDT_Monitoring/GDT_Monitoring_MasterDofile.do" 
   }

*iefolder*3*End_RunDofiles******************************************************
*iefolder will not work properly if the line above is edited

