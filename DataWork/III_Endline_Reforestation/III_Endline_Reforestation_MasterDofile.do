   * ******************************************************************** *
   * ******************************************************************** *
   *                                                                      *
   *               your_round_name                                        *
   *               MASTER DO_FILE                                         *
   *                                                                      *
   * ******************************************************************** *
   * ******************************************************************** *

       /*
       ** PURPOSE:      Write intro to survey round here

       ** OUTLINE:      PART 0: Standardize settings and install packages
                        PART 1: Preparing folder path globals
                        PART 2: Run the master do files for each high level task

       ** IDS VAR:      list_ID_var_here         //Uniquely identifies households (update for your project)

       ** NOTES:

       ** WRITEN BY:    Jonas Guthoff

       ** Last date modified: 16 Apr 2018
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
       *ssc install ietoolkit, replace

       *Standardize settings accross users
      * ieboilstart, version(12.1)      //Set the version number to the oldest version used by anyone in the project team
      *`r(version)'                    //This line is needed to actually set the version from the command above

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

   * Users
   * -----------

	clear all
	set more off
	cap log close
	set maxvar 32767
	set matsize 800
	
	version 12.1
	
 	* Verify directory path by running 

	dis "`c(username)'" // The text that shows up is the username of your computer (say XXX), and insert that into the code below
	
	
   /* Root folder globals
   * ---------------------

	* SERGE 	
	if c(username)=="WB495145" {
       global projectfolder "C:\SD Card\Cloud Docs\Dropbox\World Bank projects\PROJECTS\1-BURKINA FORESTRY"
	}

	if c(username)=="sergeadjognon" {
       global projectfolder "/Volumes/My Passport for Mac/CloudDocs/Dropbox/World Bank projects/PROJECTS/1-BURKINA FORESTRY"  
	}
   
	* DAAN
	if c(username)=="soest"  {
	   global projectfolder "D:\Dropbox\"										
	}

	* JONAS 
	if c(username)=="jonasguthoff"  {
	   global projectfolder "/Users/jonasguthoff/Dropbox/Burkina Faso IEs/Burkina Faso Forestry"										
	}
*/

*These lines are used to test that name ois not already used (do not edit manually)

   * Project folder globals
   * ---------------------

   global dataWorkFolder         "$projectfolder/DataWork"

*iefolder*1*FolderGlobals*master************************************************
*iefolder will not work properly if the line above is edited

   global mastData               "$dataWorkFolder/MasterData" 

*iefolder*1*FolderGlobals*encrypted*********************************************
*iefolder will not work properly if the line above is edited

   global encryptFolder          "$dataWorkFolder/EncryptedData" 

*iefolder*1*FolderGlobals*III_Endline_Reforestation*****************************
*iefolder will not work properly if the line above is edited


   *Encrypted round sub-folder globals
   global EDLREFOR               "$dataWorkFolder/III_Endline_Reforestation" 

   *Encrypted round sub-folder globals
   global EDLREFOR_encrypt       "$encryptFolder/Round III_Endline_Reforestation Encrypted" 
   global EDLREFOR_dtRaw         "$EDLREFOR_encrypt/Raw Identified Data" 
   global EDLREFOR_doImp         "$EDLREFOR_encrypt/Dofiles Import" 
   global EDLREFOR_HFC           "$EDLREFOR_encrypt/High Frequency Checks" 

   *DataSets sub-folder globals
   global EDLREFOR_dt            "$EDLREFOR/DataSets" 
   global EDLREFOR_dtInt         "$EDLREFOR_dt/Intermediate" 
   global EDLREFOR_dtFin         "$EDLREFOR_dt/Final" 

   *Dofile sub-folder globals
   global EDLREFOR_do            "$EDLREFOR/Dofiles" 
   global EDLREFOR_doCln         "$EDLREFOR_do/Cleaning" 
   global EDLREFOR_doCon         "$EDLREFOR_do/Construct" 
   global EDLREFOR_doAnl         "$EDLREFOR_do/Analysis" 

   *Output sub-folder globals
   global EDLREFOR_out           "$EDLREFOR/Output" 
   global EDLREFOR_outRaw        "$EDLREFOR_out/Raw" 
   global EDLREFOR_outFin        "$EDLREFOR_out/Final" 

   *Questionnaire sub-folder globals
   global EDLREFOR_prld          "$EDLREFOR_quest/PreloadData" 
   global EDLREFOR_doc           "$EDLREFOR_quest/Questionnaire Documentation" 

*iefolder*1*End_FolderGlobals***************************************************
*iefolder will not work properly if the line above is edited


*iefolder*2*StandardGlobals*****************************************************
*iefolder will not work properly if the line above is edited

   * Set all non-folder path globals that are constant accross
   * the project. Examples are conversion rates used in unit
   * standardization, differnt set of control variables,
   * ado file paths etc.

   do "$dataWorkFolder/global_setup.do" 


*iefolder*2*End_StandardGlobals*************************************************
*iefolder will not work properly if the line above is edited


*iefolder*3*RunDofiles**********************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 3: - RUN DOFILES CALLED BY THIS MASTER DO FILE
   *
   *           -A task master dofile has been created for each high
   *            level task (cleaning, construct, analyze). By 
   *            running all of them all data work associated with the 
   *            III_Endline_Reforestation should be replicated, including output of 
   *            tablets, graphs, etc.
   *           -Feel free to add to this list if you have other high
   *            level tasks relevant to your project.
   *
   * ******************************************************************** *

   **Set the locals corresponding to the taks you want
   * run to 1. To not run a task, set the local to 0.
   local importDo       0
   local cleaningDo     1
   local constructDo    1
   local analysisDo     1

   if (`importDo' == 1) { //Change the local above to run or not to run this file
       do "$EDLREFOR_doImp/EDLREFOR_import_MasterDofile.do" 
   }

   if (`cleaningDo' == 1) { //Change the local above to run or not to run this file
       do "$EDLREFOR_do/Cleaning/PIF_Endline_Cleaning.do" 
   }

   if (`constructDo' == 1) { //Change the local above to run or not to run this file
       do "$EDLREFOR_do/Construct/PIF_Endline_Construct.do" 
   }

   if (`analysisDo' == 1) { //Change the local above to run or not to run this file
       do "$EDLREFOR_do/Analysis/PIF_Endline_Analysis.do" 
   }

*iefolder*3*End_RunDofiles******************************************************
*iefolder will not work properly if the line above is edited

