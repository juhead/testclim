## script for calculating area by Holdridge Audebert level 1 classifications for the state
install.packages("sf")
install.packages("terra")
install.packages("tidyr")
install.packages("dplyr")
install.packages("exactextractr")
install.packages("tidyterra")

library(sf)
library(terra)
library(dplyr)
library(tidyr)
library(exactextractr)
library(tidyterra)

########################### LOADING DATA ########################
#import holdridge classification 
hist_hold <- rast("output_data/holdridge_audebert_lvl1_class/hist_hold_lvl1.tiff")
contemp_hold <- rast("output_data/holdridge_audebert_lvl1_class/contemp_hold_lvl1.tiff")

#import island boundaries 
hawaii <- read_sf("data_raw/hawaii_statebounds_WGS84_shp/hawaii_statebounds.shp")

########################### CHECK CRS ########################
#check the coordinate reference systems for both 
crs(hist_hold, describe = TRUE)
crs(contemp_hold, describe = TRUE)
st_crs(hawaii)

########################### AREA CALCUALTION ########################
#area calculation zones historical 
hist_hold_state <- exact_extract(
  hist_hold, hawaii,
  coverage_area = TRUE
)[[1]] |>
  filter(!is.na(value)) |>
  group_by(value) |>
  summarise(area_hist = sum(coverage_area) / 1e6, .groups = "drop") |>
  mutate(
    area_sq_km = hawaii$area_sq_km,
    pct_hist   = 100 * area_hist / area_sq_km
  ) |>
  select(value, area_hist, pct_hist)

#area calculation zones contemporary 
contemp_hold_state <- exact_extract(
  contemp_hold, hawaii,
  coverage_area = TRUE
)[[1]] |>
  filter(!is.na(value)) |>
  group_by(value) |>
  summarise(area_contemp = sum(coverage_area) / 1e6, .groups = "drop") |>
  mutate(
    area_sq_km = hawaii$area_sq_km,
    pct_contemp   = 100 * area_contemp / area_sq_km
  ) |>
  select(value, area_contemp, pct_contemp)

########################### ZONE NAMES ########################
#add in lookup table for audebert level 1 classifcation 
audebert_lvl1_lookup <- read.csv("output_data/holdridge_audebert_lvl1_class/holdridge_audebert_lvl1_lookup.csv")

#assign names of zones to table 
hist_hold_state <- left_join(hist_hold_state, audebert_lvl1_lookup, 
                               by = c("value" = "LVL1_ID"))
contemp_hold_state <- left_join(contemp_hold_state, audebert_lvl1_lookup, 
                                  by = c("value" = "LVL1_ID"))

########################### COMBINE AND COMPARE ########################
#join together contemporary and historical tables 
holdridge_state <- full_join(hist_hold_state, contemp_hold_state, by 
                          = c("value", "Label"))

holdridge_state <- holdridge_state %>% 
  mutate(across(c(area_hist, area_contemp, pct_hist, pct_contemp), 
                ~ replace_na(.x, 0)))

#difference (contemporary - legacy)
holdridge_state <- holdridge_state %>% 
  mutate("diff(contemp-legacy)" = pct_contemp - pct_hist)

#change type 
holdridge_state <- holdridge_state %>%
  mutate(change_type = case_when(
    `diff(contemp-legacy)` < 0 ~ "LOSS",
    `diff(contemp-legacy)` > 0 ~ "GAIN",
    `diff(contemp-legacy)` == 0 ~ "NO CHANGE"
  ))

########################### EXPORT TO CSV ########################
write.csv(holdridge_state, "output_data/holdridge_state_wide.csv", 
          row.names = FALSE)
