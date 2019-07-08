	
	
	
	
	* Load dataset

	use "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD_construct.dta", clear	
	
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD2_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionD3_construct.dta"
		drop _merge
		
		merge 1:1 hhid using "$EDLREFOR_dt/Intermediate/Constructed/PIF_Endline_SectionA_construct.dta", keepusing(region site bloc parcelle statut) gen(serge1)
		keep if serge1==3		
	
	
	* set directory
	global 		dir "$EDLREFOR_outFin/PES_paper"
	
	
	tab 		treatment	
	
	
	* drop not found participants
	tab 		found_participant
	
	drop if 	found_participant == 2
	 
	
	* label variables
	lab var HFIAS_score		"Household Food Insecurity Access Scale (HFIAS) \in [0,4]"
	lab var HFIA_cat_1		"HFIAS = 1 (food secure)"
	lab var HFIA_cat_4		"HFIAS = 4 (severely insecure)"
	lab var HHS				"Household Hunger Scale (HHS) \in [0,3]"
	lab var HHScat1			"HHS = 1 (no hunger)"
	lab var HHScat2			"HHS = 2 (moderate hunger)"
	
	

	* Set number of repetitions and seeds
	local  	seedsNum 	123456
	local  	repsNum 	1000

	* Set variables locals
	local 	balVars 	"FoodExp LFoodExp HFIAS_score HFIA_cat_1  HFIA_cat_4 HHS HHScat1 HHScat2 HDDS"				
	local   treatVar	"statut"
	local 	strataVar	"bloc"
	*local	clusterVar  "q6"
	
	* JONAS: drop here one treatment arm, so that table doesnt have to be adjusted
	*drop if treatment_final == 3
	
	* Drop existing matrices
	cap mat drop _all
	
	* Loop on outcome variables
	foreach var of local balVars {
		
		* Compute randomization inference p-values
		ritest `treatVar' _b[`treatVar'], 								///
		reps(`repsNum') seed(`seedsNum') strata(`strataVar') nodots:	///
		areg `var' `treatVar' , a(`strataVar')   /* cl(`clusterVar') */
		
		* And store them in a matrix (with a space before or after the cell)
		mat ri_pvalues = nullmat(ri_pvalues) \ r(p)
		mat ri_pvalues = nullmat(ri_pvalues) \ .		
	}
		
	* Drop observations without strata variable
	drop if missing(`strataVar')
	
	preserve
		
		#d	;
		
			// Run the actual `iebaltab' command and browse the results
			iebaltab `balVars',
					  /// vce(cluster `clusterVar') ///
					  grpvar(`treatVar') fixedeffect(`strataVar')
					  grplabels(1 Treatment @ 0 Control) order(1 0)
					  pttest starsnoadd
					  rowvarlabels
					  tblnonote
					  browse
					  replace
			;
		#d	cr
		
		* Drop title raws
		drop in   1/3
		
		* Replace parentheses for standard errors
		replace v3 = subinstr(v3,"[","(",.)
		replace v5 = subinstr(v5,"[","(",.)
		replace v3 = subinstr(v3,"]",")",.)
		replace v5 = subinstr(v5,"]",")",.)

		* Temporary save the table output
		tempfile baltab
		save	"$dir/temp.dta", replace
		
	restore
	
	* Use results
	use "$dir/temp.dta", clear
		
	* Here, if you need, you can merge more results, which you had produced and stored in other temporary files
	* Say, if you want to add another column, `iebaltab` does not allow to add automatically, so you would have to created it and them merge it here
	* ...
	
	* Retrieve RI p-values from matrix
	svmat 	 ri_pvalues
	
	* Generate p-values string to match `baltab` formatting
	gen		 v7 = string(ri_pvalues1 ,  "%9.3f")
	replace  v7 = ""  if ri_pvalues1 == .
	drop				 ri_pvalues1
	//you can play with this variable if you want to move it in other positions of the table
	//or add parentheses
	
	
	* Browse results if you want
	*br
	*pause
	
	* Save LaTeX file containing results
	local 	 				 fileCount = 0
	dataout, save("$dir/file`fileCount'.tex") replace tex nohead noauto
	//you can either use this TeX or format it as below
	
	
	
	* Remove lines from `dataout` export
	foreach lineToRemove in "\BSdocumentclass[]{article}"			///
							"\BSsetlength{\BSpdfpagewidth}{8.5in}" 	///
							"\BSsetlength{\BSpdfpageheight}{11in}"  ///
							"\BSbegin{document}" 					///
							"\BSend{document}" 						///
							"\BSbegin{tabular}{lcccccc}"			///
							"Variable"								///
							"\BShline"								///
							"\BSend{tabular}"						{
		
			filefilter "$dir/file`fileCount'.tex"					///
					   "$dir/file`=`fileCount'+1'.tex"				///
					   , from("`lineToRemove'") to("") replace
			erase	   "$dir/file`fileCount'.tex"
		
			local fileCount = `fileCount' + 1
		}
	
	* Add incipit and end of LaTeX table
	*(to be directly input in TeX document) without further formatting
	cap  file close _all
	file open originalFile											///
		 using "$dir/file`fileCount'.tex"							///
		 , text read		
														
	* Loop over lines of the original TeX file and save everything in a local
	local 	   	  originalFile ""											
	file read  	  originalFile line																	
	while 		  r(eof) == 0 {    
		local 	  originalFile " `originalFile' `line' "
		file read originalFile line
	}
	file close 	  originalFile 

	* Erase original file
	erase "$dir/file`fileCount'.tex"

	* Make final table
	file  open finalFile using "$dir/baltab_ri.tex", text write replace
		
	#d	;
	
		file write finalFile
				"\begin{tabular}{lcccccc} \hline \hline"																				_n
					
					" 		   &   			  & (1)		&  				& (2)		&         & Randomization \\ 		" 				_n
					" 		   &   			  & PES	    &  				& non-PES   & t-test  & inference 	  \\ 		" 				_n
					" Variable & N/[Clusters] & Mean/SE &  N/[Clusters] & Mean/SE   & p-value & p-value  	  \\ \hline " 				_n
					"`originalFile' \hline"																								_n
					"\multicolumn{7}{@{}p{1.2\textwidth}}"																				_n
					"{\textit{Notes}: "
					"We show both standard p-values and p-values computed by randomization inference (RI) with `repsNum' repetitions.}" _n
							
				"\end{tabular}"																											_n
									
		;
	#d	cr
	
	file close finalFile
