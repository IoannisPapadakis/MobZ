%macro geoagglodes(year,inlib=OUTPUTS,outlib=OUTPUTS); 

/* First you need to aggregate New England MCDs up to county */
/* Also, assign independent cities to a county  */

proc contents data = &inlib..flows_lodes_&year. ;
run ;

proc sort data = &inlib..flows_lodes_&year. out =flows;
	by home_cty work_cty ; 
run ; 

/* MK: added nway and restricted to states and dc */
proc summary data = flows (where=(not missing(home_cty) and not missing(work_cty))) nway;
	class home_cty work_cty ; 
	var jobsflow ;
	output out = flows (keep=home_cty work_cty jobs) sum(jobsflow) = jobs ;
run; 

	data flows ; 
		set flows (where=(substr(home_cty,1,2) <= '56' 
				and substr(work_cty,1,2) <= '56'));
	run ;		
 
/* Calculating residence labor force */		

	proc summary data = flows  nway;
		class home_cty ; 
		var jobs ;
		output out = &outlib..reslf_lodes_&year. (keep=home_cty reslf) sum(jobs) = reslf ;
	run ; 
	



	proc sort data = &outlib..reslf_lodes_&year. out = reslf ;
		by home_cty ; 
	run ;

/* Now merging it all together */



data ctyflowssorted (keep = h_cty w_cty jobs) ;
	set flows  ; 
	h_cty = work_cty ; 
	w_cty = home_cty ;
run ;

proc sort data = ctyflowssorted (rename=(w_cty = work_cty h_cty = home_cty jobs = w_h_jobflows)) ;
	by home_cty work_cty ; 
run ;

proc sort data = flows out=flows_sort ; 
	by home_cty work_cty ;
run ;

data ctypairs (keep= home_cty work_cty w_h_jobflows h_w_jobflows) ;
	merge ctyflowssorted flows_sort (rename =(jobs=h_w_jobflows)); 	
	by home_cty work_cty ; 
run ; 

data ctypairs (keep= home_cty work_cty w_h_jobflows h_w_jobflows reslf_h) ;
	merge ctypairs reslf (rename=(reslf=reslf_h)) ;
	by home_cty ; 
run ; 

proc sort data = ctypairs ;
 	by work_cty ;
run ; 

data &outlib..ctypairs_lodes_&year. (keep=home_cty work_cty w_h_jobflows h_w_jobflows reslf_h reslf_w p_ij ) ;
	merge ctypairs reslf (rename=(home_cty=work_cty reslf=reslf_w)) ;
	by work_cty ; 
	if h_w_jobflows = . then h_w_jobflows = 0 ; 
	if w_h_jobflows = . then w_h_jobflows = 0 ; 
	
	denominator = min(reslf_h , reslf_w) ;
	p_ij = (h_w_jobflows + w_h_jobflows)/denominator ; 
	if p_ij > 1 then p_ij = 0.999 ;
	if work_cty = home_cty then p_ij = 1 ;
	
	if home_cty ne '' and work_cty ne '' ;
run ;
/*
proc freq data = &outlib..ctypairs_lodes_&year. ;
	table home_cty/missing ; 
run ; 
*/	

proc means data = &outlib..ctypairs_lodes_&year. N NMISS MEAN STD P1 P5 P50 P95 P99 MAX	;
	title "Summary of association at county level" ; 
	var p_ij reslf_h reslf_w ; 
run ; 

/*When iterating, these all combine to take up a lot of memory */
proc datasets ; 
	delete ctypairs reslf ctyflowssorted flows_lodes_&year. flows;
run; 



%mend geoagglodes ;
