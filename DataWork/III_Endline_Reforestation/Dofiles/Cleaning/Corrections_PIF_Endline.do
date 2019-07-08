/* ******************************************************************* *
* ******************************************************************** *
*         															   *
*		  PIF Endline												   *
*                                                             		   *
*         Implement corrections based on HFCs and feedback from		   *
*		  the field 												   *
*																	   *
* ******************************************************************** *
* ******************************************************************** *

** WRITTEN BY: Jonas Guthoff (jguthoff@worldbank.org)
** CREATED: 06/12/2018

	** OUTLINE:		Run Corrections
	
	
* The corrections are coded based on the dates of the corresponding Flag dates
* in the HFC folder


* ---------------------------------------------------------------------------- *
* 								Corrections									   *
* ---------------------------------------------------------------------------- */
	
	
	* AGE corrections
	* Generally, all ages that were corrected were also confirmed, so we can 
	* move the corrected ones over
	
	* destring the Age from the Baseline
	destring b5, replace	
	replace  b5 = b5_correct				if b5_confirm == 2 & b5_correct !=.

	


	* SEXE corrections
	br b6 b6_confirm b6_correct

	decode 	 b6_correct, gen(sexe_str)
	replace	 b6 = sexe_str					if b6 != sexe_str & b6_confirm == 2
	
	
	
	
	* VILLAGE corrections
	br a3_village a3_village_confirm a3_village_autre
	
	* format both village variables
	foreach var in a3_village a3_village_autre {
		replace `var' = proper(`var')
		replace `var' = trim(`var')
		}
	
	replace a3_village = a3_village_autre	if a3_village_autre !="" & a3_village != a3_village_autre
	
	
	
	
	
	* November 2nd, 2018
	* -> only Age corrections to be implemented  - done above
	
	
	
	* November 4th, 2018
	
	* Nombre de repas 
	br d3_10 							if d3_10 == 21
	br d3_9								if d3_9  == 42
	
	* enumerator mistake, corrected in HFCs
	replace d3_10 = 4					if d3_10 == 21
	replace d3_9  = 4					if d3_9  == 42
	
	* Main d'œuvre correction
	replace c13  = 150000				if 100000 & key == "uuid:5eb825df-e41d-40d1-b5ec-baf1442bb318"
	replace c13  = 180000				if 100000 & key == "uuid:4151d224-ccf3-4d87-8cd4-8d55287825ae"
	
		
	
	* November 5th, 2018
	* -> only Age, village corrections to be implemented - done above
	
	
	
	* November 7th, 2018
	replace b10  = 6800					if b10 == 68000  & key == "uuid:74696fca-9145-465d-8e84-a6b90cc1ac25"
	
	replace b10  = 6500					if key == "uuid:7825f444-e5d0-4bc1-9f51-dc8f558f4d9d"
	replace b11  = 225000				if key =="uuid:7825f444-e5d0-4bc1-9f51-dc8f558f4d9d"
		
	replace b10  = 3500					if key == "uuid:2a2aa1ff-fb69-4f03-b1ed-c37eb07957c6"
	replace b11  = 45000				if key == "uuid:2a2aa1ff-fb69-4f03-b1ed-c37eb07957c6"
		
	replace b11 = 850000				if key == "uuid:00f8a968-8424-4d30-8200-0d769736f2c8" 
		
	replace b12 = 6						if key == "uuid:9b8e946e-4501-4629-b7af-5bac6e8624ea"
		
	replace b14 = 35000					if key == "uuid:d7170917-0d28-449f-8c3d-fa0ef3329bfd"	
	replace b14 = 3000					if key == "uuid:e3ede5aa-03bb-47f6-8bf3-8c5c2c976bc1"
	
	replace b15 = 100000				if key == "uuid:d7170917-0d28-449f-8c3d-fa0ef3329bfd"
	replace b15 = 125000				if key == "uuid:e3ede5aa-03bb-47f6-8bf3-8c5c2c976bc1"
		
	replace b38 	 = 90				if key == "uuid:e30094ef-d288-4e32-b996-d26f23de4a43"
	replace b38_unit = 1				if key == "uuid:e30094ef-d288-4e32-b996-d26f23de4a43"
			
	replace c11 = 75000					if key == "uuid:00f8a968-8424-4d30-8200-0d769736f2c8"
		
	replace c18 = 1500000				if key == "uuid:d7170917-0d28-449f-8c3d-fa0ef3329bfd"
		
	replace c3 = 13 					if key == "uuid:8e127e24-92bc-4e5a-a00a-16e9eab7ccec"
		
	replace c7 = 135000					if key == "uuid:8e127e24-92bc-4e5a-a00a-16e9eab7ccec"
	
	* Nov 7th, add	
	replace b10 = 2500 					if key == "uuid:7a1b81ad-ffb6-4e72-97f6-2f1d08ba5a3f"
	
	replace b10 = 15000					if key == "uuid:7825f444-e5d0-4bc1-9f51-dc8f558f4d9d" 
	replace b11 = 120000				if key == "uuid:7825f444-e5d0-4bc1-9f51-dc8f558f4d9d" 
		
	replace b10 = 2000					if key == "uuid:2a2aa1ff-fb69-4f03-b1ed-c37eb07957c6"
	replace b11 = 18000					if key == "uuid:2a2aa1ff-fb69-4f03-b1ed-c37eb07957c6"
		
	replace b11 = 17000					if key == "uuid:2a2aa1ff-fb69-4f03-b1ed-c37eb07957c6"
		
	replace b11 = 23000					if key == "uuid:7a1b81ad-ffb6-4e72-97f6-2f1d08ba5a3f"
		
	replace b11 = 21000					if key == "uuid:5938716f-e7bf-46ff-a3a4-0ee26de37af4"
	replace b11 = 21000					if key == "uuid:eac95f37-6b30-4220-9f3c-894c189358c0"
	replace b11 = 25000					if key == "uuid:e30094ef-d288-4e32-b996-d26f23de4a43"
	replace b11 = 18000					if key == "uuid:9b8e946e-4501-4629-b7af-5bac6e8624ea"	
	replace b11 = 21000					if key == "uuid:9eb477a7-6054-475e-adbe-042317cb189f"
		
	replace b14 = 1500 					if key == "uuid:e3ede5aa-03bb-47f6-8bf3-8c5c2c976bc1"	
	replace b14 = 2000 					if key == "uuid:a6455534-2a0c-4e0b-906c-c9e027702ce0"
	
	replace b15 = 250000				if key == "uuid:72316cca-8332-472b-90e3-bf7d805ec0c4"
	replace b15 = 240000				if key == "uuid:a6455534-2a0c-4e0b-906c-c9e027702ce0"
	
	replace b35 = 8						if key == "uuid:1548cb45-0ae4-4dcb-a31a-8fb30627ad24"
	replace b35 = 5						if key == "uuid:59bf8998-cbb7-421c-8173-24940c1f7d0e"
		
	replace b38 = 70					if key == "uuid:e30094ef-d288-4e32-b996-d26f23de4a43"
	
	
	
	* November 8th, 2018
	replace b10 = 28000					if key == "uuid:37212356-3dbe-4253-9346-48bc9cdfc6bf"
	
	replace b11 = 55000					if key == "uuid:8c052a91-5df5-4bc7-b558-28763e96aa95"
	
	replace b11 = 350000 				if key == "uuid:37212356-3dbe-4253-9346-48bc9cdfc6bf"
	
	replace b27 = 16					if key == "uuid:e309a26f-c2ca-4157-b604-5a776040d6f2"
		
	replace b38 = 1						if key == "uuid:58b97810-91b3-48fa-9a7e-b05dd6a51b47"
	
	replace c18 = 750000				if key == "uuid:37212356-3dbe-4253-9346-48bc9cdfc6bf"
	
	
	
	* November 9th, 2018	
	replace b10 = 15000					if key == "uuid:8307177f-7ff5-4704-be7a-33e8b43d352f"
	
	replace b11 = 250000				if key == "uuid:96e3f9e1-4861-42eb-9786-e13196c0ef3b"
	
	replace b11 = 50000					if key == "uuid:af893208-69ed-46a6-97db-72e40a551a01"
	
	replace c18 = 300000				if key == "uuid:96e3f9e1-4861-42eb-9786-e13196c0ef3b"
	
	replace c2  = 5 					if key == "uuid:5af75c46-5502-4597-baa8-484efc2ac990" 
	
	
	
	* November 10th, 2018
	replace b10 = 15000					if key == "uuid:17ee9cde-838a-4621-bbde-ccec23c669a4"
	
	replace b11 = 65000					if key == "uuid:396f5353-05d9-46a9-b76f-02660a65faec"
	
	replace b11 = 65000					if key == "uuid:938567dc-41e4-465c-a481-dbfe7fe36f43"
	
	replace b11 = 450000				if key == "uuid:67447629-d85b-4b02-8ffd-67cf0968484e"
		
	replace b14 = 60000					if key == "uuid:552ed1f3-3b80-40d0-a292-1a7fc9637039"
	
	replace b14 = 45000					if key == "uuid:78e29ef9-ad9d-4c3d-ada1-0a2a451d758a"
	
	replace b15 = 300000				if key == "uuid:552ed1f3-3b80-40d0-a292-1a7fc9637039"
			
	replace b15 = 170000				if key == "uuid:369fafa5-aae4-4f40-8762-3de696a74f23"
	
	replace b15 = 300000				if key == "uuid:78e29ef9-ad9d-4c3d-ada1-0a2a451d758a"
	
	replace b35 = 10					if key == "uuid:102b5005-4842-4381-a36f-3be38202a771"
	
	replace b35 = 10					if key == "uuid:f585cd1b-91f0-4028-8a43-d2f5b1fd3473"
	
	replace b38 = 1						if key == "uuid:f585cd1b-91f0-4028-8a43-d2f5b1fd3473"
	
	replace b38 = 1						if key == "uuid:102b5005-4842-4381-a36f-3be38202a771"
	
	replace c13 = 50000					if key == "uuid:a4d17a92-9be5-4a87-a372-0f7ab306ad0e"
	
	replace c2  = 11					if key == "uuid:0ae14aa0-93a5-4d65-8225-4e9f01462440"
	
	replace c3  = 13					if key == "uuid:938567dc-41e4-465c-a481-dbfe7fe36f43"
	
	replace c3  = 14					if key == "uuid:0ae14aa0-93a5-4d65-8225-4e9f01462440"
	
	replace c7  = 55000					if key == "uuid:504add56-a3d6-4658-80b1-060e9654d0c4"
	
	
	
	* December 4th, 2018	
	replace b10  = 55000				if key == "uuid:012dc75b-119d-4b3b-a945-dd45a2b61c8b"
	
	replace b11  = 125000				if key == "uuid:f3db0483-0cf4-4b3b-a06a-e1b5803504b7"
	
	replace b11  = 500000				if key == "uuid:71851efe-216c-4e16-aa72-3c5d94a40c11"
	
	replace b14  = 10000				if key == "uuid:6d1a542d-42fc-4665-bc6a-6b5d69a8fc11"
	
	replace c2   = 8					if key == "uuid:2d1dfdd6-77ac-4860-8d88-04562d668d7a"
	
	replace d3_9 = 5					if key == "uuid:57623261-bdd5-4e9d-afb1-836caf17c7dc"
	
	
	* December 7th
	replace b10 = 25000					if key == "uuid:2d7ff906-a203-4a17-9331-91556a7af942"
	
	replace b10 = 25000					if key == "uuid:1ef6a89c-4602-47e4-b44a-4b6d3f7296be"

	replace b14 = 15000					if key == "uuid:490ccbb6-9ddf-4c25-94a7-05caa5ab4320"
	
	replace b15 = 100000				if key == "uuid:125bfc49-b237-4479-8791-f130b118d538"
	
	replace c13 = 33000					if key == "uuid:fa6ddf2d-7387-485d-9c2e-f1b24a00c599"
	
	replace c2  = 7 					if key == "uuid:6f424f87-6b47-445f-8625-88ca5998a897"
		
	replace c3  = 6						if key == "uuid:44e3e775-1838-433c-971a-5e70b3b2470c"
	
	replace c5 =  15000					if key == "uuid:44e3e775-1838-433c-971a-5e70b3b2470c"
		
 	
	* December 13th
	replace	b10 = 15000					 if key == "uuid:52dbc66c-d8b4-4acb-a371-f7fff2d5b9a5"
	
	replace b10 = 15000					 if key == "uuid:b357f7ca-c3e1-4fed-9a65-17cc74767870"
	
	replace b11 = 1200000				 if key == "uuid:b357f7ca-c3e1-4fed-9a65-17cc74767870"
	
	replace b14 = 15000					 if key == "uuid:c96590bf-2570-422b-ae51-0a96397a4d61"
	
	replace b15 = 170000				 if key == "uuid:c96590bf-2570-422b-ae51-0a96397a4d61"
	
	replace c2  = 4						 if key == "uuid:2f6d631d-ce25-4623-9f19-2900592b3447"
	
	
	
/* Corrections do file
Le nom du monsieur en question c'est Poda Raoul fait parti du groupe de traitement au lieu de contrôle.
Le bloc c'est tovor








