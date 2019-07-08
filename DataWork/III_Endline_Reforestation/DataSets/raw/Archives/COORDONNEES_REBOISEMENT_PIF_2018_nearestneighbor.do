**************************************************************************
******** This code is to select observations that will need photo ********
**************************************************************************


import delimited using /Volumes/AlexisPC/GeoProjects/BurkinaFaso/BF_collector/distances/COORDONNEES_REBOISEMENT_PIF_2018_nearestneighbor.csv

* Check whether is statistically significant the median, min and max between parcels


preserve
collapse (median) dist, by(bloc parcelle)
orth_out dist, by(parcelle)
restore

preserve
collapse (max) dist, by(bloc parcelle)
orth_out dist, by(parcelle)
restore

preserve
collapse (min) dist, by(bloc parcelle)
orth_out dist, by(parcelle)
restore

orth_out dist, by(parcelle) test count

***** no significant

***** Code to generate dummies on those observations with distances above each threshold

gen dist1m = 1 if dist>=1
gen dist2m = 1 if dist>=2
gen dist3m = 1 if dist>=3
gen dist4m = 1 if dist>=4
gen dist5m = 1 if dist>=5
gen dist6m = 1 if dist>=6
gen dist7m = 1 if dist>=7
gen dist8m = 1 if dist>=8
gen dist9m = 1 if dist>=9
gen dist10m = 1 if dist>=10

*** Calculate the share of observations with distances greater than the threshold

collapse (count) dist1m dist2m dist3m dist4m dist5m dist6m dist7m dist8m dist9m dist10m objectid, by(bloc parcelle)

gen dist1m_share = dist1m/objectid*100
gen dist2m_share = dist2m/objectid*100
gen dist3m_share = dist3m/objectid*100
gen dist4m_share = dist4m/objectid*100
gen dist5m_share = dist5m/objectid*100
gen dist6m_share = dist6m/objectid*100
gen dist7m_share = dist7m/objectid*100
gen dist8m_share = dist8m/objectid*100
gen dist9m_share = dist9m/objectid*100
gen dist10m_share = dist10m/objectid*100



*** Find duplicated observations

gsort bloc parcelle -dist
gen dist_dup = 1 if dist == dist[_n-1]


*** Generate dummies for the top third observations with largest distance between others

gsort bloc parcelle -dist
egen count = count(objectid), by (bloc parcelle)
bysort bloc parcelle: gen seq = _n
gen top_third = 1 if seq< (count/3)

list bloc parcelle dist if count==count[_n+1] & top_third != top_third[_n+1] 

preserve

keep if count==count[_n+1] & top_third != top_third[_n+1]

restore

preserve

collapse (count) top_third, by(bloc parcelle)

restore

*** Generate dummies for the top half observations with largest distance between others


gen top_half = 1 if seq< (count/2)

list bloc parcelle dist if count==count[_n+1] & top_half != top_half[_n+1] 

preserve

keep if count==count[_n+1] & top_half != top_half[_n+1]

restore

preserve

collapse (count) top_half, by(bloc parcelle)

restore


