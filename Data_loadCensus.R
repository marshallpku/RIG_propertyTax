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

library(acs)



#**********************************************************************
#                           Global settings                        ####
#**********************************************************************
dir_dataraw <- "Data_raw/"



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


# Variables needed:

# Line:
# 7: general revenue from own sources
# 8: Taxes
#  9: Property
#  11: general sales
#  18: individual income



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


#**********************************************************************
#                  US population estimate                          ####
#**********************************************************************

fileName_schoolFin <- paste0(dir_dataraw, "CensusSchoolFin/elsec15_sttables.xls")
range_page1 <- "A5:L71"

df_schoolFin_p1 <- 
	read_excel(fileName_schoolFin, "1", range_page1, col_names = FALSE)






