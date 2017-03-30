/******************************This program gets all the relevant datasetsinto a county-year form, with all the variablesthat we want to calculate.********************************/global datadir "/data/working/mobz/replication"global logdir "/programs/projects/mobz2/replication/logfiles"    set more off************************STEP 1: industry employment***********************use "$datadir/cbp_allyears.dta", clearreplace fips = "12025" if fips == "12086" sort fips yeartempfile cbpsave `cbp' , replaceuse "$datadir/industry_data.dta", clearcollapse (sum) emp, by(cty_fips year) tostring cty_fips, gen(fips) forcereplace fips = "0" + fips if length(fips) == 4replace fips = "12025" if fips == "12086"rename emp manuemp_adhkeep fips year manuemp_adh sort fips year tempfile adhempsave `adhemp', replace*********************** STEP 2: census data**********************use "$datadir/popcounts.dta", clearrename county fips replace fips = "12025" if fips == "12086"drop if fips == "30113" | (substr(fips,1,2)=="02" | substr(fips,1,2) == "15" )sort fips yeartempfile populationsave `population', replaceuse "$datadir/censusdata.dta", clearreplace year = 2007 if year > 2000 rename  pop_16_65 population_census_1665replace fips = "12025" if fips == "12086"sort fips yearmerge 1:1 fips year using `population'tab _mergetab year _merge*tab fips if _merge == 2 drop if _merge == 2drop _mergetabstat pop_16_65 population_census_1665, by(year)sort fips yearmerge 1:1 fips year using "$datadir/qcewdata.dta"tab _mergedrop if _merge == 2drop _mergedrop if fips == "30113" | (substr(fips,1,2)=="02" | substr(fips,1,2) == "15" )sort fips yearmerge 1:1 fips year using `cbp'tab _mergetab year _merge drop if _merge == 2 drop _mergesort fips yearmerge 1:1 fips year using `adhemp'tab _mergetab year _merge drop if _merge == 2 drop _mergesort fips yeartempfile cty_censusdatasave  "$datadir/cty_censusdata.dta", replace
