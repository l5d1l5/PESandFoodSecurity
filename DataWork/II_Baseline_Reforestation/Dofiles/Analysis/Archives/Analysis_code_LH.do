

***-----------------------------------------------------------------------------
* 	CODE LOREDANA
***-----------------------------------------------------------------------------		
	
*** Identification of survey participants 

* Survey participants by region (%)

			graph pie, over(region) pie(1, color(teal)) pie(2, color(gs12)) ///
							pie(3, color(dkorange)) pie(4, color(navy)) ///
							plabel(_all percent, color(white)) intensity(inten90) ///
							title(Survey participants by region (%), size(medium) color(dknavy))
							graph export $BSLREFOR_out/graphs/graph1.png, replace	
	
	
			tabout bloc foret using table1.xls, c(freq) f(0c 1p 1p) lay(cb) ///
							h1(nil) h3(nil) npos(row) noffset(3) rep
				
				
			catplot region, percent blabel(bar , format(%2.1f)) ysc(r(. 46)) ///
							bar(1, color(teal)) title(Survey participants by region ///
							and treatment status (%), size(medium) color(dknavy)) ///
							graphregion(fcolor(white)) scale(*.7) over(treatment)
							graph export $BSLREFOR_out/graphs/graph2.png, replace	
	
	
			catplot foret, percent blabel(bar , format(%2.1f)) ysc(r(. 46)) bar(1, ///
							color(dknavy)) title(Survey participants by foret and ///
							treatment status (%), size(medium) color(dknavy)) ///
							graphregion(fcolor(white)) scale(*.7) over(treatment)
							graph export $BSLREFOR_out/graphs/graph3.png, replace	
	
	
			tabout bloc foret treatment using table2.xls, c(freq row) f(0c 1p 1p) ///
							lay(cb) h1(nil) h3(nil) npos(row) noffset(3) rep
	
	

***Section B: Socio-demographic characteristics

* Summary statistics table for demographic information

			tabstat age sbq17, stat(n mean sd median min max) format(%7.1g) save	
							return list
							matlist r(StatTotal)
							matrix results = r(StatTotal)'
							matlist results
							putexcel set "table3.xlsx", sheet(tab1) modify
							putexcel A1 = matrix(results), names nformat(number_d2)
							putexcel A1=("Variable")
							putexcel B1=("N")
							putexcel C1=("Mean")
							putexcel D1=("S.D.")
							putexcel E1=("Median")
							putexcel F1=("Min")
							putexcel G1=("Max")

							putexcel A2=("L'age du participant")  
							putexcel A3=("Nombre de membres de menage")
		
	
* Age distribution by forest
				
			graph hbar (count), over(participant_age) over(foret) ///
							bar(1, color(black)) ///
							bar(2, color(teal)) ///
							bar(3, color(dkgreen)) ///
							bar(4, color(navy)) ///
							bar(5, color(gs9)) ///
							bar(6, color(lavender)) ///
							bar(7, color(maroon)) ///
							blabel(bar, size(vsmall) color(white) ///
							position(center) format(%9.1g)) ///
							scale(*.8) ///
							legend(label(1 "Moins que 18") ///
							label(2 "18-24") ///
							label(3 "25-34") /// 
							label(4 "35-44") ///
							label(5 "45-54") ///
							label(6 "55-64") ///
							label(7 "over 64")) ///
							ytitle("percent") ///
							title(Age distribution by forest) graphregion(fcolor(white) ///
							ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) ///
							percent stack asyvars 
							graph export "$BSLREFOR_out/graphs/graph4.png", replace
					
					
 * Gender distribution among survey participants
 
			graph pie, over(sexe) pie(1, color(gs10)) pie(2, color(teal)) plabel(_all percent, ///
							color(white) size(vsmall)) title(Gender distribution among survey respondents, ///
							size(medium) color(navy))
							graph export "$BSLREFOR_out/graphs/graph5.png", replace

 
* Level of education among survey participants

			tabout sbq21 using table4.xls, c(freq col) f(0c 1p 1p) lay(cb) h1(nil) h3(nil) npos(row) noffset(3) rep
	
			
* Level of education by forest

			graph pie, over(sbq21) pie(1, color(gs11)) plabel(1 percent, color(white) size(vsmall) ///
							format(%9.1g)) pie(2, color(lavender)) plabel(2 percent, color(white) ///
							size(vsmall) format(%9.1g)) pie(3, color(navy)) plabel(3 percent, ///
							color(white) size(vsmall) format(%9.1g)) ///
							by(, legend(on)) legend(size(small) /// 
							label(1 "Pas de scolarization") ///
							label(2 "Primaire") ///
							label(3 "Secondaire premier cycle") ///
							label(4 "Secondaire premier cycle technique") ///
							label(5 "Secondaire second cycle")) ///
							by(, title(Level of education among survey respondents by forest)) by(foret) 	
							graph export "$BSLREFOR_out/graphs/graph6.png", replace
							
		
 
 * Primary occupation among survey participants
				
			graph pie, over(sbq9) pie(1, color(lavender)) pie(2, color(navy)) ///
							pie(3, color(gs10)) plabel(1 percent, color(white) format(%9.1g)) ///
							plabel(2 percent, color(white) format(%9.1g)) plabel(3 percent, color(white) ///
							format(%9.1g)) title(Primary occupation among survey participants, ///
							size(medium)) legend(on)			
							graph export "$BSLREFOR_out/graphs/graph7.png", replace
			
	
* Primary occupation by forest 

			graph hbar (count), over(sbq9)  over(foret)  blabel(bar, size(tiny) color(white) position(center) ///
							format(%9.1g)) scale(*.8) ///
							legend(label(1 "Aucun") ///
							label(2 "Agriculteur") 
							label(3 "Eleveur") ///
							label(4 "Agro-pasteur") ///
							label(5 "Autre")) ///
							ytitle("percent") ///
							title(Primary occupation by forest) ///
							graphregion(fcolor(white)ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) ///
							percent stack asyvars			
							graph export $BSLREFOR_out/graphs/graph8.png, replace
								
				
			///tabout foret sbq9 using table3.xls, c(freq row) f(0c 1p 1p) lay(cb) h1(nil) h3(nil) npos(row) noffset(3) rep
		
		
* Summary statistics of total income 

			tabstat total_income, stat(n mean sd median min max) format(%7.1g) save	
					`		return list
							matlist r(StatTotal)
							matrix results = r(StatTotal)'
							matlist results
							putexcel set "table5.xlsx", sheet(tab1) modify
							putexcel A1 = matrix(results), names nformat(number_d2)
							putexcel A1=("Variable")
							putexcel B1=("N")
							putexcel C1=("Mean")
							putexcel D1=("S.D.")
							putexcel E1=("Median")
							putexcel F1=("Min")
							putexcel G1=("Max")

							putexcel A2=(" Revenu total au cours des 12 derniers mois, en 1000s FCFA")
 
 
* Total income - kdensity
			su total_income, meanonly 
							kdensity total_income, xli(`r(mean)', lpa(dash)) ///
							xtitle(Total income (in 1000s FCFA)) ytitle(Density) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
							note ("Note: Variable is winsorized at 0.01")
							graph export $BSLREFOR_out/graphs/graph9.png, replace
	
* Income distribution by primary occupation

			graph hbar (mean) total_income, over(sbq9, label(labsize(vsmall))) ///
							bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
							ytitle(average income (in 1000s FCFA)) ///
							ytitle(, margin(medium)) ///
							title(Income distribution by primary occupation) legend(off) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
							note ("Note: Income variable is winsorized at 0.01")
							graph export $BSLREFOR_out/graphs/graph10.png, replace
			
* Income distribution by forest

			graph hbar (mean) total_income, over(foret, label(labsize(vsmall))) ///
							bar(1, fcolor(gs10))  blabel(bar, format(%9.1g)) ///
							ytitle(average income (in 1000s FCFA)) ///
							ytitle(, margin(medium)) ///
							title(Income distribution by forest) legend(off) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
							note ("Note: Income variable is winsorized at 0.01")
							graph export $BSLREFOR_out/graphs/graph11.png, replace
			
		
* Kernel density estimate for total income by gender
		
	
			summarize total_income if sexe==0
			summarize total_income if sexe==1
	
			twoway kdensity total_income if sexe==0, color(teal) || kdensity total_income if sexe==1, ///
							color(black) legend(order(1 "Homme" 2 "Femme")) ///
							xline(564.3986, lcolor(teal) lpattern(dash)) ///
							xline(212.4152, lcolor(black) lpattern(dash)) ///
							xtitle(Total income (in 1000s FCFA)) ytitle(Density) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
							note("Note: Income variable is winsorized at 0.01")
							graph export $BSLREFOR_out/graphs/graph12.png, replace
			
		
* Income distribution by gender and primary occupation
	
			graph bar (mean) total_income, over(sbq9, label(labsize(vsmall))) ///
							over(sexe, label(labsize(vsmall))) ///
							bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
							ytitle(average monetary value of agricultural production (in 1000s FCFA)) ///
							ytitle(, margin(medium)) ///
							title(Income distribution by gender and primary occupation, size(medium)) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
							note("Note: Income variable is winsorized at 0.01")
							graph export $BSLREFOR_out/graphs/graph13.png, replace
		
		
* Forest management group membership among survey participants

			graph pie, over(sbq22) pie(1, color(gs9)) ///
							pie(2, color(teal)) ///
							pie(3, color(gs10)) ///
							plabel(1 percent, color(white) format(%9.1g)) ///
							plabel(2 percent, color(white) format(%9.1g)) ///
							plabel(3 percent, color(white) format(%9.1g)) ///
							title(Forest management group membership among survey participants, size(medium)) ///
							legend(on)			
							graph export $BSLREFOR_out/graphs/graph14.png, replace
			
				
* Forest management group membership by forest - create stacked bars that add up to 100. 
	
			graph hbar (count), over(sbq22)  over(foret) bar(1, color(gs9)) bar(2, color(teal))  blabel(bar, ///
							size(vsmall) color(white) position(center) format(%9.1g)) scale(*.8) ///
							legend(label(1 "Non") ///
							label(2 "Oui")) ytitle("percent") ///
							title(Forest management group membership by forest) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) ///
							percent stack asyvars
							graph export $BSLREFOR_out/graphs/graph15.png, replace
		
	
* Balance tables 	
	
			iebaltab age sexe sbq18 sbq17 sbq22 total_income, grpvar(treatment) ///
							save("table6.xlsx") rowvarlabels rowlabels("sbq18 Household head? @ sbq17 Household size")
		

***Section C: Assets 

***Asset Index

* Kdensity - asset_index
			su asset_index, meanonly 
							kdensity asset_index, xli(`r(mean)', lpa(dash)) ///
							xtitle(Asset Index) ytitle(Density) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7)
							graph export $BSLREFOR_out/graphs/graph16.png, replace
				
				
* Asset Index by gender			
	
			summarize asset_index if sexe==0
			summarize asset_index if sexe==1
	
			twoway kdensity asset_index if sexe==0, color(teal) || kdensity asset_index if sexe==1, ///
							color(dknavy) legend(order(1 "Homme" 2 "Femme")) ///
							xline( -.0216131, lcolor(teal) lpattern(dash)) ///
							xline(.1145495, lcolor(dknavy) lpattern(dash)) ///
							xtitle(Asset Index) ytitle(Density) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7)
							graph export $BSLREFOR_out/graphs/graph17.png, replace
	

* Asset Index by primary occupation

			graph hbar (mean) asset_index, over(sbq9, label(labsize(vsmall))) bar(1, fcolor(gs9)) ///
							blabel(bar, format(%9.1g)) ///
							ytitle(Asset Index) ytitle(, margin(medium)) ///
							title(Asset Index by primary occupation) legend(off) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) 
							graph export $BSLREFOR_out/graphs/graph18.png, replace
	
	
* Asset Index by gender and primary occupation
	
			graph hbar (mean) asset_index, over(sbq9, label(labsize(vsmall))) over(sexe, label(labsize(vsmall))) ///
							bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
							ytitle(Asset Index) ytitle(, margin(medium)) ///
							title(Asset Index by gender and primary occupation, size(medium)) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) 
							graph export $BSLREFOR_out/graphs/graph19.png, replace


* Balance Tables ~ Asset Index
			iebaltab asset_index, grpvar(treatment) ///
							save("table7.xlsx") rowvarlabels rowlabels ("asset_index Asset Index") 
	

*** Livestock Holding index (TLU)
	
* Kdensity - livestock index
			su tlu, meanonly 
							kdensity tlu, xli(`r(mean)', lpa(dash)) ///
							xtitle(Livestock Index) ytitle(Density) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7)
							graph export $BSLREFOR_out/graphs/graph20.png, replace
		
		
			graph hbar (mean) tlu, over(foret, label(labsize(vsmall))) bar(1, fcolor(teal)) ///
							blabel(bar, format(%9.1g)) ///
							ytitle(index) ytitle(, margin(medium)) ///
							title(Livestock index by forest) legend(off) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) 
							graph export $BSLREFOR_out/graphs/graph21.png, replace
		
		
* Livestock Index by primary occupation

			graph hbar (mean) tlu, over(sbq9, label(labsize(vsmall))) bar(1, fcolor(gs8)) /// 
							blabel(bar, format(%9.1g)) ///
							ytitle(Livestock Index) ytitle(, margin(medium)) ///
							title(Livestock Index by primary occupation) legend(off) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) 
							graph export $BSLREFOR_out/graphs/graph22.png, replace

		
* Livestock Index by gender
		
		///twoway histogram tlu, color(*.5) || kdensity tlu ||, by(sexe)
				
			summarize tlu if sexe==0
			summarize tlu if sexe==1
	
			twoway kdensity tlu if sexe==0, color(teal) || kdensity tlu if sexe==1, color(dknavy) ///
							legend(order(1 "Homme" 2 "Femme")) ///
							xline(5.878377, lcolor(teal) lpattern(dash)) ///
							xline(2.925, lcolor(dknavy) lpattern(dash)) ///
							xtitle(Livestock Index) ytitle(Density) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7)
							graph export $BSLREFOR_out/graphs/graph23.png, replace
	
* Livestock Index by gender and primary occupation
	
			graph hbar (mean) tlu, over(sbq9, label(labsize(vsmall))) over(sexe, label(labsize(vsmall))) ///
							bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
							ytitle(Livestock Index) ytitle(, margin(medium)) ///
							title(Livestock index by gender and primary occupation, size(medium)) 
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) 
							graph export $BSLREFOR_out/graphs/graph24.png, replace

		
* Balance tables ~ Livestock Index		
		
			iebaltab tlu, grpvar(treatment) save("table8.xlsx") rowvarlabels rowlabels ("tlu Livestock Index")
	
	
*Section D: Agricultural production				
	
* Summary statistics for agricultural inputs 

			tabstat sdq2 sdq3 sdq5 sdq7 sdq9 sdq11 sdq13, stat(n mean sd median min max) format(%9.1g) save	
							return list
							matlist r(StatTotal)
							matrix results = r(StatTotal)'
							matlist results
							putexcel set "table9.xlsx", sheet(tab1) modify
							putexcel A1 = matrix(results), names nformat(number_d2)
							putexcel A1=("Variable")
							putexcel B1=("N")
							putexcel C1=("Mean")
							putexcel D1=("S.D.")
							putexcel E1=("Median")
							putexcel F1=("Min")
							putexcel G1=("Max")

							putexcel A2=("Superficie totale de terres, en ha")
							putexcel A3=("Superficie total cultivee, en ha")
							putexcel A4=("Valeur totale des semences ameliorees achetees, en 1000s FCFA")
							putexcel A5=("Valeur totale des engrais chimiques achetes, en 1000s FCFA")
							putexcel A6=("Valeur totale des engrais organiques achetes, en 1000s FCFA")
							putexcel A7=("Valeur totale des produits phytosanitaires achetes, en 1000s FCFA")
							putexcel A8=("Valeur totale de la main d'oeuvre achetee ou louee, en 1000s FCFA")
	

* Land ownership and cultivated land	

* Kdensity - total land
				
			su sdq2, meanonly 
							kdensity sdq2, xli(`r(mean)', lpa(dash)) ///
							xtitle(Superficie totale de terre du menage en ha) ytitle(Density) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
							note("Note: Variable is winsorized at 0.05")
							graph export $BSLREFOR_out/graphs/graph25.png, replace
				
				
* Land ownership by gender (kdensity)			
		
			summarize sdq2 if sexe==0
			summarize sdq2 if sexe==1
		
			twoway kdensity sdq2 if sexe==0, color(teal) || kdensity sdq2 if sexe==1, color(dknavy) ///
							legend(order(1 "Homme" 2 "Femme")) ///
							xline(6.032407, lcolor(teal) lpattern(dash)) ///
							xline(3.882022, lcolor(dknavy) lpattern(dash)) ///
							xtitle(Superficie totale de terre de menage en ha) ytitle(Density) ///
							graphregion(fcolor(white) ifcolor(white)) ///
							plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
							note("Note: Variable is winsorized at 0.05")
							graph export $BSLREFOR_out/graphs/graph26.png, replace


			///graph bar (mean) f1_sdq2 (mean) f2_sdq2 (mean) f3_sdq2 (mean) f4_sdq2 (mean) f5_sdq2 ///
						///(mean) f6_sdq2 (mean) f7_sdq2 (mean) f8_sdq2 (mean) f9_sdq2 (mean) f10_sdq2 (mean) totavg_sdq2, ///
						///blabel(bar, size(vsmall) color(white) position(inside) format(%9.1g)) bargap(20) ///
						///legend(label(1 "Kari") label(2 "Toroba") label(3 "Nosebou") label(4 "Oualou") ///
						///label(5 "Sorobouli") label(6 "Tisse") label(7 "Nazinon") label(8 "Tiogo") ///
						///label(9 "Bontioli") label(10 "Tapoaboopo") label(11 "TOTAL AVERAGE")) ///
						///bar(1, color(gs12)) bar(2, color(gs10)) bar(3, color(gs8)) bar(4, color(gs6)) ///
						///bar(5, color(gs4)) bar(6, color(stone)) bar(7, color(lime)) bar(8, color(eltgreen)) ///
						///bar(9, color(dkgreen)) bar(10, color(forest_green)) bar(11, color(green))  ///
						///legend(on rowgap(minuscule) colgap(minuscule) keygap(minuscule) size(small) ///
						///color(navy) margin(small) nobox fcolor() linegap(vsmall) region(fcolor(white)) ///
						///bmargin(tiny) position(6) span) ///
						///title(Average land size by forest and total average land size, size(small) color(dknavy)) ///
						///graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) scale(*.7)
						///graph export $BSLREFOR_out/graphs/graph12.png, replace

* Total average area of land owned by forest and total average area of land across all forests					
						
			graph hbar (mean) f1_sdq2 (mean) f2_sdq2 (mean) f3_sdq2 f4_sdq2 (mean) f5_sdq2 ///
						(mean) f6_sdq2 (mean) f7_sdq2 (mean) f8_sdq2 (mean) f9_sdq2 ///
						(mean) f10_sdq2 (mean) totavg_sdq2, ///
						showyvars yvaroptions(relabel(1 "Kari" 2 "Toroba" 3 "Nosebou" ///
						4"Oualou" 5 "Sorobouli" 6 "Tisse" 7 "Nazinon" 8 "Tiogo" 9 "Bontioli" ///
						10 "Tapoaboopo" 11 "Total Average") ///
						label(labcolor("dknavy"))) bar(1, color(teal) fintensity(inten90)) ///
						bar(2, color(teal) fintensity(inten90)) ///
						bar(3, color(teal) fintensity(inten90)) ///
						bar(4, color(teal) fintensity(inten90)) ///
						bar(5, color(teal) fintensity(inten90)) ///
						bar(6, color(teal) fintensity(inten90)) ///
						bar(7, color(teal) fintensity(inten90)) ///
						bar(8, color(teal) fintensity(inten90)) ///
						bar(9, color(teal) fintensity(inten90)) ///
						bar(10, color(teal) fintensity(inten90)) ///
						bar(11, color(teal) fintensity(inten90)) ///
						bargap(20) blabel(bar, size(small) color(white) position(center) format(%9.1g)) ///
						ylabel(none, labels) legend(off) ///
						title(Average land size by forest and total average land size, ///
						size(small) color(dknavy)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: Variable is winsorized at 0.05")
						graph export $BSLREFOR_out/graphs/graph27.png, replace
						
						
* Area of cultivated land

* Distribution of cultivated land
				
			histogram landprop, percent fcolor(sienna%85) gap(5) addlabel addlabopts(mlabsize(vsmall) ///
						yvarformat(%4.1f) mlabcolor(dknavy)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) ///
						note("Note: Variable is winsorized at 0.05")
						graph export $BSLREFOR_out/graphs/graph28.png, replace
			
	
* Kdensity estimate for cultivated land
				
			su sdq3, meanonly 
						kdensity sdq3, xli(`r(mean)', lpa(dash)) ///
						xtitle(Superficie totale de terre cultivee du menage en ha) ytitle(Density) /// 
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: Variable is winsorized at 0.05")
						graph export $BSLREFOR_out/graphs/graph29.png, replace

* Are of cultivated land by gender
				
			summarize sdq3 if sexe==0
			summarize sdq3 if sexe==1
		
			twoway kdensity sdq3 if sexe==0, color(teal) || kdensity sdq3 if sexe==1, color(dknavy) ///
						legend(order(1 "Homme" 2 "Femme")) ///
						xline(4.829282, lcolor(teal) lpattern(dash)) ///
						xline(3.174157, lcolor(dknavy) lpattern(dash)) ///
						xtitle(Superficie totale de terre du menage cultivee en ha) ytitle(Density) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: Variable is winsorized at 0.05")
						graph export $BSLREFOR_out/graphs/graph30.png, replace


*Average size of cultivated land by forest and total average bar (across all forests)
			
			graph hbar (mean) f1_sdq3 (mean) f2_sdq3 (mean) f3_sdq3 f4_sdq3 (mean) f5_sdq3 ///
						(mean) f6_sdq3 (mean) f7_sdq3 (mean) f8_sdq3 (mean) f9_sdq3 ///
						(mean) f10_sdq3 (mean) totavg_sdq3, ///
						showyvars yvaroptions(relabel(1 "Kari" 2 "Toroba" 3 "Nosebou" ///
						4"Oualou" 5 "Sorobouli" 6 "Tisse" 7 "Nazinon" 8 "Tiogo" 9 "Bontioli" ///
						10 "Tapoaboopo" 11 "Total Average") ///
						label(labcolor("dknavy"))) ///
						bar(1, color(teal) fintensity(inten90)) ///
						bar(2, color(teal) fintensity(inten90)) ///
						bar(3, color(teal) fintensity(inten90)) ///
						bar(4, color(teal) fintensity(inten90)) ///
						bar(5, color(teal) fintensity(inten90)) ///
						bar(6, color(teal) fintensity(inten90)) ///
						bar(7, color(teal) fintensity(inten90)) ///
						bar(8, color(teal) fintensity(inten90)) ///
						bar(9, color(teal) fintensity(inten90)) ///
						bar(10, color(teal) fintensity(inten90)) ///
						bar(11, color(teal) fintensity(inten90)) ///
						bargap(20) blabel(bar, size(small) color(white) position(center) ///
						format(%9.1g)) ylabel(none, labels) legend(off) ///
						title(Average size of cultivated land by forest and total average size of cultivated land, ///
						size(small) color(dknavy)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: Variable is winsorized at 0.05")
						graph export $BSLREFOR_out/graphs/graph31.png, replace
						
										
						
*** Agricultural Inputs 	

	* Proportions for the use of agricultural inputs

		*to obtain percentages, we convert 1 to 100 for the binary variables
			foreach input of varlist sdq4 sdq6 sdq8 sdq10 sdq12 {
						recode `input' (1=100)
			}

	
			graph hbar sdq4 sdq6 sdq8 sdq10 sdq12, ///
						bargap(20)  blabel(bar, format(%9.1g)) ///
						legend(label(1 "semences ameliorees") ///
						label(2 "engrais chimiques") ///
						label(3 "engrais organiques") ///
						label(4 "produits phytosanitaires") ///
						label(5 "main d'oeuvre agricole")) ///
						ytitle(percent) ytitle(, margin(medium)) ///
						title(Use of agricultural inputs (%), size(medium)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) ///
						graph export $BSLREFOR_out/graphs/graph32.png, replace
					
						
	* Improved seed varities
				
			graph hbar (mean) f1_sdq5 (mean) f2_sdq5 (mean) f3_sdq5 f4_sdq5 (mean) f5_sdq5 ///
						(mean) f6_sdq5 (mean) f7_sdq5 (mean) f8_sdq5 (mean) f9_sdq5 ///
						(mean) f10_sdq5 (mean) totavg_sdq5, ///
						showyvars yvaroptions(relabel(1 "Kari" 2 "Toroba" 3 "Nosebou" ///
						4"Oualou" 5 "Sorobouli" 6 "Tisse" 7 "Nazinon" 8 "Tiogo" ///
						9 "Bontioli" 10 "Tapoaboopo" 11 "Total Average") ///
						label(labcolor("dknavy"))) ///
						bar(1, color(gs11) fintensity(inten90)) ///
						bar(2, color(gs11) fintensity(inten90)) ///
						bar(3, color(gs11) fintensity(inten90)) ///
						bar(4, color(gs11) fintensity(inten90)) ///
						bar(5, color(gs11) fintensity(inten90)) ///
						bar(6, color(gs11) fintensity(inten90)) ///
						bar(7, color(gs11) fintensity(inten90)) ///
						bar(8, color(gs11) fintensity(inten90)) ///
						bar(9, color(gs11) fintensity(inten90)) ///
						bar(10, color(gs11) fintensity(inten90)) ///
						bar(11, color(gs5) fintensity(inten90)) ///
						bargap(20) blabel(bar, size(small) color(white) position(center) ///
						format(%9.1g)) ylabel(none, labels) legend(off) ///
						title(Average expenditure (in 1000s FCFA) on improved seed varieties by forest and total average expenditure, ///
						size(small) color(dknavy)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)
						graph export $BSLREFOR_out/graphs/graph33.png, replace
						
											

	* chemical fertilizers


			graph hbar (mean) f1_sdq7 (mean) f2_sdq7 (mean) f3_sdq7 f4_sdq7 (mean) f5_sdq7 ///
						(mean) f6_sdq7 (mean) f7_sdq7 (mean) f8_sdq7 (mean) f9_sdq7 ///
						(mean) f10_sdq7 (mean) totavg_sdq7, ///
						showyvars yvaroptions(relabel(1 "Kari" 2 "Toroba" 3 "Nosebou" ///
						4"Oualou" 5 "Sorobouli" 6 "Tisse" 7 "Nazinon" 8 "Tiogo" ///
						9 "Bontioli" 10 "Tapoaboopo" 11 "Total Average") ///
						label(labcolor("dknavy"))) ///
						bar(1, color(gs11) fintensity(inten90)) ///
						bar(2, color(gs11) fintensity(inten90)) ///
						bar(3, color(gs11) fintensity(inten90)) ///
						bar(4, color(gs11) fintensity(inten90)) ///
						bar(5, color(gs11) fintensity(inten90)) ///
						bar(6, color(gs11) fintensity(inten90)) ///
						bar(7, color(gs11) fintensity(inten90)) ///
						bar(8, color(gs11) fintensity(inten90)) ///
						bar(9, color(gs11) fintensity(inten90)) ///
						bar(10, color(gs11) fintensity(inten90)) ///
						bar(11, color(gs5) fintensity(inten90)) ///
						bargap(20) blabel(bar, size(small) color(white) position(center) ///
						format(%9.1g)) ylabel(none, labels) legend(off) ///
						title(Average expenditure (in 1000s FCFA) on chemical fertilizers by forest and total average expenditure, ///
						size(small) color(dknavy)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)
						graph export $BSLREFOR_out/graphs/graph34.png, replace
	

	* organic fertilizers

		
		graph hbar (mean) f1_sdq9 (mean) f2_sdq9 (mean) f3_sdq9 f4_sdq9 (mean) f5_sdq9 ///
						(mean) f6_sdq9 (mean) f7_sdq9 (mean) f8_sdq9 (mean) f9_sdq9 ///
						(mean) f10_sdq9 (mean) totavg_sdq9, ///
						showyvars yvaroptions(relabel(1 "Kari" 2 "Toroba" 3 "Nosebou" ///
						4"Oualou" 5 "Sorobouli" 6 "Tisse" 7 "Nazinon" 8 "Tiogo" 9 "Bontioli" ///
						10 "Tapoaboopo" 11 "Total Average") ///
						label(labcolor("dknavy"))) ///
						bar(1, color(gs11) fintensity(inten90)) ///
						bar(2, color(gs11) fintensity(inten90)) ///
						bar(3, color(gs11) fintensity(inten90)) ///
						bar(4, color(gs11) fintensity(inten90)) ///
						bar(5, color(gs11) fintensity(inten90)) ///
						bar(6, color(gs11) fintensity(inten90)) ///
						bar(7, color(gs11) fintensity(inten90)) ///
						bar(8, color(gs11) fintensity(inten90)) ///
						bar(9, color(gs11) fintensity(inten90)) ///
						bar(10, color(gs11) fintensity(inten90)) ///
						bar(11, color(gs5) fintensity(inten90)) ///
						bargap(20) blabel(bar, size(small) color(white) position(center) ///
						format(%9.1g)) ylabel(none, labels) legend(off) ///
						title(Average expenditure (in 1000s FCFA) on organic fertilizers by forest and total average expenditure, ///
						size(small) color(dknavy)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)
						graph export $BSLREFOR_out/graphs/graph35.png, replace

						
	* pesticide products


		graph hbar (mean) f1_sdq11 (mean) f2_sdq11 (mean) f3_sdq11 f4_sdq11 (mean) f5_sdq11 ///
						(mean) f6_sdq11 (mean) f7_sdq11 (mean) f8_sdq11 (mean) f9_sdq11 ///
						(mean) f10_sdq11 (mean) totavg_sdq11, ///
						showyvars yvaroptions(relabel(1 "Kari" 2 "Toroba" 3 "Nosebou" ///
						4"Oualou" 5 "Sorobouli" 6 "Tisse" 7 "Nazinon" 8 "Tiogo" 9 "Bontioli" ///
						10 "Tapoaboopo" 11 "Total Average") ///
						label(labcolor("dknavy"))) ///
						bar(1, color(gs11) fintensity(inten90)) ///
						bar(2, color(gs11) fintensity(inten90)) ///
						bar(3, color(gs11) fintensity(inten90)) ///
						bar(4, color(gs11) fintensity(inten90)) ///
						bar(5, color(gs11) fintensity(inten90)) ///
						bar(6, color(gs11) fintensity(inten90)) ///
						bar(7, color(gs11) fintensity(inten90)) ///
						bar(8, color(gs11) fintensity(inten90)) ///
						bar(9, color(gs11) fintensity(inten90)) ///
						bar(10, color(gs11) fintensity(inten90)) ///
						bar(11, color(gs5) fintensity(inten90)) ///
						bargap(20) blabel(bar, size(small) color(white) position(center) ///
						format(%9.1g)) ylabel(none, labels) legend(off) ///
						title(Average expenditure (in 1000s FCFA) on pesticide products by forest and total average expenditure, ///
						size(small) color(dknavy)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)
						graph export $BSLREFOR_out/graphs/graph36.png, replace
	


	*labor



		graph hbar (mean) f1_sdq13 (mean) f2_sdq13 (mean) f3_sdq13 f4_sdq13 (mean) f5_sdq13 ///
						(mean) f6_sdq13 (mean) f7_sdq13 (mean) f8_sdq13 (mean) f9_sdq13 ///
						(mean) f10_sdq13 (mean) totavg_sdq13, ///
						showyvars yvaroptions(relabel(1 "Kari" 2 "Toroba" 3 "Nosebou" ///
						4"Oualou" 5 "Sorobouli" 6 "Tisse" 7 "Nazinon" 8 "Tiogo" ///
						9 "Bontioli" 10 "Tapoaboopo" 11 "Total Average") ///
						label(labcolor("dknavy"))) ///
						bar(1, color(gs11) fintensity(inten90)) ///
						bar(2, color(gs11) fintensity(inten90)) ///
						bar(3, color(gs11) fintensity(inten90)) ///
						bar(4, color(gs11) fintensity(inten90)) ///
						bar(5, color(gs11) fintensity(inten90)) ///
						bar(6, color(gs11) fintensity(inten90)) ///
						bar(7, color(gs11) fintensity(inten90)) ///
						bar(8, color(gs11) fintensity(inten90)) ///
						bar(9, color(gs11) fintensity(inten90)) ///
						bar(10, color(gs11) fintensity(inten90)) ///
						bar(11, color(gs5) fintensity(inten90)) ///
						bargap(20) blabel(bar, size(small) color(white) position(center) ///
						format(%9.1g)) ylabel(none, labels) legend(off) ///
						title(Average expenditure (in 1000s FCFA) on labor by forest and total average expenditure, ///
						size(small) color(dknavy)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)
						graph export $BSLREFOR_out/graphs/graph37.png, replace
	

* Balance tables for agricultural inputs

		iebaltab sdq2 sdq3 sdq5 sdq7 sdq9 sdq11 sdq13, grpvar(treatment) ///
						save("table10.xlsx") rowvarlabels rowlabels("sdq2 Superficie de terre totale, en ha @ sdq3 Superficie de terre cultivee, en ha")
	
	
	
* Summary statistics for the monetary value of agricultural production and yield

		tabstat sdq18 yield, stat(n mean sd median min max) format(%9.1g) save	
						return list
						matlist r(StatTotal)
						matrix results = r(StatTotal)'
						matlist results
						putexcel set "table11.xlsx", sheet(tab1) modify
						putexcel A1 = matrix(results), names nformat(number_d2)
						putexcel A1=("Variable")
						putexcel B1=("N")
						putexcel C1=("Mean")
						putexcel D1=("S.D.")
						putexcel E1=("Median")
						putexcel F1=("Min")
						putexcel G1=("Max")

						putexcel A2=("Valeur totale de la production agricole, en 1000s FCFA")
						putexcel A3=("Level of yield, FCFA per ha")
	
	
* Agricultural production by forest

		///graph hbar (mean) sdq18, over(foret, label(labsize(vsmall))) bar(1, fcolor(dkorange))  blabel(bar, format(%9.1g)) ///
				///ytitle(average monetary value of agricultural production (in 1000s FCFA)) ytitle(, margin(medium)) ///
				///title(Agricultural production by forest) legend(off) graphregion(fcolor(white) ///
				///ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) scale(*.7) 
				///graph export $BSLREFOR_out/graphs/graph19.png, replace

	
		///graph hbar (mean) sdq18, over(foret, label(labsize(vsmall))) over(sexe) bar(1, fcolor(midblue))  blabel(bar, format(%9.1g)) ///
				///ytitle(average monetary value of agricultural production (in 1000s FCFA)) ytitle(, margin(medium)) ///
				///title(Agricultural production by gender and forest) legend(off) graphregion(fcolor(white) ///
				///ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) scale(*.7) 
				///graph export $BSLREFOR_out/graphs/graph20.png, replace

	
	
* Balance tables for agricultural production

		iebaltab sdq18 yield, grpvar(treatment) ///
						save("table12.xlsx") rowvarlabels rowlabels("sdq18 Valeur totale de la production agricole, en 1000s FCFA")
	
				



* Kernel density estimate for yield
	
		su yield, meanonly 
						kdensity yield, xli(`r(mean)', lpa(dash)) ///
						xtitle(Niveau du rendement - FCFA per ha) ytitle(Density) ///
						graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: Variable is winsorized at 0.05")
						graph export $BSLREFOR_out/graphs/graph38.png, replace

* Yield by gender
				
		summarize yield if sexe==0
		summarize yield if sexe==1
		
		twoway kdensity yield if sexe==0, color(teal) || kdensity yield if sexe==1, ///
						color(dknavy) legend(order(1 "Homme" 2 "Femme")) ///
						xline(127.4965, lcolor(teal) lpattern(dash)) ///
						xline(115.4579, lcolor(dknavy) lpattern(dash)) ///
						xtitle(Niveau du rendement - FCFA per ha) ytitle(Density) ///
						graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: Variable is winsorized at 0.05")
						graph export $BSLREFOR_out/graphs/graph39.png, replace
	
	
* Yield by primary occupation

		graph hbar (mean) yield, over(sbq9, label(labsize(vsmall))) ///
						bar(1, fcolor(gs9))  blabel(bar, format(%9.1g)) ///
						ytitle(average yield- FCFA per ha) ytitle(, margin(medium)) ///
						title(Yield by primary occupation) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: Variable is winsorized at 0.05")
						graph export $BSLREFOR_out/graphs/graph40.png, replace
		

		
* Yield by forest

		graph hbar (mean) yield, over(foret, label(labsize(vsmall))) ///
						bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
						ytitle(average yield- FCFA per ha) ytitle(, margin(medium)) ///
						title(Yield by forest) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: Variable is winsorized at 0.05")
						graph export $BSLREFOR_out/graphs/graph41.png, replace
		
			
		
* Yield by gender and primary occupation
	
		graph bar (mean) yield, over(sbq9, label(labsize(vsmall))) over(sexe, ///
						label(labsize(vsmall))) bar(1, fcolor(gs10)) ///
						blabel(bar, format(%9.1g)) ///
						ytitle(average yield - FCFA per ha) ///
						ytitle(, margin(medium)) ///
						title(Yield by gender and primary occupation, size(medium)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: Variable is winsorized at 0.05")
						graph export $BSLREFOR_out/graphs/graph42.png, replace
	

* Food expenditure

* Summary statistics for the monetary value of food consumed

		tabstat food_totalval, stat(n mean sd median min max) format(%9.1g) save	
						return list
						matlist r(StatTotal)
						matrix results = r(StatTotal)'
						matlist results
						putexcel set "table13.xlsx", sheet(tab1) modify
						putexcel A1 = matrix(results), names nformat(number_d2)
						putexcel A1=("Variable")
						putexcel B1=("N")
						putexcel C1=("Mean")
						putexcel D1=("S.D.")
						putexcel E1=("Median")
						putexcel F1=("Min")
						putexcel G1=("Max")
						putexcel A2= ("Total monetary value of food from all sources, en 1000s FCFA")


		su food_totalval, detail 
				mat b = `r(p50)'
				local beta = b[1,1]
				local beta = round(`=100*`beta'',2)/100
				di "`beta'"
						kdensity food_totalval, xli(`beta', lpa(dash)) xmlabel(`beta' "Med=`beta'", labsize(vsmall)) ///
						xtitle(Monetary value of food consumed over past 7 days - in 1000s FCFA) ytitle(Density) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)
						graph export "$BSLREFOR_out/graphs/graph43.png", replace
	

* Food expenditure by gender

		summarize food_totalval if sexe==0
		summarize food_totalval if sexe==1
		
		twoway kdensity food_totalval if sexe==0, color(teal) || kdensity food_totalval if sexe==1, ///
						color(dknavy) legend(order(1 "Homme" 2 "Femme")) ///
						xline(22.86907, lcolor(teal) lpattern(dash)) ///
						xline(20.18953, lcolor(dknavy) lpattern(dash)) ///
						xtitle(Monetary value of food consumed over past 7 days - in 1000s FCFA) ytitle(Density) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) 
						graph export "$BSLREFOR_out/graphs/graph44.png", replace
	

* Proportion of food expenditure by primary occupation
	
		graph bar food_totalval, over(sbq9) blabel(bar, size(small) color(white) position(center) ///
						format(%9.1g)) bar(1, color(teal)) bargap(-10) legend(off) ///
						ytitle ("Value in 1000s FCFA") ///
						title(Total monetary value of food consumed over the past 7 days, size(medium)) ///
						subtitle ("By primary occupation") ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)
						graph export $BSLREFOR_out/graphs/graph45.png, replace
		

		
* Food expenditure by forest

		graph hbar (mean) food_totalval, over(foret, label(labsize(vsmall))) ///
						bar(1, fcolor(teal))  blabel(bar, format(%9.1g)) ///
						ytitle(Monetary value of food consumed over past 7 days - in 1000s FCFA) ///
						ytitle(, margin(medium)) ///
						title(Monetary value of food consumed by forest) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)								
						graph export $BSLREFOR_out/graphs/graph46.png, replace
		
			
		
* Food expenditure by gender and primary occupation
	
		graph bar (mean) food_totalval, over(sbq9, label(labsize(vsmall))) ///
						over(sexe, label(labsize(vsmall))) bar(1, fcolor(gs10)) ///
						blabel(bar, format(%9.1g)) ///
						ytitle(Monetary value of food consumed over past 7 days - in 1000s FCFA) ///
						ytitle(, margin(medium)) ///
						title(Monetary value of food consumed by gender and primary occupation, size(medium)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7)
						graph export $BSLREFOR_out/graphs/graph47.png, replace
	

* Balance tables for food expenditure

		iebaltab food_totalval, grpvar(treatment) ///
						save("table14.xlsx") rowvarlabels rowlabels("food_totalval Total monetary value of food consumed, en 1000s FCFA")
	
*Household Dietary Diversity Score

		tabstat hdds, stat(n mean sd median min max) format(%9.1g) save	
						return list
						matlist r(StatTotal)
						matrix results = r(StatTotal)'
						matlist results
						putexcel set "table15.xlsx", sheet(tab1) modify
						putexcel A1 = matrix(results), names nformat(number_d2)
						putexcel A1=("Variable")
						putexcel B1=("N")
						putexcel C1=("Mean")
						putexcel D1=("S.D.")
						putexcel E1=("Median")
						putexcel F1=("Min")
						putexcel G1=("Max")
						putexcel A2=("Household dietary diversity score")
					
	
* hdds by gender

		summarize hdds if sexe==0
		summarize hdds if sexe==1

		 hist hdds,  percent addlabels color(teal) ///
						xtitle(household dietary diversity score (HDDS)) ytitle(Density) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: HDDS is measured on a scale 0-12")
						graph export "$BSLREFOR_out/graphs/graph48.png", replace		
		
		
		twoway kdensity hdds if sexe==0, color(teal) || kdensity hdds if sexe==1, ///
						color(dknavy) legend(order(1 "Homme" 2 "Femme")) ///
						xline(5.603774, lcolor(teal) lpattern(dash)) ///
						xline(6.17, lcolor(dknavy) lpattern(dash)) ///
						xtitle(household dietary diversity score (HDDS)) ytitle(Density) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: HDDS is measured on a scale 0-12")
						graph export $BSLREFOR_out/graphs/graph48.png, replace
	

*hdds by primary occupation
		graph bar hdds, over(sbq9) blabel(bar, size(small) color(white) position(center) ///
						format(%9.1g)) bar(1, color(teal)) ///
						bargap(-10) legend(off) ///
						ytitle ("hdds") ///
						title(Household dietary diversity score, size(medium)) ///
						subtitle ("By primary occupation") graphregion(fcolor(white) ///
						ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: HDDS is measured on a scale 0-12")
						graph export $BSLREFOR_out/graphs/graph49.png, replace
		
	
* hdds by forest

		graph hbar (mean) hdds, over(foret, label(labsize(vsmall))) ///
						bar(1, fcolor(gs10))  blabel(bar, format(%9.1g)) ///
						ytitle(hdds) ytitle(, margin(medium)) ///
						title(Household dietary diversity score by forest) legend(off) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: HDDS is measured on a scale 0-12")
						graph export $BSLREFOR_out/graphs/graph50.png, replace
	

* hdds by gender and primary occupation
	
		graph bar (mean) hdds, over(sbq9, label(labsize(vsmall))) ///
						over(sexe, label(labsize(vsmall))) ///
						bar(1, fcolor(gs10))  blabel(bar, format(%9.1g)) ///
						ytitle(hdds) ytitle(, margin(medium)) ///
						title(Household dietary diversity score by gender and primary occupation, size(medium)) ///
						graphregion(fcolor(white) ifcolor(white)) ///
						plotregion(fcolor(white) ifcolor(white)) scale(*.7) ///
						note("Note: HDDS is measured on a scale 0-12")
						graph export $BSLREFOR_out/graphs/graph51.png, replace
	

* Balance tables for hdds

		iebaltab hdds, grpvar(treatment) ///
						save("table16.xlsx") rowvarlabels rowlabels("hdds household dietary diversity score")









