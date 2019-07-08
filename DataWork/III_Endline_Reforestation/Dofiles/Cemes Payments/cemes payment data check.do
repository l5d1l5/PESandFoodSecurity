/*
After discussions with cemes team, these corrections were done on some names

Two types of issues were found.  

Problem 1: Mistakes done by cemes on names spelling

nom_dime	prenom_dime	nom_cemes	prenom_ceme	observation
GORO		OUMAR		KORO		OUMAR		Nom ecrit avec erreur
SAWADOGO	DRAMANE		SAWADOGO	RASMANE		Prenom ecrit avec erreur
NEO 		DRISSA		NEWO 		DRISSA		Nom ecrit avec erreur
ZOMA		ALBERT		ZOUMA		ALBERT		Nom ecrit avec erreur
ZOMA		WEND-NGUDI	ZOMA		WINDGOUDA	Prenom ecrit avec erreur
BAGNAON		BEVROU		BAGNON		BEVROU		Nom ecrit avec erreur
BAGNAON		BETIA		BAGNON		BITIA		Nom ecrit avec erreur

Problem 2: Names corrected during the payment (mis-spelling on the master data)

nom_dime	prenom_dime	nom_cemes	prenom_ceme	observation
BATIENE		ROGER		BATIENE		ROGER YAYA	Nom corrigé sur le terrain
BANAO		DABA		BANAO		BABA		Nom corrigé sur le terrain
KONE		DEDOUGOU	KONE		DEDOU		Nom corrigé sur le terrain
KAMOUNI		JOCELINE	KANTIONO	JOCEYLINE	Nom corrigé sur le terrain
NEBIE		ABOU		NEBIE		EBOUBIE		Nom corrigé sur le terrain
KAKOUAN		RASMATA		KANKOUAN	RASMATA		Nom corrigé sur le terrain
PODA		NOUON		PODA		Fabere		Nom corrigé sur le terrain

Problem 3: Replacement done by the groups in the field
In Bontioli, six persons left their groups mainly due to migration

Bontioli, groupe bleu:
PODA SANYAOUFOU a remplacé KAMBIRE DOMIN-YIRE

Tovor, groupe bleu
PODA RAOUL a remplacé PODA ANICET 
PODA DIEUDONNE a remplacé SOME JUSTIN 

Zambo, groupe rouge
DABIRE GNINEMAYI a remplacé HIEN ZIEM 
SOMDA NIFASSOA a remplacé SOMDA FLORENT 
PODA BALZAOL a remplacé SOME POLEON 

When we take into account all these issues, the merging is 100% perfect
*/

clear all

*cd "C:\Users\ICRAF\Dropbox\WB_PIF_BF\ENDLINE\PAIEMENT PARTICIPANTS\WFILE"
cd "C:\Users\WB495145\Dropbox\World Bank projects\PROJECTS\1-BURKINA FORESTRY\DataWork\III_Endline_Reforestation\Dofiles\New folder\" 
*1. CEMES payment data
clear
import excel "Données paiement des participants pif.xlsx", sheet("Sheet1") firstrow
drop if groupe=="Parcelle verte"

** Harmonize groups spelling accross both datasets
replace groupe="GROUPE ROUGE" if groupe=="Parcelle Rouge"
replace groupe="GROUPE BLEU" if groupe=="Parcelle Bleue"

** Harmonize Blocs spelling accross both datasets
replace bloc="GALO" if bloc=="GALO (B2)"
replace bloc="SILIMBA" if bloc=="SILIMBA(B1)"
replace bloc="NADONO" if bloc=="NADONO (B3)"

* Correct names spelling
replace nom="GORO" if nom=="KORO" & prenom=="OUMAR"
replace prenom="DRAMANE" if nom=="SAWADOGO" & prenom=="RASMANE"
replace nom="NEO" if nom=="NEWO " & prenom=="DRISSA"
replace nom="ZOMA" if nom=="ZOUMA" & prenom=="ALBERT"
replace prenom="WEND-NGUDI" if nom=="ZOMA" & prenom=="WINDGOUDA"
replace nom="BAGNAON" if nom=="BAGNON" & prenom=="BEVROU"
replace nom="BAGNAON" if nom=="BAGNON" & prenom=="BITIA"
replace prenom="BETIA" if nom=="BAGNAON" & prenom=="BITIA"

* Check for duplicates
duplicates report region site bloc groupe nom prenom sexe

sort region site bloc groupe
gen idusing=_n
save cemes_payment_data.dta, replace

*2. Master data shared with cemes for the payment

clear
use "tracking for participants payment", clear

** Harmonize groups spelling accross both datasets
replace groupe="GROUPE ROUGE" if groupe=="Groupe ROUGE"
replace groupe="GROUPE BLEU" if groupe=="Groupe BLEU"

* Correct names spelling
replace prenom="ROGER YAYA" if nom=="BATIENE" & prenom=="ROGER"	
replace prenom="BABA" if nom=="BANAO" & prenom=="DABA"
replace prenom="DEDOU" if nom=="KONE" & prenom=="DEDOUGOU"	
replace prenom="JOCEYLINE" if nom=="KAMOUNI" & prenom=="JOCELINE"
replace nom="KANTIONO" if nom=="KAMOUNI" & prenom=="JOCEYLINE"	
replace prenom="EBOUBIE" if nom=="NEBIE" & prenom=="ABOU"	
replace nom="KANKOUAN" if nom=="KAKOUAN" & prenom=="RASMATA"	
replace prenom="Fabere" if nom=="PODA" & prenom=="NOUON"

* Insert replacements made in Bontioli

* PODA SANYAOUFOU has replaced KAMBIRE DOMIN-YIRE in Bontioli, groupe bleu
replace nom="PODA" if nom=="KAMBIRE" & prenom=="DOMIN YIRE"
replace prenom="SANYAOUFOU" if nom=="PODA" & prenom=="DOMIN YIRE"

* PODA RAOUL has replaced PODA ANICET in Tovor, groupe bleu
replace prenom="RAOUL" if nom=="PODA" & prenom=="ANICET"

* PODA DIEUDONNE has replaced SOME JUSTIN in Tovor, groupe bleu
replace nom="PODA" if nom=="SOME" & prenom=="JUSTIN"
replace prenom="DIEUDONNE" if nom=="PODA" & prenom=="JUSTIN"

* DABIRE GNINEMAYI has replaced HIEN ZIEM in Zambo, groupe rouge
replace nom="DABIRE" if nom=="HIEN" & prenom=="ZIEM"
replace prenom="GNINEMAYI" if nom=="DABIRE" & prenom=="ZIEM"

*SOMDA NIFASSOA has replaced SOMDA FLORENT in Zambo, groupe rouge
replace prenom="NIFASSOA" if nom=="SOMDA" & prenom=="M. FLORENT"

*PODA BALZAOL has replaced SOME POLEON in Zambo, groupe rouge
replace nom="PODA" if nom=="SOME" & prenom=="POLEON"
replace prenom="BALZAOL" if nom=="PODA" & prenom=="POLEON"			
		
* Check for duplicates
duplicates report region site bloc groupe nom prenom sexe
sort region site bloc groupe
gen idmaster=_n

save "$BSLREFOR_dt/Intermediate/tempSERGE.dta", replace


*3. Merging the datasets
reclink region site bloc groupe nom prenom sexe using cemes_payment_data, gen (myscore) idm (idmaster) idu (idusing)
ta myscore


