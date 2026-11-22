#####################################################################
## This script uses the packages terra and macroBiome to calculate HLZs area by 
## island for future climate projections (8 mulit-model ensemble climate 
## projections: 4 SSP scenarios to 2 different projection dates (mid-century and
## end-of-centruy)) 
#####################################################################

########################### LOAD PACKAGES ########################
library(sf)
library(terra)
library(dplyr)
library(exactextractr)
library(tidyverse)
library(writexl)

########################### LOAD DATA  ########################
#scenario filepaths
scenarios <- list.files(path = "output_data/holdridge_audebert_lvl1_class", 
                        pattern = "mid|end", full.names = TRUE)
#creating raster layers 
scenario_stack <- rast(scenarios)
scenario_stack <- terra::rotate(scenario_stack)
#naming layers in raster stack 
names(scenario_stack) <- tools::file_path_sans_ext(basename(scenarios))
scenario_names <- names(scenario_stack)
scenario_names <- as.list(scenario_names)
#import island boundaries 
islands <- read_sf("data_raw/hawaii_coastline_WGS84_shp/coastline_hawaii_WGS84.shp")

########################### AREA CALCUALTION ########################
#summarize by zone area function 
summarize_island_area_future <- function(data, summary, suffix) {
  out <- exact_extract(
    data, summary,
    function(df) {
      df |>
        filter(!is.na(value)) |>
        group_by(Name, area_sq_km, value) |>
        summarise(area = sum(coverage_area) / 1e6, .groups = "drop") |>
        mutate(pct_zone = 100 * area / area_sq_km)
    },
    coverage_area = TRUE,
    include_cols  = c("Name", "area_sq_km"),
    summarize_df  = TRUE,
    progress      = FALSE
  )
  
  out |>
    rename(
           !!paste0("area_", suffix) := area,
           !!paste0("pct_",  suffix) := pct_zone)}
summarize_state_area <- function(data, state, suffix) {
  out <- exact_extract( 
    data, state,
    coverage_area = TRUE
  )[[1]] |>
    filter(!is.na(value)) |>
    group_by(value) |>
    summarise(area = sum(coverage_area) / 1e6, .groups = "drop") |>
    mutate(
      area_sq_km = hawaii$area_sq_km,
      pct_state  = 100 * area / area_sq_km
    ) |>
    select(value, area, pct_state)
  
  rename(out,
         "area_{suffix}" := area,
         "pct_state_{suffix}" := pct_state)}
#creating list to store area
areas_list <- as.list(rep(NA, 8))
names(areas_list) <- paste(scenario_names, "area_islands", sep = "_")
#end ssp126
areas_list$end_ssp126_hold_lvl1_area_islands <- 
  as.data.frame(summarize_island_area_future(
  scenario_stack$end_ssp126_hold_lvl1, islands, "end_ssp126"))
#end ssp245
areas_list$end_ssp245_hold_lvl1_area_islands <- 
  as.data.frame(summarize_island_area_future(
  scenario_stack$end_ssp245_hold_lvl1, islands, "end_ssp245"))
#end ssp370
areas_list$end_ssp370_hold_lvl1_area_islands <- 
  as.data.frame(summarize_island_area_future(
    scenario_stack$end_ssp370_hold_lvl1, islands, "end_ssp370"))
#end ssp585
areas_list$end_ssp585_hold_lvl1_area_islands <-
  as.data.frame(summarize_island_area_future(
  scenario_stack$end_ssp585_hold_lvl1, islands, "end_ssp585"))
#mid ssp126
areas_list$mid_ssp126_hold_lvl1_area_islands <- 
  as.data.frame(summarize_island_area_future(
  scenario_stack$mid_ssp126_hold_lvl1, islands, "mid_ssp126"))
#mid ssp245
areas_list$mid_ssp245_hold_lvl1_area_islands <- 
  as.data.frame(summarize_island_area_future(
    scenario_stack$mid_ssp245_hold_lvl1, islands, "mid_ssp245"))
#mid ssp370
areas_list$mid_ssp370_hold_lvl1_area_islands <- 
  as.data.frame(summarize_island_area_future(
    scenario_stack$mid_ssp370_hold_lvl1, islands, "mid_ssp370"))
#mid ssp585
areas_list$mid_ssp585_hold_lvl1_area_islands <- 
  as.data.frame(summarize_island_area_future(
    scenario_stack$mid_ssp585_hold_lvl1, islands, "mid_ssp585"))

########################### ZONE NAMES ########################
#add in lookup table for audebert level 1 classifcation 
audebert_lvl1_lookup <- read.csv(
  "output_data/holdridge_audebert_lvl1_class/holdridge_audebert_lvl1_lookup.csv")

for(n in seq_along(areas_list)){
  areas_list[[n]] <- left_join(areas_list[[n]], audebert_lvl1_lookup, 
                            by = c("value" = "LVL1_ID"))
}
########################### COMBINE AND EXPORT DATA ########################
hold_future_islands <- areas_list %>%
  reduce(full_join, by = c("value", "Name", "area_sq_km", "Label"))

write.csv(hold_future_islands, "output_data/hold_future_islands_area.csv")


