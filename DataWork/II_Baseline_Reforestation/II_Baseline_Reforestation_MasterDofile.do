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
       *ssc install ietoolkit, replace

       *Standardize settings accross users
       *ieboilstart, version(12.1)      //Set the version number to the oldest version used by anyone in the project team
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
	   global projectfolder "C:\Users\soest\Dropbox"										
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

*iefolder*1*FolderGlobals*II_Baseline_Reforestation*****************************
*iefolder will not work properly if the line above is edited


   *Encrypted round sub-folder globals
   global BSLREFOR               "$dataWorkFolder/II_Baseline_Reforestation" 

   *Encrypted round sub-folder globals
   global BSLREFOR_encrypt       "$encryptFolder/Round II_Baseline_Reforestation Encrypted" 
   global BSLREFOR_dtRaw         "$BSLREFOR_encrypt/Raw Identified Data" 
   global BSLREFOR_doImp         "$BSLREFOR_encrypt/Dofiles Import" 
   global BSLREFOR_HFC           "$BSLREFOR_encrypt/High Frequency Checks" 

   *DataSets sub-folder globals
   global BSLREFOR_dt            "$BSLREFOR/DataSets" 
   global BSLREFOR_dtInt         "$BSLREFOR_dt/Intermediate" 
   global BSLREFOR_dtFin         "$BSLREFOR_dt/Final" 

   *Dofile sub-folder globals
   global BSLREFOR_do            "$BSLREFOR/Dofiles" 
   global BSLREFOR_doCln         "$BSLREFOR_do/Cleaning" 
   global BSLREFOR_doCon         "$BSLREFOR_do/Construct" 
   global BSLREFOR_doAnl         "$BSLREFOR_do/Analysis" 

   *Output sub-folder globals
   global BSLREFOR_out           "$BSLREFOR/Output" 
   global BSLREFOR_outRaw        "$BSLREFOR_out/Raw" 
   global BSLREFOR_outFin        "$BSLREFOR_out/Final" 

   *Questionnaire sub-folder globals
   global BSLREFOR_prld          "$BSLREFOR_quest/PreloadData" 
   global BSLREFOR_doc           "$BSLREFOR_quest/Questionnaire Documentation" 

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
   *            II_Baseline_Reforestation should be replicated, including output of 
   *            tablets, graphs, etc.
   *           -Feel free to add to this list if you have other high
   *            level tasks relevant to your project.
   *
   * ******************************************************************** *

   **Set the locals corresponding to the taks you want
   * run to 1. To not run a task, set the local to 0.
   local importDo       0
   local cleaningDo     0
   local constructDo    0
   local analysisDo     0

   if (`importDo' == 1) { //Change the local above to run or not to run this file
       do "$BSLREFOR_doImp/BSLREFOR_import_MasterDofile.do" 
   }

   if (`cleaningDo' == 1) { //Change the local above to run or not to run this file
       do "$BSLREFOR_do/Cleaning/Baseline_Cleaning.do" 
   }

   if (`constructDo' == 1) { //Change the local above to run or not to run this file
       do "$BSLREFOR_do/Construct/Baseline_Construct.do" 
   }

   if (`analysisDo' == 1) { //Change the local above to run or not to run this file
       do "$BSLREFOR_do/Analysis/Baseline_Analysis.do" 
   }

*iefolder*3*End_RunDofiles******************************************************
*iefolder will not work properly if the line above is edited

