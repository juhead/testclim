## This script is for reviewing holdridge classifications by island 
#adding packages used for this script
install.packages("sf")
install.packages("terra")
install.packages("tidyr")
install.packages("dplyr")
install.packages("exactextractr")
install.packages("macroBiome")
install.packages("ggplot2")

library(sf)
library(terra)
library(dplyr)
library(tidyr)
library(exactextractr)
library(macroBiome)
library(ggplot2)

#import holdridge classification created for hawaii created previously 
hold_class_hist <- rast("output_data/historical_holdridge_hawaii.tiff")
hold_class_contem <- rast("output_data/contemporary_holdridge_hawaii.tiff")

#adding in islands shapefile data 
islands<- read_sf("data_raw/hawaii_coastline_shp/coast_hawaii.shp")

#check the coordinate reference systems for both 
crs(hold_class_hist, describe = TRUE)
crs(hold_class_contem, describe = TRUE)
st_crs(islands)

#reprojecting hold_class to NAD83
hist_hold_reproj <- project(hold_class_hist, "EPSG:4269", method = "near")
contem_hold_reproj <- project(hold_class_contem, "EPSG:4269", method = "near")
crs(hist_hold_reproj, describe = TRUE)

#summarized historical classifications by island 
hist_hold_islands <- exact_extract(
  hist_hold_reproj, islands,
  function(df) {
    df |>
      filter(!is.na(value)) |>
      group_by(value, Name, Area_sq_km) |>
      summarise(area_hist = (sum(coverage_area) / 1e6), .groups = "drop") |>
      mutate(pct_island_hist = 100 * (area_hist  / Area_sq_km))
  },
  coverage_area = TRUE,
  include_cols = c("Name", "Area_sq_km"),
  summarize_df = TRUE
)

#get codes from macroBiome
codes <- vegClsNumCodes

lookup <- data.frame(
  ID    = seq_len(nrow(codes)),
  label = codes$Name.HLZ      
)

#assign names of zones to table 
hist_hold_islands <- left_join(hist_hold_islands, lookup, by = c("value" = "ID"))

#summarize contemporary island classifications by island 
contemp_hold_islands <- exact_extract(
  contem_hold_reproj, islands,
  function(df) {
    df |>
      filter(!is.na(value)) |>
      group_by(value, Name, Area_sq_km) |>
      summarise(area_contemp = (sum(coverage_area) / 1e6), .groups = "drop") |>
      mutate(pct_island_contemp = 100 * (area_contemp / Area_sq_km))
  },
  coverage_area = TRUE,
  include_cols = c("Name", "Area_sq_km"),
  summarize_df = TRUE
)

#assign names of zones to table 
contemp_hold_islands <- left_join(contemp_hold_islands, lookup, by = c("value" = "ID"))

#join together contemporary and historical tables 
hold_islands <- full_join(hist_hold_islands, contemp_hold_islands, by 
                          = c("value", "Name", "Area_sq_km", "label"))

hold_islands <- hold_islands %>%
  mutate(across(.cols = everything(), .fns = function(x) ifelse(is.na(x), 0, x)))
