/* *************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
*         	PIF Burkina Faso		  					   			   		   *
*		  	Construct PIF Group Level Diversity & Trust Indicators		   	   *
*																	   		   *
* **************************************************************************** *
* **************************************************************************** *


** WRITTEN BY: Jonas Guthoff 	(jguthoff@worldbank.org)
** CREATED:    22/02/2019

	** OUTLINE:		In this do file, we construct tree survival on group level
					
					
					The data used for construction here is taken from Section B 
					and Section E from the Endline Survey
					
						
					1. Construct Group Diversity Index	(Endline Section B)
					 
					2. Quantify the number of encounters/group meetings to take of the plots 	(Endline Section B)
					
					3. Effort evaluation 	(Endline Section B)
						a. General and conditional on different ethnic background
					
					
					4. Construct Levels of Trust	(Endline Section E)
						a. Towards the group
						b. Towards the individual
						c. aggregate on group level
					
										
					
		
		
	** Requires:  	III_Endline_Reforestation_MasterDofile.do to set the globals
	
	
	** Unique identifier: hhid
	
	
* **************************************************************************** *
* **************************************************************************** */



	* Load constructed data from Section B from the Endline Survey
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_construct.dta", clear	
	
	
	* keep only treatment & found respondents
	keep if statut == 1 & found_participant == 1
	
	
	* We only asked to evaluate the effort of the other group members in the treatment
	* group. Similarly, the trust question. We can therefore focus on respondents in
	* the treatment groups.
	
	
* ------------------------------------------------------------------------------
* 1.) Construct Group Diversity Index
* ------------------------------------------------------------------------------	



	* Check the completion of ethnicites for the 574 interviewd respondents 
	tab 	b7
		
	
	
	* 1.1) We will first save seperately the based on the interview with each respondent (found + treatment)
	*	   his name and ethnicity
	
	* 1.2) Then we will reshape the repeat group where effort was evaluated of each of the respondents 
	*	   group members and merge the ethnicity information onto that.
	
	* -> we will then be able to say, whether effort is evaluated differently based on ethnical background
	
	
	
	
	
	

	* 1.1) We will first save seperately the based on the interview with each respondent (found + treatment)
	*	   his name and ethnicity
	
	
	* concatenate first and last name -> to obtain the same name as it is save in the repeat calc field 
	* in the survey
	
	egen repondant_nom = concat(b2 b1), punct(" ")
	
		 
	sort group_id
	br   group_id repondant_nom b7  hhid groupsize 			if  statut == 1 & found_participant == 1


	 
	* Keep only the found respondents from the treatment groups
	preserve 	
		
		sort group_id
		br   group_id repondant_nom b7  hhid groupsize 			
		
		* re-generate group size -> based on what we have data on
		bys group_id: gen 	n 				 = _n
		bys group_id: egen	groupsize_real   = max(n)
		
		keep   repondant_nom b7  hhid groupsize_real groupsize a1_region a2_site a4_bloc a5_parcelle
		gen    membre_id = hhid
		rename repondant_nom 	 membre
		rename b7 			 	 ethnicity
		
		save "$EDLREFOR_dtInt/nom_ethnicity.dta", replace
	restore

 	
	
	
	
	
	* 1.2) Then we will reshape the repeat group where effort was evaluated of each of the respondents 
	*	   group members and merge the ethnicity information onto that.
	
	* Now reshape the data to the group member level to merge on the ethniciy of each group member
	
	sort group_id
	br b2 b1 b7  group_id groupsize membre1 membre2 membre3 membre4			
	
 		
   		
	reshape long membre , i(hhid repondant_nom) j(number)
		
		merge m:m membre using "$EDLREFOR_dtInt/nom_ethnicity.dta", gen(_merge_Membre) keep(3)
		
		/* codebook  membre if _merge_Membre == 1
		* not merged from master are those that were not interviewd (not_found==0), therefore where we do not 
		* have the information on the ethnicity
		* for _merge_Membre == 2 : wrong allocation in group.
				
		sort 	b2 b1 membre
		br 		b2 b1 membre _merge_Membre	if inlist(_merge_Membre,1,2)
		
		*/
		
		
		sort group_id membre
		br 	 group_id groupsize b2 b1 b7   membre _merge_Membre ethnicity		
		
		
		label values ethnicity b7_update
		
		sort group_id membre
		br 	 group_id groupsize b2 b1 b7   membre _merge_Membre ethnicity	if _merge_Membre == 3
		
		drop  _merge_Membre
		
		*reshape back to wide
		sort 	hhid repondant_nom 
		br 		hhid repondant_nom  
		
	* reshape the data back to the respondent level
	reshape wide membre ethnicity membre_id groupsize_real, i(hhid repondant_nom) j(number)
	
	
	
	sort group_id
	br b2 b1 b7  group_id groupsize membre1 ethnicity1  membre2 ethnicity2 membre3 ethnicity3 membre4 ethnicity4		

 	
	* include the respondent himself to get the full picture
	gen 		 ethnicity0 = b7
	label values ethnicity0   b7_update	
		
		
		
	sort group_id
	br 	 group_id groupsize repondant_nom ethnicity0  membre1 ethnicity1  membre2 ethnicity2 membre3 ethnicity3 membre4 ethnicity4		
		
	
	* Set a local for all ethnicities
	* local all_ethnicities = "Mossi Gourmatche Samo Gourounsi Bobo Bwaba Lobi Dagara Birifor Peul Touareg Senoufo Dafi Koh Nounouma Yadega"
 

	* Generate indicator for ALL the ETHNICITIES and then count them for each group
	foreach ethnicity of numlist 1/17 {
		gen 	ethnic_`ethnicity'_count = 0
		}
	
	
	
	* Now count for each group the number of members from each ethnicity -> indicators
	* that capture the number of group members per ethnicity
	foreach membre of numlist 0/4 {
		foreach ethnicity of numlist 1/17 {
		replace ethnic_`ethnicity'_count = ethnic_`ethnicity'_count + 1		if ethnicity`membre' == `ethnicity'
			}
		}
	
 
	
	* sum up total of group members interviewed + 1, the repondent himself
	egen 		group_total = rowtotal(ethnic_1_count - ethnic_17_count) 
	
	lab var	    group_total "Number of group respondents interviewed"
	
	
	* generate a count for each group about the different numbers of tribes within the group
	
	gen 		num_ethnicities = 0
	
	lab var 	num_ethnicities	"Number of different ethnicites in the group"
	
	* Count across the indicators that capture the number for the respective ethniciy
	foreach ethnicity of numlist 1/17 {
		replace num_ethnicities = num_ethnicities + 1 			if ethnic_`ethnicity'_count > 0 
		}
		
		
	* Check the number of groups with more than 1 ethnicity
	
	codebook 	group_id
	* 66 groups
	
	
	* The distribution
	preserve 
	duplicates drop group_id, force
	tab num_ethnicities 
	restore
	
	
	**** Generate a binary Indicator which captures whether a group is composed out of at least 2 different ethnic groups
	gen 	treat_diversity = 0	
	replace treat_diversity = 1				if num_ethnicities > 1
	
	tab 	treat_diversity 				if found_participant == 1 & statut == 1
	
	lab var treat_diversity	"The group has at least 2 different ethnic groups"
	
	
	**** Generate another binary indicator which captures if the group is composed of 
	gen 	treat_diversity3 = 0	
	replace treat_diversity3 = 1			if num_ethnicities > 2
	
	tab 	treat_diversity3 				if found_participant == 1 & statut == 1
	
 	lab var treat_diversity3	"The group has at least 3 different ethnic groups"
	
	
	
	sort  	group_id
	order 	group_id groupsize repondant_nom ethnicity0  membre1 ethnicity1 membre2 ethnicity2 membre3 ethnicity3 membre4 ethnicity4 num_ethnicities group_total
	br    	group_id groupsize repondant_nom ethnicity0  membre1 ethnicity1 membre2 ethnicity2 membre3 ethnicity3 membre4 ethnicity4 num_ethnicities group_total	if found_participant == 1 & statut == 1	

	* generate a share "diversity score" with respect to the ethnic composition of each group
	* -> the higher the score, the more diverse the the composition of the group
	* 	 use here the number of 
	
 	
	gen 	  div_score = round(num_ethnicities / group_total,.01 )
	
	tab  	  div_score if found_participant == 1 & statut == 1
	
	label var div_score "Group Diversity Score"
	
	
	preserve
	duplicates drop group_id, force
	tab div_score if found_participant == 1 & statut == 1
	restore
	

	
	* Collapse the data on Group level and save
	sort  	group_id
	br    	group_id ethnic_1_count - ethnic_17_count num_ethnicities group_total treat_diversity3 treat_diversity div_score	if found_participant == 1 & statut == 1	
	
	
	
	sort  	group_id
	br    	group_id ethnicity0 ethnicity1 ethnicity2 ethnicity3 ethnicity4 num_ethnicities found_participant	if num_ethnicities == 0 & statut == 1	
	
	


	* Save the information on group level	
	preserve 
		
			
		*	br  group_id
		* drop duplicates in terms of groups -> keep only one observation of all the respondents
		duplicates drop group_id, force
	
		* keep only group level variables
		keep group_id a1_region a2_site a4_bloc a5_parcelle ethnic_1_count - ethnic_17_count num_ethnicities group_total treat_diversity3 treat_diversity div_score
				
		save "$EDLREFOR_dt/Intermediate/Constructed/Ethnic_Comp_GroupLevel.dta", replace
		
	restore
	
	
	
	
	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_div_score_construct.dta", replace	

	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_div_score_construct.dta", clear
	
	
* ------------------------------------------------------------------------------
* 2.) Quantify the number of encounters/group meetings to take of the plots 	(Endline Section B)
* ------------------------------------------------------------------------------
	
	* We asked 3 different questions about the number of times the group met
/*	
B.27 Combien de fois vous êtes-vous réunis avec un ou plusieurs membres de votre équipe d’entretien pour discuter de la protection des arbres sur votre parcelle d’entretien ?
B.28 Combien de fois vous êtes-vous rendus sur la parcelle en groupe pour en assurer l’entretien durant la période d’entretien ?	
*/	
	
	
	summ 	b27 b28 									if found_participant == 1 & statut == 1	
	
	
	* Check for variation within the group
	
	sort group_id
	
	br 	 group_id  b27 b28								if found_participant == 1 & statut == 1	
	
	
	* Generate on group level the mean and deviation vars
	
	bys group_id : egen mean_b27 = mean(b27)
	
	bys group_id : egen mean_b28 = mean(b28)
	
	* Generate the median to compare
	
	bys group_id : egen median_b27 = median(b27)
	
	bys group_id : egen median_b28 = median(b28)

	* -> median is less prone to outliers, use the median to have estimates on group
		
	lab var 		    median_b27	"No de réunion avec membres de groupe pour discuter"
		
	lab var				median_b28	"No de réunion sur la parcelle en groupe"

	* Collapse and Save the data
	preserve
		
		* keep only treatment 
		keep if statut == 1 & found_participant == 1
		
		* drop duplicates in terms of groups -> keep only one observation of all the respondents
		duplicates drop group_id, force
				
		* keep only the group level relevant vars
		keep group_id  median_b27 median_b28
	
		save "$EDLREFOR_dt/Intermediate/Constructed/GroupInteraction_GroupLevel.dta", replace
	
	restore
	
	
	
	

	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_interaction_construct.dta", replace	

	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_interaction_construct.dta", clear
		
	
* ------------------------------------------------------------------------------
* 3.) Effort evaluation 	(Endline Section B)
* ------------------------------------------------------------------------------
	
	
	* We first asked individuals to recall from memory the other members of their group by name.
	* Then, we asked them about the other not named individuals
	* In each case, we asked to evaluate the respective group members effort
	
	* To easier work with the data, we first process the information from group members that were 
	* recalled from memory.
	* Then secondly, we do the same for members that were not recalled, but once reminded, recognized
	
	

	* 1.) Remembered  from memory
	sort hhid repondant_nom
	br 	 hhid repondant_nom ethnicity0 b25 mem_na_conn_1 b26_1_1  mem_na_conn_2 b26_1_2 mem_na_conn_3 b26_1_3 mem_na_conn_4 b26_1_4 
	
	
	* keep, reshape and safe the group data from memory
	preserve
	
		* keep only participants that were found, in the treatment group and that remembered other group membres
		keep if statut == 1 & found_participant == 1 & b25 == 1
		
		* reshape the member and the effort attrivuted
		reshape long mem_na_conn_ b26_1_, i(hhid) j(Membre_number)
		
		* drop the empty member rows
		drop if mem_na_conn_ == "" & b26_1_ == .
		
		* generate an indicator, that the respondent remembered from memory
		gen remember = 1
		
		* keep only relevant variables
		keep  hhid ethnicity0 repondant_nom b25 mem_na_conn_ b26_1_ remember group_id
		* save that data set 
		save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_GroupEffort1.dta", replace
	
	restore 
	
	
	
	
	
	* 2.) Asked specifically about
	sort hhid repondant_nom
	br 	 hhid repondant_nom  mem_na_dem_1 b26_3_1  mem_na_dem_2 b26_3_2 mem_na_dem_3 b26_3_3    if statut == 1 & found_participant == 1 & mem_na_dem_1 !=""
	
	* the same for the members that were recognized asking
	preserve
	
		* keep only participants that were found, in the treatment group and that remembered other group membres
		keep if statut == 1 & found_participant == 1 & mem_na_dem_1 !=""
		
		* reshape the member and the effort attrivuted
		reshape long mem_na_dem_ b26_3_, i(hhid) j(Membre_number)
		
		* drop the empty member rows
		drop if mem_na_dem_ == "" & b26_3_ == .
		
		* generate an indicator, that the respondent remembered from memory
		gen remember = 0
		
		* keep only relevant variables
		keep hhid ethnicity0 repondant_nom  mem_na_dem_ b26_3_ remember group_id
		* save that data set 
		save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_GroupEffort2.dta", replace
	
	restore
	
	
	
	
	
	* 3.) Reload all data and append to have for each respondent the evaluation of all his/her group members on one level
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_GroupEffort1.dta", clear
	
	
	append using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_GroupEffort2.dta"
	
	sort 	hhid
	br 		hhid repondant_nom b25 mem_na_conn_ b26_1_ remember mem_na_dem_ b26_3_
	
	
	* generate 1 variable for all group members and 1 for all efforts
	gen 		membre = ""
	replace		membre = mem_na_conn_		if mem_na_conn_ !=""
	replace 	membre = mem_na_dem_		if mem_na_dem_ !="" & membre ==""
	
	* generate 1 variable that captures the effort
	gen 		effort_evaluation = .
	replace 	effort_evaluation = b26_1_		if b26_1_ !=.
	replace 	effort_evaluation = b26_3_		if b26_3_ !=.
	
	label values effort_evaluation b26_1_4
	
	
	* Merge in the ethnicities from Section B
	merge m:m membre using "$EDLREFOR_dtInt/nom_ethnicity.dta", gen(Merge_Ethnicity) keep(3)
	
	
	* rename the ethnic variables clearly for the respondent and the group members
	rename ethnicity  membre_ethnicity	
	rename ethnicity0 respondent_ethnicity
	
	
	* Now we have:
	* the respondent, his ethnicity and the respective group members, their ethnicity and the respondents evaluation 
	* of their effort
	
	sort repondant_nom
	br 	 repondant_nom respondent_ethnicity membre membre_ethnicity effort_evaluation

	
/*	
1 On a fourni le même effort de travail
2 J’ai fourni un peu plus d’effort que ${mem_na_conn}
3 J’ai fourni beaucoup plus d’effort que ${mem_na_conn}
4 ${mem_na_conn} a fourni beaucoup plus d’effort que moi
5 Nous avions fourni assez d’effort
*/	

	stop 
	
	* Recode  effort evaluation into 3 categories 0: equal effort, 1: "i did more", -1 the other person did more
	gen 	effort = 0						if 	inlist(effort_evaluation,1,5)
	replace effort = 1						if 	inlist(effort_evaluation,2,3)
	replace effort = -1						if 	inlist(effort_evaluation,4)
	
	
	tab 	effort
	* 90 percent of the data are ranked as the same effort
	lab define effort_lab 	0 "Equal effort" -1 "I did more" 1 "other did more"
	lab values effort effort_lab
	
	
	* Recode effort binary -> generate to 1 in case not positively evaluated
	gen 	effort_bin = 0					if effort_evaluation == 1
	replace effort_bin = 1					if effort_evaluation != 1	& effort_evaluation !=.
	
	tab 	effort_bin
	
	
	
	* Generate a binary indicator that cpatures whether the 2 group members are form different ethnic groups
	gen 		diff_ethnicity = 0			if membre_ethnicity !=.
	replace 	diff_ethnicity = 1			if respondent_ethnicity != membre_ethnicity & membre_ethnicity !=.
	
	tab 		diff_ethnicity
	
	lab var 	diff_ethnicity	"Respondent and group member are form different ethnicities"
	

	sort 	hhid
	br 		hhid respondent_ethnicity repondant_nom effort_evaluation  membre membre_ethnicity  diff_ethnicity
	
	
	

	* how are effort and different ethnical background correlated?
	
	correlat effort 	diff_ethnicity
	
	
	correlat effort_bin diff_ethnicity
	
	
	
	* The data here is on Respondent - Group Member level, so there are multiple observations per respondent
	

	
	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_Group_effort_construct.dta", replace	
	
	
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionB_Group_effort_construct.dta", clear	
		
	


* ------------------------------------------------------------------------------
* 4.) Construct Levels of Trust	(Endline Section E)
* ------------------------------------------------------------------------------

	
	use "$EDLREFOR_dt/Intermediate/Clean/PIF_Endline_SectionE_clean.dta", clear	
	
	sort hhid
	br 	 hhid b25 e3_1 e3_2 e3_3 e3_4 e3_autre_1 e3_autre_2 e3_autre_3						if found_participant == 1 & statut == 1	&  b25  == 1
	
	* 0.) Re-compute the number of members we asked the respondent about and "other"
	
	gen num_recalled 	 = 0					if found_participant == 1 & statut == 1	&  b25  == 1
	gen num_recognized	 = 0					if found_participant == 1 & statut == 1	&  b25  == 1
	
	
	foreach member of numlist 1(1)4 {
		
		replace  num_recalled   = num_recalled   + 1			if e3_`member' !=.
		* since there were only up to 3 that we additionally asked about, set the condition
		if `member' < 4 {
		replace  num_recognized = num_recognized + 1			if e3_autre_`member' !=.
		}
	}
	
	sort hhid
	br 	 hhid b25 e3_1 e3_2 e3_3 e3_4 e3_autre_1 e3_autre_2 e3_autre_3 num_recalled no_membre_connu num_recognized		 no_membre_dem				if found_participant == 1 & statut == 1	&  b25  == 1
	 
	gen diff_con = no_membre_connu - num_recalled
	
	gen diff_dem = no_membre_dem - num_recognized
	
	sort hhid
	*br 	 hhid b25 e3_1 e3_2 e3_3 e3_4 e3_autre_1 e3_autre_2 e3_autre_3 num_recognized		 no_membre_dem				if found_participant == 1 & statut == 1	&  b25  == 1 & diff_dem ==1
	
	
	sort hhid
	*br 	 hhid b25 e3_1 e3_2 e3_3 e3_4 e3_autre_1 e3_autre_2 e3_autre_3 num_recognized		 no_membre_dem				if found_participant == 1 & statut == 1	&  b25  == 1 & e3_autre_1 == . & e3_4 ==.
	
	* in case the respondent didnt recall ALL MEMBERS at the first question, we asked the follow-up question
	* for that one the no_membre_dem will then be 1, even in case where he didnt remember others
	
	
	
	* cleant survey variables with the newly created ones
	replace no_membre_connu		= num_recalled					if no_membre_connu !=  num_recalled & no_membre_connu != . & num_recalled !=.
	
	replace no_membre_dem		= num_recognized				if no_membre_dem !=  num_recognized & no_membre_dem != . & num_recognized !=.
	
	
	
	* In case the respondent remembered some of his group members, we asked him next to the 
	* evaluation of work effort also about his levels of trust towards the respective 
	* group members that he was able to remember
	
	* Question B.25 captures, whether the respondent was able to remember 
	* B.25 Vous vous rappelez des noms des autres membres de votre équipe d’entretien ? 
	
	
	* Generate Avg. level of trust towards the other members
	* We do this in 2 steps, 1) for the ones he recalled by himself, 2) for those that we asked about
	* then we can test for differences in between
	
	sort hhid
	br 	 hhid b25 e3_1 e3_2 e3_3 e3_4 e3_autre_1 e3_autre_2 e3_autre_3						if found_participant == 1 & statut == 1	&  b25  == 1

/*	
1 Aucune confiance
2 Peu de confiance
3 Confiance moyenne
4 Assez de confiance
5 Confiance totale
*/	

	* COMPUTE AVERAGES
	
	* Generate the sum of trust values for those that remembered any members
	gen sum_trust_known = 0				if b25 == 1
	
	* in members we asked about
	gen sum_trust_other = 0				if inlist(no_membre_dem,1,2,3)
	
	
		* a.) for those that the respondent remembered 
		foreach member of numlist 1(1)4 {
			replace sum_trust_known = sum_trust_known + e3_`member'				if e3_`member' !=.
			}
			
		* generate averages 
		gen 		sum_trust_known_avg = round(sum_trust_known / no_membre_connu,.01)
			
		label var 	sum_trust_known_avg	"Avg. level of trust towards his group (1-5)"
		
		summ		sum_trust_known_avg, detail
		
		
		* Number of individuals knwon
		foreach member of numlist 1(1)3 {
			replace  sum_trust_other = sum_trust_other + e3_autre_`member'		if e3_autre_`member' !=.
			}
						
		
		* generate the average
		gen 		sum_trust_other_avg = round(sum_trust_other / no_membre_dem,.01)	if sum_trust_other !=0
		
		lab var 	sum_trust_other_avg	"Avg. level of trust towards other group members (1-5)"
		
		summ		sum_trust_other_avg, detail
		
	
	
	
	sort hhid
	br 	 hhid b25 e3_1 e3_2 e3_3 e3_4 e3_autre_1 e3_autre_2 e3_autre_3	sum_trust_known sum_trust_other  				if found_participant == 1 & statut == 1	&  b25  == 1
			
	
	* Compute levels of TRUST for the whole group - add first both 
	egen 	sum_trust_group = rowtotal(sum_trust_known sum_trust_other)			if found_participant == 1 & statut == 1	&  b25  == 1	
		
	
	* Compute the total number of members asked about
	egen 	member_total = rowtotal(no_membre_connu no_membre_dem)
	
	
	* Compute the  average level of trust on group level
	gen 	sum_trust_group_avg = round(sum_trust_group / member_total,.01)
		
	tab 	sum_trust_group_avg	
	
	
	
	* Aggregate on group level the individual evaluation for each group member
	
	sort	group_id
	br 		group_id sum_trust_group_avg					if found_participant == 1 & statut == 1	&  b25  == 1	 
	

	* Collapse and save AVERAGE LEVELS OF TRUST on group level 
	preserve
		
		* keep 
		keep if found_participant == 1 & statut == 1 &  b25  == 1
		
		* collapse on group level
		collapse (mean) sum_trust_group_avg, by(a1_region a2_site a4_bloc a5_parcelle group_id)
	
		* save the data
		save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_Group_AvgTrust.dta", replace
	
	restore
	
	
	
	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_GroupTrust_construct.dta", replace	

	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_GroupTrust_construct.dta", clear	


	/*
	use  "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_Group_AvgTrust.dta", clear 
	
	br group_id sum_trust_group_avg
	
	kdensity sum_trust_group_avg
	
	tab		 sum_trust_group_avg
	*/
	
	
* ---------------------------------------------------------------------------- *
* Code Proportion within the group that can be trusted
* ---------------------------------------------------------------------------- *
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_GroupTrust_construct.dta", clear	
	
	
	* Recode the following scale into 1) trusted (5,4) and 2) not trusted (1,2,3) and then 
	* compute on group level the proportion of the group that can be trusteds
	
/*	
1	Aucune confiance
2	Peu de confiance
3	Confiance moyenne
4	Assez de confiance
5	Confiance totale	
*/
	
	
	sort hhid
	br 	 hhid b25 e3_1 e3_2 e3_3 e3_4 e3_autre_1 e3_autre_2 e3_autre_3				if found_participant == 1 & statut == 1	&  b25  == 1
	
	
	* Generate foreach category a binary var -> first generate one variable that is equal to  0 
	foreach member of numlist 1(1)4 {
		gen 	e3_`member'_bin 		= 0 		if e3_`member' !=.
		}
	
	foreach member of numlist 1(1)3 {
		gen 	e3_autre_`member'_bin	= 0			if e3_autre_`member' !=.
		}
		
	* replace with binary (0/1) if trusted or not
	foreach member of numlist 1(1)4 {
		replace e3_`member'_bin 		= 1 		if inlist(e3_`member',5,4)
		}
	
	foreach member of numlist 1(1)3 {
		replace e3_autre_`member'_bin	= 1			if inlist(e3_autre_`member',5,4)
		}
		

	
	* Compute the number of truster people
	egen 		num_trusted = rowtotal(e3_1_bin e3_2_bin e3_3_bin e3_4_bin e3_autre_1_bin e3_autre_2_bin e3_autre_3_bin)			if found_participant == 1 & statut == 1	&  b25  == 1
	
	
	* divide by the number of people known to obtain the proportion (in percent)
	gen 		prop_trusted = round(num_trusted / member_total,.01) * 100
	
	tab 		prop_trusted
	
	lab var		prop_trusted 	"Prop. of trusted group members (in pct)"
	
	
	* br member_total num_trusted  prop_trusted
 	
	
	* Generate an indicator that captures whether an individual trusts 50 percent or more	
	gen 		trust_50plus = 0					if found_participant == 1 & statut == 1	&  b25  == 1	
	replace 	trust_50plus = 1					if found_participant == 1 & statut == 1	&  b25  == 1  & prop_trusted > 50 & prop_trusted !=.
	
	tab 		trust_50plus
	
	lab var 	trust_50plus "Trusts more than 50 pct of the group (Yes=1, No=0)"
	
	* br member_total num_trusted prop_trusted trust_50plus if found_participant == 1 & statut == 1	&  b25  == 1
	
	
	* Collapse and save AVERAGE PROPORTION OF TRUST on group level 
	preserve
		
		* keep 
		keep if found_participant == 1 & statut == 1 &  b25  == 1
		
		* collapse on group level
		collapse (mean) prop_trusted, by(group_id)
	
		* save the data
		save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_Group_AvgPropTrust.dta", replace
	
	restore
		
	
	/*
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_Group_AvgPropTrust.dta", clear
	br group_id prop_trusted
	tab 	prop_trusted
	*/
	
	
	
	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_Trust_individual_level.dta", replace
	
	
	
	use	 "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_Trust_individual_level.dta", clear
	
	* ------------------------------------------------------------------------ *
	
	* TRUST - on individual  conditional on different ethnic background
	
	
	* Merge Info from Section B on ethnicity 
	merge 1:1 hhid using "$EDLREFOR_dtInt/nom_ethnicity.dta", gen(Merge_SecB) keep(3) 
	
			
	
	br hhid ethnicity mem_na_conf_c_1 e3_1							if found_participant == 1  & statut == 1 &  b25 == 1
	
	
	* 1.) Again, as in Section B reshape first the set of the members where the respondent
	* was able to recall members from memory
	preserve
		
		reshape long mem_na_conf_c_ e3_, i(hhid) j(Membre_nun)
		
		br hhid ethnicity mem_na_conf_c_ e3_
		
		* drop empty rows
		drop if mem_na_conf_c_ == "" & e3_ ==.
		
		* keep only relevant variables
		keep hhid ethnicity mem_na_conf_c_ e3_ group_id  a1_region a2_site a4_bloc a5_parcelle 
		
		* save
		save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_confiance1.dta", replace
	
	restore
	
		
		
	* 2.) Reshape those where we asked about
	br hhid mem_na_conf_d_1 e3_autre_1
	
	preserve
		
		reshape long mem_na_conf_d_ e3_autre_, i(hhid) j(Membre_nun)
			
		* drop empty rows
		drop if mem_na_conf_d_ == "" & e3_autre_ ==.
		
		* keep only relevant variables
		keep  hhid ethnicity mem_na_conf_d_ e3_autre_ group_id  a1_region a2_site a4_bloc a5_parcelle 
		
		* save
		save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_confiance2.dta", replace
	
	restore
	
	
	
	
	
	
	* Append all data together
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_confiance1.dta", clear
	
	append using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_confiance2.dta"
	
	
	
	* generate 1 member name variable
	gen 	 membre 	= mem_na_conf_d_			if mem_na_conf_d_ != ""
	replace	 membre 	= mem_na_conf_c_			if mem_na_conf_c_ != ""	& membre == ""
	
	codebook membre
	
		* drop the 1 observation with a missing name
		drop if membre == ""
	
	* generate 1 confidence variable
	gen 	 confiance 	= e3_						if e3_ !=.
	replace  confiance 	= e3_autre_					if e3_autre_ !=.	& confiance ==.
	
	codebook confiance
	
	
	label values confiance e3_4
	
	tab 	 confiance
	
	rename ethnicity respondent_ethnicity
	
	
	* Merge in the ethnicities of the group members that we asked about
	merge m:m membre using "$EDLREFOR_dtInt/nom_ethnicity.dta", gen(Merge_Ethnicity) keep(3)
	
	sort  hhid membre
	br 	  hhid respondent_ethnicity  membre confiance ethnicity 

 	
	
	* Generate a binary indicator for the confidence level: 1: in between moyen to aucune, 0: Confidence
	gen 	ind_conf = 0						  	if inlist(confiance,1,2,3)  
	replace ind_conf = 1 							if inlist(confiance,4,5)
	
	tab 	ind_conf
	
	lab var	ind_conf	"Trusts the group member (Yes=1, No=0)"
	
	
	* generate an ethnicity indicator
	gen 	diff_ethnicity = 0						if respondent_ethnicity != . 			& ethnicity !=.
	replace diff_ethnicity = 1 						if respondent_ethnicity != ethnicity 	& ethnicity !=. &  respondent_ethnicity!=.
	
	tab 	diff_ethnicity
	
	lab var diff_ethnicity	"Different ethnicity than group member X (Yes=1, No=0)"
	
	bys 	diff_ethnicity: summ	ind_conf 
	

 	
	
	* Generate an indicator in case it is the same ethnicity -> to verify if the dynamic is correct
	
	gen 	same_ethnicity = 0					if respondent_ethnicity != . & ethnicity !=.
	replace same_ethnicity = 1				 	if respondent_ethnicity == ethnicity & respondent_ethnicity != . & ethnicity !=.
	
	tab 	same_ethnicity
	
	
	br 		hhid respondent_ethnicity group_id confiance membre_id ethnicity		if ethnicity == 10
	
	
	reg		ind_conf same_ethnicity
	
	reg  	ind_conf diff_ethnicity
	
	
	reg  	ind_conf diff_ethnicity		if ethnicity == 10
	

	
	
	
	
	
	
	save "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_confidence_construct.dta", replace
	
	
	
	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionE_confidence_construct.dta", clear

	
	
	
	
	
********************************************************************************
* End of the Do file														   *
********************************************************************************
	
	
	
	
	
	
	



















