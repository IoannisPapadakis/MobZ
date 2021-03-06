%include(/ssgprojects/project0002/Mobz/programs/config.sas) ;

    * Mobility Zones (MobZ);
* Execute control program to run selected modules;	
options  mlogic symbolgen spool;
* Modules, set to 1 to run, otherwise 0;	

/*************************************
FURTHER ANALYSIS
            
module_graph runs the %review for jtw1990, over
a wide             
**************************************/    
%let run_cutoff = 0 ; 
%let run_graph = 0;
%let run_graph_regions = 0;               

%let run_cutoff_objfn = 0 ; 
/* PERTURB IS ONE RUN OF THE MACRO %PERTURB */            
%let run_perturbjtw2009 = 0 ;

/**********************************
  BOOTSTRAP_STATISTICS PERTURBS THE FLOWS 
          AND REDOES CLUSTERING AND REVIEW 
***********************************/            
%let run_bootstrap_statistics =0   ; 

             
/* CALCULATING OBJECTIVE FUNCTION*/
%let run_objfn = 0;
%let run_objfnfc = 0;             
            
%let run_clustersum=0;
%let run_comstat=0 ;
    
%let run_spectralboot = 1;

%let run_divergence =10;    
/*********************************
    SETTING MACROS FOR RUNS
********************************/        

* Cluster threshold;
%let cutoff=0.9418 ; /*national cutoff for their way*/
    
* Cutoffs ;
    %let cutoff_bottom = 0.8 ;
    %let cutoff_top = 1.0 ;
    %let ci90 = 1.645 ;
    
* Paths;
%let dirprog=&root.;
%let dirdata=&root.;
libname OUTPUTS "&dirdata./data";
libname GEO "&dirdata./data" ;
options sasautos="&dirprog./programs/macros" mautosource nocenter ps=1000;

%global tstamp;
%let t=%sysfunc(today());
%let tt=%sysfunc(time());
%let dstamp=%trim(%sysfunc(year(&t.),z4.))%trim(%sysfunc(month(&t.),z2.))%trim(%sysfunc(day(&t.),z2.));
%let tstamp=&dstamp._%trim(%sysfunc(hour(&tt.),z2.))%trim(%sysfunc(minute(&tt.),z2.))%trim(%sysfunc(second(&tt.),z2.));

/* Overall Macro */
%macro runall;

* Modules;
%macro runmod(val,modname);
%put module &modname.;
%if (&val.=1) %then %do;
proc printto
    log="&dirprog./programs/modules/20.analysis/module_&modname..log" new
    print="&dirprog./programs/modules/20.analysis/module_&modname..lst" new;
run;
%include "&dirprog./programs/modules/20.analysis/module_&modname..sas";	

%end;
%mend runmod;

* Create one for each module;

%runmod(&run_graph.,graph);
%runmod(&run_graph_regions.,graph_regions);

%runmod(&run_perturbjtw2009., perturbjtw2009) ;

%runmod(&run_bootstrap_statistics., bootstrap) ;

%runmod(&run_objfn.,objfn) ;
%runmod(&run_objfnfc.,objfnfc) ;
    
%runmod(&run_cutoff.,cutoff) ;
%runmod(&run_clustersum.,clustersum) ;
%runmod(&run_comstat.,comstat) ;    

%runmod(&run_spectralboot.,spectralboot) ;
%runmod(&run_divergence.,divergence) ;

%runmod(&run_cutoff_objfn.,cutoff_objfn) ;
%mend runall;
* run all;
%runall;
