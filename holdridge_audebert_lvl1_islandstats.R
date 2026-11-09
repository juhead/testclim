## This script is for calculating area by Holdridge Audebert level 1 classifications for each island
install.packages("sf")
install.packages("terra")
install.packages("dplyr")
install.packages("exactextractr")
install.packages("tidyterra")

library(sf)
library(terra)
library(dplyr)
library(exactextractr)
library(purrr)

########################### LOADING DATA ########################
#import holdridge classification 
hist_hold <- rast("output_data/holdridge_audebert_lvl1_class/hist_hold_lvl1.tiff")
contemp_hold <- rast("output_data/holdridge_audebert_lvl1_class/contemp_hold_lvl1.tiff")

#import island boundaries 
islands <- read_sf("data_raw/hawaii_coastline_WGS84_shp/coastline_hawaii_WGS84.shp")


########################### CHECK CRS ########################
#check the coordinate reference systems for both 
crs(hist_hold, describe = TRUE)
crs(contemp_hold, describe = TRUE)
st_crs(islands)

########################### AREA CALCUALTION ########################
#area calculation zones historical 
hist_hold_islands <- exact_extract(
  hist_hold, islands,
  function(df) {
    df |>
      filter(!is.na(value)) |>
      group_by(value, Name, area_sq_km) |>
      summarise(area_hist = (sum(coverage_area) / 1e6), .groups = "drop") |>
      mutate(pct_island_hist = 100 * (area_hist  / area_sq_km))
  },
  coverage_area = TRUE,
  include_cols = c("Name", "area_sq_km"),
  summarize_df = TRUE
)

#area calculation zones contemporary 
contemp_hold_islands <- exact_extract(
  contemp_hold, islands,
  function(df) {
    df |>
      filter(!is.na(value)) |>
      group_by(value, Name, area_sq_km) |>
      summarise(area_contemp = (sum(coverage_area) / 1e6), .groups = "drop") |>
      mutate(pct_island_contemp = 100 * (area_contemp  / area_sq_km))
  },
  coverage_area = TRUE,
  include_cols = c("Name", "area_sq_km"),
  summarize_df = TRUE
)

########################### ZONE NAMES ########################
#add in lookup table for audebert level 1 classifcation 
audebert_lvl1_lookup <- read.csv("output_data/holdridge_audebert_lvl1_class/holdridge_audebert_lvl1_lookup.csv")

#assign names of zones to table 
hist_hold_islands <- left_join(hist_hold_islands, audebert_lvl1_lookup, 
                               by = c("value" = "LVL1_ID"))
contemp_hold_islands <- left_join(contemp_hold_islands, audebert_lvl1_lookup, 
                                  by = c("value" = "LVL1_ID"))

########################### COMBINE AND COMPARE ########################
#join together contemporary and historical tables 
hold_islands <- full_join(hist_hold_islands, contemp_hold_islands, by 
                          = c("value", "Name", "area_sq_km", "Label"))
hold_islands <- hold_islands %>% 
  mutate(across(c(area_hist, area_contemp, pct_island_hist, pct_island_contemp), 
                ~ replace_na(.x, 0)))

#difference (contemporary - legacy)
hold_islands <- hold_islands %>% 
  mutate("diff(contemp-legacy)" = pct_island_contemp - pct_island_hist)

#change type 
hold_islands <- hold_islands %>%
  mutate(change_type = case_when(
    `diff(contemp-legacy)` < 0 ~ "LOSS",
    `diff(contemp-legacy)` > 0 ~ "GAIN",
    `diff(contemp-legacy)` == 0 ~ "NO CHANGE"
  ))

########################### EXPORT TO CSV ########################
write.csv(hold_islands, "output_data/holdridge_lvl1_island_breakdown.csv", 
          row.names = FALSE)
