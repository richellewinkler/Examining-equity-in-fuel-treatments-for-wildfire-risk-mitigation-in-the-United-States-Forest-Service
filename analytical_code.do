*** Analytical code for "Examining equity in fuel treatments for wildfire risk mitigation in the United States Forest Service" in Landscape and Urban Planning
* Richelle Winkler, Michigan Technological University, rwinkler@mtu.edu

* Step 1 - Spatial data processing in ArcGIS: Identify census blocks that have had fuel treatments and associate blocks to the National Forests they fall in and around. See GIS processing notes document.

* Step 2 - Data Cleaning and Merging files in Stata. Bring resulting .dbfs into Stata and keep only those observations since 2017. Work with all blocks within 1km of a fuel treatment or within 1 km of national forest land.  
* work with blocks within 1km of a National Forest (universe)
keep GEOID20 GEOIDFQ20 ALAND NFSLANDUNI NFFID NFSLANDU_2 GIS_ACRES REGION
rename GEOID20 GEOID
save "...\nf_blocks2.dta", replace 
* some national forests have multiple different NFFID codes for different pieces of the same forest. Recode these to be consistent.
destring NFFID, gen (n_nffid)
drop if NFFID== "0802"
replace NFFID= "0401" if NFFID=="6028"
replace NFFID= "0424" if NFFID=="6441"
replace NFFID= "0451" if NFFID=="6001"
replace NFFID= "0481" if NFFID=="6013"
replace NFFID= "0058" if NFFID=="0835"
replace NFFID= "0366" if NFFID=="6011"
replace NFFID= "0166" if NFFID=="6016"
replace NFFID= "0166" if NFFID=="0167"
replace NFFID= "0166" if NFFID=="0165"
replace NFFID= "0527" if NFFID=="9900"
replace NFFID= "0516" if NFFID=="0517"
replace NFFID= "0531" if NFFID=="0521"
replace NFFID= "0232" if NFFID=="6010"
replace NFFID= "0232" if NFFID=="0235"
replace NFFID= "0238" if NFFID=="2201"
replace NFFID= "7001" if NFFID=="6035"
replace NFFID= "0171" if NFFID=="6017"
replace NFFID= "0191" if NFFID=="6192"
replace NFFID= "0311" if NFFID=="6027"
replace NFFID= "0217" if NFFID=="6019"
replace NFFID= "0217" if NFFID=="0218"
replace NFFID= "0103" if NFFID=="0567"
replace NFFID= "0102" if NFFID=="0091"
replace NFFID= "0227" if NFFID=="6030"
replace NFFID= "0227" if NFFID=="6025"
replace NFFID= "0526" if NFFID=="0528"
replace NFFID= "0551" if NFFID=="0552"
replace NFFID= "0042" if NFFID=="0552"
replace NFFID= "0131" if NFFID=="6007"
replace NFFID= "0242" if NFFID=="6026"
replace NFFID= "0042" if NFFID=="6044"
replace NFFID= "0217" if NFFID=="6218"
replace NFFID= "0234" if NFFID=="6234"
replace NFFID= "0424" if NFFID=="6424"
replace NFFID= "0186" if NFFID=="6009"
replace NFFID= "0242" if NFFID=="6037"
replace NFFID= "0428" if NFFID=="6060"
replace NFFID= "0428" if NFFID=="0429"
replace NFFID= "0124" if NFFID=="6125"
replace NFFID= "0121" if NFFID=="6127"
replace NFFID= "0121" if NFFID=="6128"
replace NFFID= "0131" if NFFID=="0132"
replace NFFID= "0221" if NFFID=="6222"
replace NFFID= "0221" if NFFID=="6225"
replace NFFID= "0221" if NFFID=="6223"
replace NFFID= "0221" if NFFID=="6224"
replace NFFID= "0052" if NFFID=="6370"
replace NFFID= "0522" if NFFID=="6524"
replace NFFID= "0522" if NFFID=="6525"
replace NFFID= "0522" if NFFID=="6529"
replace NFFID= "0527" if NFFID=="6530"
replace NFFID= "0522" if NFFID=="6533"
replace NFFID= "0526" if NFFID=="6532"
replace NFFID= "0008" if NFFID=="6549"
replace NFFID= "0042" if NFFID=="6550"
replace NFFID= "0081" if NFFID=="6551"
replace NFFID= "0242" if NFFID=="6555"
replace NFFID= "0516" if NFFID=="6517"
replace NFFID= "0068" if NFFID=="0074"
replace NFFID= "0422" if NFFID=="0438"
replace NFFID= "0139" if NFFID=="0158"
replace NFFID= "0261" if NFFID=="0264"
replace NFFID= "0142" if NFFID=="0152"
replace NFFID= "0571" if NFFID=="0574"
replace NFFID= "0252" if NFFID=="0257"
replace NFFID= "0154" if NFFID=="0141"
replace NFFID= "0506" if NFFID=="0507"
replace NFFID= "0434" if NFFID=="0436"
replace NFFID= "0042" if NFFID=="0043"
drop if n_nffid>6999
save "....\nf_blocks_collapsed.dta", replace 

* Import and clean fuel treatment block data
* tag duplicates and collapse into a block level file with one observation per block that notes number of times the block was treated or planned 2017+
rename geoid20 GEOID20
gen GEOID20b= substr(geoidfq,10,15)
duplicates drop GEOID20 fy_planned_or_accomplished, force
count
* there are 131,585 block-year observations after dropping extra treatments in the same block in the same year
sort GEOID20
rename GEOID20 n_GEOID
duplicates tag GEOID20, gen (dup)
count if dup==0
save "....\FuelTreatmentBlocks_time.dta", replace

* Import and clean tribal lands data from Census 2020
rename GEOID20_Block GEOID
rename ur20 urban
keep GEOID geoid state statea county countya AIAN_tot tribal pop2020 p_AIAN urban arealand
rename GEOID n_GEOID
gen GEOID= substr(geoid,10,15)
joinby n_GEOID using "...\FuelTreatmentBlocks_time.dta", unmatched(both)
count
sum _merge
count if _merge==1
count if _merge==2
count if _merge==3
* returns the full set of 8,132,968 records. None were only in using. 131,585 observations in both datasets are the blocks with at least one treatment.
replace dup= 1 if dup!=.
rename dup treated
mvencode treated, mv(0)
drop _merge
save "....\FuelTreatment_Blocks_AIAN_time.dta", replace
* count= 8,202,980
* count if pop2020>0= 5,802,667

* Import and clean wildfire risk, WUI, tenure, and age data from Census 2020
* done elsewhere. Join to fuel treatment block file.
save "...\FuelTreatment_Blocks_workingTime.dta", replace

** Import, clean, and join race/ethnicity data (downloaded from NHGIS)

import delimited "M:\REB\RWinkler\Data_NotRecords\nhgis_blocks_race_dhc2020\nhgis0074_csv\nhgis0074_ds258_2020_block.csv", varnames(1) rowrange(3) clear
* IPUMS NHGIS, University of Minnesota, www.nhgis.org

        Steven Manson, Jonathan Schroeder, David Van Riper, Katherine Knowles, Tracy Kugler, Finn Roberts, and Steven Ruggles.
        IPUMS National Historical Geographic Information System: Version 18.0 
        [dataset]. Minneapolis, MN: IPUMS. 2023.
        http://doi.org/10.18128/D050.V18.0

gen Hisp_pop= u7n009
gen Black_pop= u7n004+u7n011
gen GEOID= substr(geoid,10,15)
gen total_pop= u7n001
keep GEOID Hisp_pop Black_pop total_pop
gen p_Black2= Black_pop/total_pop*100
gen p_Hisp2= Hisp_pop/total_pop*100
sum p_Black2 p_Hisp2
save "...\census2020_race.dta", replace

use "...\FuelTreatment_Blocks_workingTime.dta"
* Note this using file was already joined to forest names and treatments in prior .do file
joinby GEOID using "...\census2020_race.dta", unmatched(both)
save "...\FuelTreatment_Blocks_workingTime.dta", replace

* Join to National Forest shapefile to identify which blocks intersect with which NF, beyond just those with treatments (full universe file). 
use "...\FuelTreatment_Blocks_workingTime.dta", clear
joinby GEOID using "...\nf_blocks_collapsed.dta", unmatched (both) 
sum _merge
count if _merge==1
count if _merge==2
count if _merge==3
* 196,427 block-years that are in/near FS joined, as expected. Most observations are only in master (5,619,488 presumably not in/near NF land). There are 175,315 only in using- these are blocks with no population in/near NF. 
sort _merge
gen treated=1 if fy_planned_or_accomplished !=.
mvencode treated, mv(0)
count if treated>0 & _merge==1
count if treated>0 & _merge==3
* There are 8,986 blocks not matching to near NF but with a fuel treatmet- these are excluded from analysis. There are 59,611 block-years with a fuel treatment and near NF
count if treated==0 & _merge==3
* There are 136,816 blocks that are within 1km of NF but no fuel treatments. 
drop if _merge==2

* prepare variables for analysis
gen p_dens20= pop2020/arealand
gen h_dens20= hu2020/arealand
gen RPS_mean2= RPS_mean*RPS_mean
mvencode WUI_2020, mv(0)
rename treated treatment
destring NFFID, gen (NF_id)
* drop observations that are not in/near a National Forest. These would not be eligible for treatments. 
keep if NF_id !=.
count
* There are 196,427 observations that are in/near a National Forest in universe of analysis
bysort NF_id: sum treatment
* Note there are many NF with no treatment blocks
bysort NF_id: egen nf_treatments= sum(treatment)
duplicates drop 
* dropped 6,849 observations that were duplicates in terms of all variables
drop if fy_planned_or_accomplished<2017
count
* 181,765 observations within 1km of a NF, includes duplicate blocks with multiple treatments since 2017 and with connections to multiple NFs.
count if fy_planned_or_accomplished !=.
* of those 48,423 are treated blocks

duplicates report GEOID NFFID
** still many surplus observations because of the names of forests being different (join issue described above or more than one treatment in the same year in the same block and forest) and because of treatments in multiple years, so...
duplicates drop GEOID NFFID, force
count
* n= 154,467 blocks within 1km of a NF - the final universe. The only duplicates by GEOID that remain now should be blocks that are within 1 km of multiple different NF (n= ~ 3,000 surplus observations this way)
duplicates tag GEOID, gen (DUP)
duplicates report GEOID
* tag observations as DUP that are the same block associated with multiple NFs so can exclude from global analysis
save "...\FuelTreatment_Blocks_analyzeTime10172024.dta", replace

* Create indicators for high shares of Black and Hispanic populations, based on > mean +0.5SD
sum p_Black2 p_Hisp2 p_AIAN p_old p_renter
gen Black=1 if p_Black2>10.6
mvencode Black, mv(0)
gen Hisp=1 if p_Hisp2>22.4
mvencode Hisp, mv(0)
gen old=1 if p60plus>45.7
mvencode old, mv(0)
gen Rent=1 if p_renter>43
mvencode Rent, mv(0)
gen AIAN=1 if p_AIAN>15.2
mvencode AIAN, mv(0)
replace Black=. if p_Black2==.
replace Hisp=. if p_Hisp2==.
replace old=. if p60plus==.
replace Rent=. if p_renter==.
replace AIAN=. if p_AIAN==.

destring REGION, gen (nf_region)
save "...\ANALYZE_10072024.dta", replace

* Step 3: Analysis
************** ANALYSIS BELOW*****************
use "...\ANALYZE_10072024.dta", clear
* Crosstabs j
	table nf_region treatment Black
	table nf_region treatment Hisp
	table nf_region treatment AIAN
	table nf_region treatment tribal
	table nf_region treatment old
	table nf_region treatment Rent
	table nf_region treatment institute

* Global model that includes all populated blocks in 50 states + DC that are within 1km of a National Forest. Comparison is to other blocks within 1 km of any NF. Don't include duplicate blocks in this model. Control for region. Note- no real substantive difference when control for region vs not
melogit treated i.Risk2 i.urbanity p_dens20 tribal old Rent Black Hisp AIAN arealand i.nf_region || NF_id:, or

* Regional spatial regime with a NF random intercept
bysort nf_region: melogit treated i.Risk2 i.urbanity p_dens20 tribal old Rent Black Hisp AIAN arealand || NF_id:, or
