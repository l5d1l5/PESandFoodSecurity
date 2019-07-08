	
	* Set directory here
	global 	dir "$EDLREFOR_outFin/"

	
	
	
	* Load dataset
	*use 	"$HFData_dtRaw/Combined/WRS_HFD_RENCONTRE_STOCK_ROSTER_HH_construct.dta", clear

	* Set number of repetitions and seeds
	local  	seedsNum 	123456
	local  	repsNum 	1000

	* Set variables locals
	local 	balVars 	"FoodExp LFoodExp HFIAS_score HFIA_cat_1  HFIA_cat_4 HHS HDDS"				
	local   treatVar	"treatment"
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
					  grplabels(1 Treatment @ 0 Control)
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
		"\begin{table}[h!]" 																											_n
			
			"\caption{Mean Comparison of Food Security Indicators across Treatment Groups}"																									_n
			"\centering"																												_n
			
			"\begin{adjustbox}{max width=\textwidth}"																					_n
	
				"\begin{tabular}{lcccccc} \hline \hline"																				_n
					
					" 		   &   			  & (1)		&  				& (2)		&         & Randomization \\ 		" 				_n
					" 		   &   			  & Control &  				& Treatment & t-test  & inference 	  \\ 		" 				_n
					" Variable & N/[Clusters] & Mean/SE &  N/[Clusters] & Mean/SE   & p-value & p-value  	  \\ \hline " 				_n
					"`originalFile' \hline"																								_n
					"\multicolumn{7}{@{}p{1.2\textwidth}}"																				_n
					"{\textit{Notes}: "
					"We show both standard p-values and p-values computed by randomization inference (RI) with `repsNum' repetitions.}" _n
							
				"\end{tabular}"																											_n
	
			"\end{adjustbox}"																											_n
		 "\end{table}"
									
		;
	#d	cr
	
	file close finalFile
