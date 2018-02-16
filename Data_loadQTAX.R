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
#                                        ####
#**********************************************************************

file_name <- paste0(dir_dataraw, "/QTAX-mf/QTAX-mf.xlsx")

range_cat_idx <- "A2:D5"
range_dt_idx  <- "A9:D47"
range_geo_idx <- "A51:C103"
range_per_idx <- "A107:B210"

df_cat_idx  <- read_excel(file_name, "QTAX-mf", range_cat_idx)
df_dt_idx   <- read_excel(file_name, "QTAX-mf", range_dt_idx)
df_geo_idx  <- read_excel(file_name, "QTAX-mf", range_geo_idx)
df_per_idx  <- read_excel(file_name, "QTAX-mf", range_per_idx)

range_data  <- "A222:F128752"
range_data1 <- "A222:F99999"
range_data2 <- "A1:F28754"

#df_data    <- read_xlsx(path = file_name, sheet = "QTAX-mf", range = range_data) # error when trying to load more than 100k rows
df_data1    <- read_xlsx(path = file_name, sheet = "QTAX-mf",  range = range_data1)
df_data2    <- read_xlsx(path = file_name, sheet = "QTAX-mf2", range = range_data2)

df_data1 %>% head
df_data2 %>% tail
df_data <- bind_rows(df_data1, df_data2)



df_cat_idx
df_dt_idx
df_geo_idx
df_per_idx

# %in% c(1, 2, 37, 38)

x <- df_data %>% 
	filter(cat_idx == 3, geo_idx == 34,  per_idx %in% 76 ) %>% 
	arrange(dt_idx)
head(x,30)


df_data %>% 
	filter(cat_idx == 1, dt_idx %in% c(1, 2, 37, 38),  per_idx %in% 80 )













