#####################################################################
## This script calculates area by Holdridge climate classification for the whole 
## state, each island, and the state climate divisions for contemporary data. 
#####################################################################

########################### LOAD PACKAGES ########################
library(sf)
library(terra)
library(dplyr)
library(exactextractr)
library(purrr)

########################### LOADING DATA ########################
#import contemporary holdridge classification
contemp_hold <- rast("output_data/holdridge_contemporary.tif")
#important hawaii climate divisions 
hi_clim_divs <- read_sf("data_raw/Hawaii_Climate_Divs/Hawaii_Climate_Divs.shp")
#import island boundaries 
islands <- read_sf("data_raw/hawaii_coastline_WGS84_shp/coastline_hawaii_WGS84.shp")
#import state boundaries 
hawaii <- read_sf("data_raw/hawaii_statebounds_WGS84_shp/hawaii_statebounds.shp")
#import holdridge lookup table 
hold_lookup <- read_csv("output_data/holdridge_lookup.csv")
########################### AREA CALCUALTION ########################
#summarize by zone area function 
summarize_zone_area <- function(data, summary, name, area_sqkm, suffix) {
  summary$zone_name <- name
  summary$zone_area <- area_sqkm
  
  out <- exact_extract(
    data, summary,
    function(df) {
      df |>
        filter(!is.na(value)) |>
        group_by(zone_name, zone_area, value) |>
        summarise(area = sum(coverage_area) / 1e6, .groups = "drop") |>
        mutate(pct_zone = 100 * area / zone_area)
    },
    coverage_area = TRUE,
    include_cols  = c("zone_name", "zone_area"),
    summarize_df  = TRUE,
    progress      = FALSE
  )
  
  out |>
    rename(Name = zone_name,
           area_sq_km = zone_area,
           !!paste0("area_", suffix) := area,
           !!paste0("pct_",  suffix) := pct_zone)}
# Summarize state area function
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
#area calculation island zones contemporary
contemp_hold_islands <- summarize_zone_area(contemp_hold, islands, islands$Name, 
                                            islands$area_sq_km, "contemp")
#area calculation climate divisions contemporary
contemp_hold_clim_divs <- summarize_zone_area(contemp_hold, hi_clim_divs, 
                                              hi_clim_divs$Id, 
                                              hi_clim_divs$area_sqkm, "contemp")
#area calculation statewide 
contemp_hold_state <- summarize_state_area(contemp_hold, hawaii, "contemp")

########################### ZONE NAMES ########################
#island zones 
contemp_hold_islands <- left_join(contemp_hold_islands, hold_lookup, by = c("value" = "ID"))
#climate division zones
contemp_hold_clim_divs <- left_join(contemp_hold_clim_divs, hold_lookup, by = c("value" = "ID"))
#statewide
contemp_hold_state <- left_join(contemp_hold_state, hold_lookup, by = c("value" = "ID"))

########################### EXPORT TO CSV ########################
#exporting contemporary holdridge island zone area
write.csv(contemp_hold_islands, "output_data/contemp_hold_island_area.csv", 
          row.names = FALSE)
#exporting contemporary holdridge climate division zone area 
write.csv(contemp_hold_state, "output_data/contemp_hold_state_area_NEW.csv", 
          row.names = FALSE)
