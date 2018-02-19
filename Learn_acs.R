# Learn acs package

#**********************************************************************
#                           Notes                              ####
#**********************************************************************

# Info for acs package
# https://www.r-bloggers.com/acs-version-2-0-an-r-package-to-download-and-analyze-data-from-the-us-census/


#**********************************************************************
#                           Packages                               ####
#**********************************************************************

library(tidyverse)
library(readxl)
library(magrittr)
library(stringr)
library(xts)
library(lubridate)

library(acs)



#**********************************************************************
#                           Global settings                        ####
#**********************************************************************
# Use ACS API key
# From http:	//api.census.gov/data/key_signup.html
api.key.install(key="5435cbc6b6275965ca83cf300a380321a7311de0")



#**********************************************************************
#                   User-specific geographies                      ####
#**********************************************************************

## geo.set object and geo.make function
washington <- geo.make(state = 53)
alabama    <- geo.make(state = "Alab") 
yakima <- geo.make(state = "WA", county = "Yakima")

# geographies:
#		state
#   county
#		county subdivision
#   place
#   tract and/or block.group # FIPS code number

#   * for smallest level of geography specified, use "*" to indicate taht all
#   geographies at that level is specified

# state-county-tract (summary levels 140) or state-place (summary levels 160)   

STATE <- geo.make(state = 1:60, county = "*")

## Groups and combinations

## adding existing geo.sets with "+": creates "flat" geo.set -- no nesting

## Combining geo.sets with "c()": creates nested struture

## change combine and combine term: combine(), combine.term() functions


## geo.lookup


#**********************************************************************
#                   Getting data                                   ####
#**********************************************************************

states <- geo.make(state = row.names(USArrests))

df_state <- acs.fetch(geo = states, variable = c("B25090_001", "B25103_001", "B25103_002", "B25103_003"), endyear = 2016 )
df_state


NY <- geo.make(state = "NY", county = "*" )
df_ny <- acs.fetch(geo = NY, variable = c("B25090_001", "B25103_001"), endyear = 2014 )
df_ny@estimate


NY2 <- geo.make(state = "NY", school.district.unified = c("Shen", "Niskayuna", "Guilderland", "Albany"))
df_ny2 <- acs.fetch(geo = NY2, variable = c("B25103_001"), endyear = 2016 )
df_ny2@geography


str(df_ny2)


#**********************************************************************
#                   Getting state level data                                   ####
#**********************************************************************
acs.lookup(endyear = 2015, keyword = "real estate tax")

states <- geo.make(state = row.names(USArrests))

df_state <- acs.fetch(geo = states, variable = c("B25090_001", "B25103_001"), endyear = 2015 )
df_propertyTax_acs <- 
	df_state@estimate %>% 
	as.data.frame %>% 
	rename(Aggretage_propertyTax = B25090_001,
				 Median_propertyTax    = B25103_001) %>% 
	mutate(state = row.names(.)) %>% 
	select(state, everything()) %>% 
	arrange(desc(Median_propertyTax))

write.xlsx2(df_propertyTax_acs, file = paste0(dir_dataout, "PropertyTax_PrelimTables_ACS.xlsx"))










