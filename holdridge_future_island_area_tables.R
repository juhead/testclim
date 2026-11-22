#this is a script to create a table of holdridge future projections by island area for paper
#load required packages 
library(tidyverse)
library(readxl)
library(dplyr)

########################### LOADING DATA ########################
#read in files 
oahu <- read_excel("output_data/holdridge_future_area_by_island.xlsx", sheet = 1)
molokai <- read_excel("output_data/holdridge_future_area_by_island.xlsx", sheet = 2)
maui <- read_excel("output_data/holdridge_future_area_by_island.xlsx", sheet = 3)
lanai <- read_excel("output_data/holdridge_future_area_by_island.xlsx", sheet = 4)
kauai <- read_excel("output_data/holdridge_future_area_by_island.xlsx", sheet = 5)
hawaii <- read_excel("output_data/holdridge_future_area_by_island.xlsx", sheet = 6)
#rounding values
oahu <- oahu %>% mutate(across(where(is.numeric), round, digits = 2))
molokai <- molokai %>% mutate(across(where(is.numeric), round, digits = 2))
maui <- maui %>% mutate(across(where(is.numeric), round, digits = 2))
lanai <- lanai %>% mutate(across(where(is.numeric), round, digits = 2))
kauai <- kauai %>% mutate(across(where(is.numeric), round, digits = 2))
hawaii <- hawaii %>% mutate(across(where(is.numeric), round, digits = 2))

########################### TABLE CONVERSION ########################
#writing function 
format_stats_islands <- function(polygon, midssp125, midssp245, midssp370, 
                                 midssp585, endssp126, endssp245, endssp370, 
                                 endssp585) {
  polygon %>% 
    mutate({{ midssp125 }} := paste0(area_mid_ssp126, " (", pct_mid_ssp126, ")")) %>% 
    mutate({{ midssp245 }} := paste0(area_mid_ssp245, " (", pct_mid_ssp245, ")")) %>%
    mutate({{ midssp370 }} := paste0(area_mid_ssp370, " (", pct_mid_ssp370, ")")) %>%
    mutate({{ midssp585 }} := paste0(area_mid_ssp585, " (", pct_mid_ssp585, ")")) %>%
    mutate({{ endssp126 }} := paste0(area_end_ssp126, " (", pct_end_ssp126, ")")) %>%
    mutate({{ endssp245 }} := paste0(area_end_ssp245, " (", pct_end_ssp245, ")")) %>%
    mutate({{ endssp370 }} := paste0(area_end_ssp370, " (", pct_end_ssp370, ")")) %>%
    mutate({{ endssp585 }} := paste0(area_end_ssp585, " (", pct_end_ssp585, ")")) %>%
    select(Label, {{ midssp125 }}, {{ midssp245 }}, {{ midssp370 }}, {{ midssp585 }},
           {{ endssp126 }}, {{ endssp245 }}, {{ endssp370 }}, {{ endssp585 }})
}

oahu <- format_stats_islands(polygon = oahu, midssp125 = "SSP1-2.5 Mid-Century", 
                              midssp245 = "SSP2-4.5 Mid-Century", 
                              midssp370 = "SSP3-7.0 Mid-Century", 
                              midssp585 = "SSP5-8.5 Mid-Century",
                              endssp126 = "SSP1-2.5 End-of-Century",
                              endssp245 = "SSP2-4.5 End-of-Century",
                              endssp370 = "SSP3-7.0 End-of-Century",
                              endssp585 = "SSP5-8.5 End-of-Century")
molokai <- format_stats_islands(polygon = molokai, midssp125 = "SSP1-2.5 Mid-Century", 
                             midssp245 = "SSP2-4.5 Mid-Century", 
                             midssp370 = "SSP3-7.0 Mid-Century", 
                             midssp585 = "SSP5-8.5 Mid-Century",
                             endssp126 = "SSP1-2.5 End-of-Century",
                             endssp245 = "SSP2-4.5 End-of-Century",
                             endssp370 = "SSP3-7.0 End-of-Century",
                             endssp585 = "SSP5-8.5 End-of-Century")
maui <- format_stats_islands(polygon = maui, midssp125 = "SSP1-2.5 Mid-Century", 
                             midssp245 = "SSP2-4.5 Mid-Century", 
                             midssp370 = "SSP3-7.0 Mid-Century", 
                             midssp585 = "SSP5-8.5 Mid-Century",
                             endssp126 = "SSP1-2.5 End-of-Century",
                             endssp245 = "SSP2-4.5 End-of-Century",
                             endssp370 = "SSP3-7.0 End-of-Century",
                             endssp585 = "SSP5-8.5 End-of-Century")
lanai <- format_stats_islands(polygon = lanai, midssp125 = "SSP1-2.5 Mid-Century", 
                             midssp245 = "SSP2-4.5 Mid-Century", 
                             midssp370 = "SSP3-7.0 Mid-Century", 
                             midssp585 = "SSP5-8.5 Mid-Century",
                             endssp126 = "SSP1-2.5 End-of-Century",
                             endssp245 = "SSP2-4.5 End-of-Century",
                             endssp370 = "SSP3-7.0 End-of-Century",
                             endssp585 = "SSP5-8.5 End-of-Century")
kauai <- format_stats_islands(polygon = kauai, midssp125 = "SSP1-2.5 Mid-Century", 
                             midssp245 = "SSP2-4.5 Mid-Century", 
                             midssp370 = "SSP3-7.0 Mid-Century", 
                             midssp585 = "SSP5-8.5 Mid-Century",
                             endssp126 = "SSP1-2.5 End-of-Century",
                             endssp245 = "SSP2-4.5 End-of-Century",
                             endssp370 = "SSP3-7.0 End-of-Century",
                             endssp585 = "SSP5-8.5 End-of-Century")
hawaii <- format_stats_islands(polygon = hawaii, midssp125 = "SSP1-2.5 Mid-Century", 
                             midssp245 = "SSP2-4.5 Mid-Century", 
                             midssp370 = "SSP3-7.0 Mid-Century", 
                             midssp585 = "SSP5-8.5 Mid-Century",
                             endssp126 = "SSP1-2.5 End-of-Century",
                             endssp245 = "SSP2-4.5 End-of-Century",
                             endssp370 = "SSP3-7.0 End-of-Century",
                             endssp585 = "SSP5-8.5 End-of-Century")

########################### EXPORTING ########################
write.csv(oahu, "output_data/oahu_future_area_results.csv", row.names = FALSE)
write.csv(molokai, "output_data/molokai_future_area_results.csv", row.names = FALSE)
write.csv(maui, "output_data/maui_future_area_results.csv", row.names = FALSE)
write.csv(lanai, "output_data/lanai_future_area_results.csv", row.names = FALSE)
write.csv(kauai, "output_data/kauai_future_area_results.csv", row.names = FALSE)
write.csv(hawaii, "output_data/hawaii_future_area_results.csv", row.names = FALSE)
