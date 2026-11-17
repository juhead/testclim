#this is a script to create a table of holdridge area by climate division for paper
#load required packages 
install.packages("tidyverse")
install.packages("readxl")
install.packages("dplyr")

library(tidyverse)
library(readxl)
library(dplyr)


########################### LOADING DATA ########################
#read in files 
climdiv12 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 1)
climdiv11 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 2)
climdiv10 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 3)
climdiv9 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 4)
climdiv8 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 5)
climdiv7 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 6)
climdiv6 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 7)
climdiv5 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 8)
climdiv4 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 9)
climdiv3 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 10)
climdiv2 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 11)
climdiv1 <- read_excel(
  "output_data/contemporary_climate_division_holdridge_classes.xlsx", sheet = 12)

#rounding values
climdiv12 <- climdiv12 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv11 <- climdiv11 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv10 <- climdiv10 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv9 <- climdiv9 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv8 <- climdiv8 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv7 <- climdiv7 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv6 <- climdiv6 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv5 <- climdiv5 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv4 <- climdiv4 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv3 <- climdiv3 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv2 <- climdiv2 %>% mutate(across(where(is.numeric), round, digits = 2))
climdiv1 <- climdiv1 %>% mutate(across(where(is.numeric), round, digits = 2))

########################### TABLE CONVERSION ########################
format_stats <- function(polygon, column) {
  polygon %>% 
    mutate({{ column }} := paste0(area_contemp, " (", pct_clim_div, ")")) %>% 
    select(Label, {{ column }})
}

#format stats
climdiv12 <- format_stats(polygon = climdiv12, column = "Climate Division 12")
climdiv11 <- format_stats(polygon = climdiv11, column = "Climate Division 11")
climdiv10 <- format_stats(polygon = climdiv10, column = "Climate Division 10")
climdiv9 <- format_stats(polygon = climdiv9, column = "Climate Division 9")
climdiv8 <- format_stats(polygon = climdiv8, column = "Climate Division 8")
climdiv7 <- format_stats(polygon = climdiv7, column = "Climate Division 7")
climdiv6 <- format_stats(polygon = climdiv6, column = "Climate Division 6")
climdiv5 <- format_stats(polygon = climdiv5, column = "Climate Division 5")
climdiv4 <- format_stats(polygon = climdiv4, column = "Climate Division 4")
climdiv3 <- format_stats(polygon = climdiv3, column = "Climate Division 3")
climdiv2 <- format_stats(polygon = climdiv2, column = "Climate Division 2")
climdiv1 <- format_stats(polygon = climdiv1, column = "Climate Division 1")

########################### EXPORTING ########################
#list of all climate divisions 
all_columns <- list(climdiv1, climdiv2, climdiv3, climdiv4, climdiv5, climdiv6,
                    climdiv7, climdiv8, climdiv9, climdiv10, climdiv11, climdiv12)

#join together by holdridge climate class
climate_div_hold_areas <- all_columns %>% 
  reduce(full_join, by = "Label")

#export csv 
write.csv(climate_div_hold_areas, 
          "output_data/climate_divisons_holdridge_area.csv", row.names = FALSE)
