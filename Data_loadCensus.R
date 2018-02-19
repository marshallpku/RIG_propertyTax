# Load QTAX data

#**********************************************************************
#                           Notes                              ####
#**********************************************************************

# Data obtained from

# US Census Bureau, Annual state and local government finance data
# https://www.census.gov//govs/local/index.html
# Files: State R & Local Summary Tables by Level of Government (in two files)

# U.S. Census Bureau, Annual Population Estimates.
# https://www.census.gov/programs-surveys/popest/data/data-sets.html
# File: Annual Estimates of the Resident Population for the United States, Regions, States, 
#       and Puerto Rico: April 1, 2010 to July 1, 2017 (NST-EST2017-01) 

# US Census Bureau, Annual Survey of School System Finances Tables
# https://www.census.gov/programs-surveys/school-finances/data/tables.html
# Files: Public Elementary-Secondary Education Finance Data - State-Level Tables


#**********************************************************************
#                           Packages                               ####
#**********************************************************************

library(tidyverse)
library(readxl)
library(magrittr)
library(stringr)
library(xts)
library(lubridate)

library(readxl)
library(xlsx)

library(readr)

library(acs)

# check pakcage r2excel: edits excel, based on xlsx


#**********************************************************************
#                           Global settings                        ####
#**********************************************************************
dir_dataraw <- "Data_raw/"
dir_dataout <- "Data_out/"



#**********************************************************************
#                  State and Local Government Finance              ####
#**********************************************************************
fileName_SLGF2015a <- paste0(dir_dataraw, "/CensusSLGF/15slsstab1a.xlsx")
fileName_SLGF2015b <- paste0(dir_dataraw, "/CensusSLGF/15slsstab1b.xlsx")

range_SLGF2015a <- "A15:EB189"
range_SLGF2015b <- "A15:EB189"

fn_index <- function(...){
	#x <- read_xlsx(fileName_SLGF2015a, "2015_US_MS", "A10:EB15", col_names = FALSE) %>% 
	read_xlsx(...) %>% 	
		t %>% 
		as.data.frame %>% 
		filter(!is.na(V5)) %>% 
		unite(Description_govVar, V2, V3, V4, sep = " ") %>% 
		rename(state = V1,
					 govVar_short = V5,
					 govVar_long  = V6) %>% 
		mutate(state = na.locf(state, na.rm = FALSE)) 
	
}

df_SLGF2015a <- left_join(
	read_xlsx(fileName_SLGF2015a, "2015_US_MS", range_SLGF2015a) %>% filter(!is.na(Line)) %>% 
		gather(govVar_long, value, -Line, -Description),
	fn_index(fileName_SLGF2015a, "2015_US_MS", "A10:EB15", col_names = FALSE)
)
	
df_SLGF2015b <- left_join(
	read_xlsx(fileName_SLGF2015b, "2015_MO_WY", range_SLGF2015b) %>% filter(!is.na(Line)) %>% 
		gather(govVar_long, value, -Line, -Description),
	fn_index(fileName_SLGF2015b, "2015_MO_WY", "A10:EB15", col_names = FALSE)
)

df_SLGF2015 <- bind_rows(df_SLGF2015a, df_SLGF2015b)
df_SLGF2015


# Variables needed:

# Line:
vars_SLGF = c(7,  # general revenue from own sources
              8,  # Taxes
              9,  # Property
              11, # general sales
              18  #individual income
)

df_SLGF2015_select <- 
	df_SLGF2015 %>% 
	filter(Line %in% vars_SLGF)


#**********************************************************************
#                  US population estimate                          ####
#**********************************************************************

fileName_population <- paste0(dir_dataraw, "CensusPopulation/nst-est2017-01.xlsx")
range_population <- "A4:K60"

df_population <- 
	read_xlsx(fileName_population, "NST01", range_population) %>% 
	rename(EstiamtesBase2010 = `Estimates Base`,
				 Census2010 = Census,
				 state = X__1) %>% 
	mutate(state = str_replace(state, "\\W", ""))

df_population


#**********************************************************************
#                  US school finance####
#**********************************************************************

fileName_schoolFin <- paste0(dir_dataraw, "CensusSchoolFin/elsec15_sttables.xls")
range_page1 <- "A8:L71"
range_page4 <- "A7:K70"

df_schoolFin_p1 <- 
	read_excel(fileName_schoolFin, "1", range_page1) %>%  # Total revenue
  select(-X__2) %>% 
	filter(!is.na(X__1))

varNames_schoolFin_p1 <- c("state", 
													 "revenue_total",
													 "revenue_federal",
													 "revenue_state",
													 "revenue_local",
													 "expen_total",
													 "expen_current",
													 "expen_capital",
													 "expen_other",
													 "debt_outstanding",
													 "cashSecurity")
names(df_schoolFin_p1) <- varNames_schoolFin_p1
df_schoolFin_p1 %<>% 
	mutate(state = str_replace(state, "\\.+", "")) %>% 
	mutate_at(vars(-state), funs(as.numeric))



df_schoolFin_p4 <- 
	read_excel(fileName_schoolFin, "4", range_page4, col_names = FALSE) %>%  # Local revenue
	select(-X__2) %>% 
	filter(!is.na(X__1))

varNames_schoolFin_p4 <- c("state",
													 "revenue_local_total",
													 "propertyTax",
													 "otherTax",
													 "parentGov",
													 "nonSchoolLocal",
													 "schoolLunchChg",
													 "tuitionChg",
													 "otherChg",
													 "otherLocalRev"
													 )
names(df_schoolFin_p4) <- varNames_schoolFin_p4
df_schoolFin_p4 %<>% 
	mutate(state = str_replace(state, "\\.+", "")) %>% 
	mutate_at(vars(-state), funs(as.numeric))

df_schoolFin_p1
df_schoolFin_p4

#**********************************************************************
#                  Preliminary tables                              ####
#**********************************************************************

## Property taxes as share of total local taxes, FY2015

tbl_1 <- 
df_SLGF2015 %>% 
	filter(govVar_short == 4, Line %in% c(8,9)) %>%
	select(state, Description, value) %>% 
	spread(Description, value) %>% 
	mutate(Property_pct = 100 * Property / Taxes) %>% 
	arrange(desc(Property_pct))
tbl_1


## Total property tax and per capita property tax
tbl_2 <- 
left_join(
		df_SLGF2015 %>% 
			filter(govVar_short == 4, Line %in% c(9)) %>%
			select(state, Description, value) %>% 
			spread(Description, value) %>% 
			mutate(state = ifelse(state == "United States Total", "US", state)),
		
		df_population %>% 
			select(state, `2015`) %>% 
			mutate(state = ifelse(state == "UnitedStates", "US", state))
) %>%
	rename(pop2015 = `2015`) %>% 
	mutate(Property_perCapita = 1000* Property / pop2015) %>% 
	arrange(desc(Property_perCapita))


## Distribution of Public K012 School Revenue 2015

tbl_3 <- 
left_join(
    df_schoolFin_p1 %>%  
    	select(state, revenue_total, revenue_federal, revenue_state, revenue_local),
    df_schoolFin_p4 %>% 
    	select(state, propertyTax) 
) %>% 
	mutate(federal_pct  = 100 * revenue_federal / revenue_total,
				 state_pct    = 100 * revenue_state / revenue_total,
				 local_pct    = 100 * revenue_local / revenue_total,
				 property_pct = 100 * propertyTax / revenue_total
				 ) %>% 
	arrange(desc(property_pct))
tbl_3

#**********************************************************************
#                  Preliminary tables                              ####
#**********************************************************************

write.xlsx2(tbl_1, file = paste0(dir_dataout, "PropertyTax_PrelimTables_Census.xlsx"), sheetName = "PctLocal")
write.xlsx2(tbl_2, file = paste0(dir_dataout, "PropertyTax_PrelimTables_Census.xlsx"), sheetName = "total&perCapita", append = TRUE)
write.xlsx2(tbl_3, file = paste0(dir_dataout, "PropertyTax_PrelimTables_Census.xlsx"), sheetName = "schoolFinance", append = TRUE)







