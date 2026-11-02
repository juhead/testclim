## This script is for reviewing holdridge classifications by island 
install.packages("sf")
install.packages("terra")
install.packages("tidyr")
install.packages("dplyr")
install.packages("exactextractr")
install.packages("macroBiome")
install.packages("ggplot2")
install.packages("tidyterra")
install.packages("purrr")
install.packages("paletteer")

library(sf)
library(terra)
library(dplyr)
library(tidyr)
library(exactextractr)
library(macroBiome)
library(ggplot2)
library(tidyterra)
library(purrr)
library(paletteer)

########################### LOADING DATA ########################
#import holdridge classification 
hist_hold <- rast("output_data/historical_holdridge_hawaii.tiff")
contemp_hold <- rast("output_data/contemporary_holdridge_hawaii.tiff")

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
#get codes from macroBiome
codes <- vegClsNumCodes

lookup <- data.frame(
  ID    = seq_len(nrow(codes)),
  label = codes$Name.HLZ      
)

#assign names of zones to table 
hist_hold_islands <- left_join(hist_hold_islands, lookup, by = c("value" = "ID"))
contemp_hold_islands <- left_join(contemp_hold_islands, lookup, by = c("value" = "ID"))

########################### COMBINE AND COMPARE ########################
#join together contemporary and historical tables 
hold_islands <- full_join(hist_hold_islands, contemp_hold_islands, by 
                          = c("value", "Name", "area_sq_km", "label"))
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
write.csv(hold_islands, "output_data/holdridge_island_breakdown.csv", 
          row.names = FALSE)







