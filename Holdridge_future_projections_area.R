## This script is for calculating area by Holdridge Audebert level 1 for future projections 
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

############################ LOADING DATA ########################
#import mid century projections 
mid_ssp126 <- rast("output_data/holdridge_audebert_lvl1_class/mid_ssp126_hold_lvl1.tiff")
mid_ssp245 <- rast("output_data/holdridge_audebert_lvl1_class/mid_ssp245_hold_lvl1.tiff")
mid_ssp370 <- rast("output_data/holdridge_audebert_lvl1_class/mid_ssp370_hold_lvl1.tiff")
mid_ssp585 <- rast("output_data/holdridge_audebert_lvl1_class/mid_ssp585_hold_lvl1.tiff")

#import end century projections 
end_ssp126 <- rast("output_data/holdridge_audebert_lvl1_class/end_ssp126_hold_lvl1.tiff")
end_ssp245 <- rast("output_data/holdridge_audebert_lvl1_class/end_ssp245_hold_lvl1.tiff")
end_ssp370 <- rast("output_data/holdridge_audebert_lvl1_class/end_ssp370_hold_lvl1.tiff")
end_ssp585 <- rast("output_data/holdridge_audebert_lvl1_class/end_ssp585_hold_lvl1.tiff")

#import hawaii state shapefile
hi_statebounds <- read_sf("data_raw/hawaii_statebounds_WGS84_shp/hawaii_statebounds.shp")

#rotate projections
#mid century
mid_ssp126 <- terra::rotate(mid_ssp126) 
mid_ssp245 <- terra::rotate(mid_ssp245)
mid_ssp370 <- terra::rotate(mid_ssp370)
mid_ssp585 <- terra::rotate(mid_ssp585)

#end of century
end_ssp126 <- terra::rotate(end_ssp126)
end_ssp245 <- terra::rotate(end_ssp245)
end_ssp370 <- terra::rotate(end_ssp370)
end_ssp585 <- terra::rotate(end_ssp585)

########################### AREA CALCUALTION ########################
#creating function to calculate area 
state_area <- function(r, polys, scenario = NA_character_,
                                area_col = "area_sq_km") {
  
  exact_extract(r, polys, coverage_area = TRUE)[[1]] |>
    filter(!is.na(value)) |>
    group_by(value) |>
    summarise(area_km2 = sum(coverage_area) / 1e6, .groups = "drop") |>
    mutate(
      scenario  = scenario,
      pct_state = 100 * area_km2 / polys[[area_col]][1],
      .before   = 1
    )
}

#calculate area for mid century predictions 
mid_ssp126_area <- state_area(mid_ssp126, hi_statebounds, "mid_ssp126")
mid_ssp245_area <- state_area(mid_ssp245, hi_statebounds, "mid_ssp245")
mid_ssp370_area <- state_area(mid_ssp370, hi_statebounds, "mid_ssp370")
mid_ssp585_area <- state_area(mid_ssp585, hi_statebounds, "mid_ssp585")

#calculate area for end of century predictions
end_ssp126_area <- state_area(end_ssp126, hi_statebounds, "end_ssp126")
end_ssp245_area <- state_area(end_ssp245, hi_statebounds, "end_ssp245")
end_ssp370_area <- state_area(end_ssp370, hi_statebounds, "end_ssp370")
end_ssp585_area <- state_area(end_ssp585, hi_statebounds, "end_ssp585")

########################### COMBINE DATA ########################
#dataframe for mid century all ssps 
mid_century <- bind_rows(mid_ssp126_area, mid_ssp245_area, mid_ssp370_area, 
                         mid_ssp585_area)

#dataframe for end of century all ssps 
end_century <- bind_rows(end_ssp126_area, end_ssp245_area, end_ssp370_area, 
                         end_ssp585_area)


########################### ZONE NAMES ########################
#add in lookup table for audebert level 1 classifcation 
audebert_lvl1_lookup <- read.csv(
  "output_data/holdridge_audebert_lvl1_class/holdridge_audebert_lvl1_lookup.csv")

#join class names with mid and end century tables 
mid_century <- left_join(mid_century, audebert_lvl1_lookup, 
                                     by = c("value" = "LVL1_ID"))
end_century <- left_join(end_century, audebert_lvl1_lookup, 
                         by = c("value" = "LVL1_ID"))

########################### EXPORT TO CSV ########################
write.csv(mid_century, "output_data/holdridge_mid_century.csv", 
          row.names = FALSE)
write.csv(end_century, "output_data/holdridge_end_century.csv", 
          row.names = FALSE)
