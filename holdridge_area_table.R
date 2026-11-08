#load required packages 
install.packages("tidyverse")
install.packages("readxl")
install.packages("dplyr")

library(tidyverse)
library(readxl)
library(dplyr)

#read in files 
statewide <- read_excel("output_data/holdridge_lvl1_stats.xlsx", sheet = 1)
oahu <- read_excel("output_data/holdridge_lvl1_stats.xlsx", sheet = 2)
molokai <- read_excel("output_data/holdridge_lvl1_stats.xlsx", sheet = 3)
maui <- read_excel("output_data/holdridge_lvl1_stats.xlsx", sheet = 4)
lanai <- read_excel("output_data/holdridge_lvl1_stats.xlsx", sheet = 5)
kauai <- read_excel("output_data/holdridge_lvl1_stats.xlsx", sheet = 6)
hawaii <- read_excel("output_data/holdridge_lvl1_stats.xlsx", sheet = 7)

#rounding values
statewide <- statewide %>% mutate(across(where(is.numeric), round, digits = 2))
oahu <- oahu %>% mutate(across(where(is.numeric), round, digits = 2))
molokai <- molokai %>% mutate(across(where(is.numeric), round, digits = 2))
maui <- maui %>% mutate(across(where(is.numeric), round, digits = 2))
lanai <- lanai %>% mutate(across(where(is.numeric), round, digits = 2))
kauai <- kauai %>% mutate(across(where(is.numeric), round, digits = 2))
hawaii <- hawaii %>% mutate(across(where(is.numeric), round, digits = 2))

#writing function 
format_stats <- function(polygon, column) {
  polygon %>% 
    mutate({{ column }} := paste0(area_contemp, " (", pct_contemp, ")")) %>% 
    select(Label, {{ column }})
}

format_stats_islands <- function(polygon, column) {
  polygon %>% 
    mutate({{ column }} := paste0(area_contemp, " (", pct_island_contemp, ")")) %>% 
    select(Label, {{ column }})
}

# flow 
statewide <- format_stats(polygon = statewide, column = "Statewide")
kauai <- format_stats_islands(polygon = kauai, column = "Kaua'i")
oahu <- format_stats_islands(polygon = oahu, column = "O'ahu")
molokai <- format_stats_islands(polygon = molokai, column = "Moloka'i")
maui <- format_stats_islands(polygon = maui, column = "Maui")
lanai <- format_stats_islands(polygon = lanai, column = "Lana'i")
hawaii <- format_stats_islands(polygon = hawaii, column = "Hawai'i")

# export
all_columns <- list(statewide, kauai, oahu, molokai, maui, lanai, hawaii)

t1 <- all_columns %>% 
  reduce(left_join, by = "Label")

write.csv(t1, "output_data/table2_area_results_holdridge", row.names = FALSE)
