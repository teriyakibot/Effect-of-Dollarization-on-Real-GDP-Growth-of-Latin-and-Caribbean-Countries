// clean up and setup//
capture clear
capture log close
set more off




//set path to working directory//
cd "/Users/shuhuisun/Downloads/ECON501/Project"
log using ols_data_cleaning_20240415.log, text replace


use "/Users/shuhuisun/Downloads/ECON501/Project/dollarization - Data - 20240415.dta"


 

//data cleaning//
describe 


rename politicalstabilityandabsenceofvi political_stability
rename exportsofgoodsandservicesconstan  export_value
rename exportsofgoodsandservicesannualg  export_growth
rename gdppercapitagrowthannualnygdppca  gdp_pc_growth
rename realeffectiveexchangerateindex20  exchange_rate
rename agricultureforestryandfishingval  structure_agri
rename generalgovernmentfinalconsumptio govt_exp
rename manufacturingvalueaddedofgdpnvin structure_manu
rename servicesvalueaddedofgdpnvsrvtotl structure_service
rename householdsandnpishsfinalconsumpt consumption
rename exportsofgoodsandservicesofgdpne export_percent
rename netforeignassetscurrentlcufmastn foreign_asset
rename gdppercapitaconstant2015usnygdpp gdp_pc
rename gdpconstant2015usnygdpmktpkd     gdp
rename personalremittancesreceivedofgdp remittance
rename foreigndirectinvestmentnetinflow fdi
rename grosscapitalformationofgdpnegdit investment
rename agriculturalrawmaterialsexportso expo_agri
rename fuelexportsofmerchandiseexportst expo_fuel
rename foodexportsofmerchandiseexportst expo_food

drop var24
drop var27
drop merchandiseexportsbythereporting

drop if time==1990


rename grosssavingsofgdpnygnsictrzs      saving
rename netdomesticcreditcurrentlcufmast  domestic_credit
drop gdpgrowthannualnygdpmktpkdzg


destring time saving political_stability export_value export_growth exchange_rate structure_agri govt_exp structure_manu structure_service consumption export_percent foreign_asset domestic_credit gdp_pc_growth gdp_pc gdp remittance fdi investment expo_agri expo_fuel expo_food, replace force


describe 

summarize


gen dollarization = foreign_asset / domestic_credit

gen t = time-2000

*gen lggdp = log(gdp)

**ols
reg gdp_pc_growth dollarization govt_exp investment consumption export_percent
outreg2 using ols_classical_20240415, excel dec(3) replace

reg gdp_pc_growth dollarization govt_exp investment consumption export_percent t
outreg2 using ols_classical_20240415, excel dec(3) 

reg gdp_pc_growth dollarization govt_exp investment consumption export_percent t saving structure_agri structure_manu structure_service 
outreg2 using ols_sa_20240415, excel dec(3) replace


reg gdp_pc_growth dollarization govt_exp investment consumption export_percent t saving structure_agri structure_manu structure_service expo_agri expo_fuel expo_food
outreg2 using ols_sa_20240415, excel dec(3) 


reg gdp_pc_growth dollarization govt_exp investment consumption export_percent t saving structure_agri structure_manu structure_service expo_agri expo_fuel expo_food political_stability export_growth exchange_rate remittance fdi
outreg2 using ols_sa_20240415, excel dec(3) 

/*
drop if gdp_pc_growth==. | dollarization==. | govt_exp==. | investment==. | consumption==. | export_percent==. | t==. | saving==. | structure_agri==. | structure_manu==. | structure_service==. | expo_agri==. | expo_fuel==. | expo_food==. | political_stability==. | export_growth==. | exchange_rate==. | remittance==. | fdi==.

summarize

export delimited using model_obs.csv, replace
*/



*modeled half of the variation. the other half may be hard to quantify and record including political leadership, intervention of internaitonal institutions, or global financial incidents


**interaction
**economic structure

reg gdp_pc_growth dollarization govt_exp investment consumption export_percent t saving structure_agri structure_manu structure_service expo_agri expo_fuel expo_food political_stability export_growth exchange_rate remittance fdi
outreg2 using ols_interaction_20240415, excel dec(3)  replace

gen agri_dollar = structure_agri*dollarization
gen manu_dollar = structure_manu*dollarization
gen service_dollar = structure_service*dollarization
reg gdp_pc_growth dollarization govt_exp investment consumption export_percent t saving structure_agri structure_manu structure_service expo_agri expo_fuel expo_food political_stability export_growth exchange_rate remittance fdi agri_dollar manu_dollar service_dollar
outreg2 using ols_interaction_20240415, excel dec(3) 

**export composition
gen eagri_dollar = expo_agri*dollarization
gen fuel_dollar = expo_fuel*dollarization
gen food_dollar = expo_food*dollarization
reg gdp_pc_growth dollarization govt_exp investment consumption export_percent t saving structure_agri structure_manu structure_service expo_agri expo_fuel expo_food political_stability export_growth exchange_rate remittance fdi eagri_dollar fuel_dollar food_dollar
outreg2 using ols_interaction_20240415, excel dec(3)  

*found sig syn effect with food export


**panel and fixed effect
xtset t
xtreg gdp_pc_growth dollarization govt_exp investment consumption export_percent saving structure_agri structure_manu structure_service expo_agri expo_fuel expo_food political_stability export_growth exchange_rate remittance fdi, fe
outreg2 using ols_fe_20240415, excel dec(3)  replace

xi:reg gdp_pc_growth dollarization t i.countrycode govt_exp investment consumption export_percent saving structure_agri structure_manu structure_service expo_agri expo_fuel expo_food political_stability export_growth exchange_rate remittance fdi
outreg2 using ols_dummycountry_20240415, excel dec(3)  replace


**secondary Ys
reg export_growth dollarization govt_exp investment consumption t saving structure_agri structure_manu structure_service expo_agri expo_fuel expo_food political_stability  exchange_rate remittance fdi
outreg2 using ols_secondary_20240415, excel dec(3)  replace


reg political_stability dollarization govt_exp investment consumption export_percent t saving structure_agri structure_manu structure_service expo_agri expo_fuel expo_food  export_growth exchange_rate remittance fdi
outreg2 using ols_secondary_20240415, excel dec(3)

reg exchange_rate dollarization govt_exp investment consumption export_percent t saving structure_agri structure_manu structure_service expo_agri expo_fuel expo_food political_stability export_growth remittance fdi
outreg2 using ols_secondary_20240415, excel dec(3)



cap log close
