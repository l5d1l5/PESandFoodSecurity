/* *************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
*         	PIF Burkina Faso		  					   			   		   *
*		  	Construct PIF Tree Survival Rates on Group Level		   		   *
*																	   		   *
* **************************************************************************** *
* **************************************************************************** *


** WRITTEN BY: Jonas Guthoff 	(jguthoff@worldbank.org)
** CREATED:    22/02/2019

	** OUTLINE:		In this do file, we construct tree survival on group level
					
	
					0. Load data					
					
					1. Construct tree survival on group level
					
		
		
	** Requires:  	III_Endline_Reforestation_MasterDofile.do to set the globals
	
	
	** Unique identifier: 
	
	
*/

* **************************************************************************** *
* load data
* **************************************************************************** *

	
	use "$EDLREFOR_dt/Intermediate/collector_app_data_construct.dta", clear



	tab 	treatment


	* Vivant 1 and Vivant 2 are the 2 outcome variables. generate on group level
	* rates for those variables -> coded based on condition_code
	
	tab 	condition_code

/*	
condition_code |      Freq.     Percent        Cum.
---------------+-----------------------------------
Je ne sais pas |        213        1.29        1.29
       Disparu |      8,957       54.04       55.33
  Là mais mort |      1,339        8.08       63.41
  Mauvais état |        956        5.77       69.17
Assez bon état |      3,614       21.81       90.98
 Très bon état |      1,495        9.02      100.00
---------------+-----------------------------------
         Total |     16,574      100.00
*/
	
	
	tab 	vivant1 condition_code
	* only Assez bon etat and Très bon etat are coded to vivant
	
 
	tab 	vivant2 condition_code
	* all living status are coded to vivant: Mauvais etat, Assez bon etat, très bon etat
	* so as long as the trees are alive
	
	
	
	
	* Compute on group level the tree survival/state rates
	
	
	br region site bloc parcelle parcelleid treatment
	
	
	codebook parcelleid
	* 93 parcelles
	* groups are organized at the level of the parcelle and divided into treatment groups
	* generate here on that level the survival rates
	
	
	
	
	* 1.) For vivant 1 -> collapse on group level to obtain mean rates
	
	br region site bloc parcelle parcelleid vivant1
	
	
	preserve
	
		collapse vivant1, by(region site bloc parcelle)
	
		save "$EDLREFOR_dtInt/Constructed/SurvivalRates_GroupLevel_vivant1.dta", replace
	
	restore
	
	
	/* Check distribution of group survival rates
	use "$EDLREFOR_dtInt/SurvivalRates_GroupLevel_vivant1.dta", clear
	kdensity vivant1
	*/
	
	
	
	* 2.) For Vivant 2 -> collapse on grooup level to obtain mean rates for vivant 2
	
	preserve
		
		collapse vivant2, by(region site bloc parcelle)
	
		save "$EDLREFOR_dtInt/Constructed/SurvivalRates_GroupLevel_vivant2.dta", replace
	
	restore
	
	
	/* Check distribution by groups
	use "$EDLREFOR_dtInt/SurvivalRates_GroupLevel_vivant2.dta", clear
	kdensity vivant2
	*/
	
	
	
	
	
	
	
	
	
	
	
	

