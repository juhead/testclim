## This script is for reviewing holdridge classifications by climate division 
install.packages("sf")
install.packages("terra")
install.packages("tidyr")
install.packages("dplyr")
install.packages("exactextractr")
install.packages("macroBiome")
install.packages("tidyterra")
install.packages("purrr")
install.packages("units")

library(sf)
library(terra)
library(dplyr)
library(tidyr)
library(exactextractr)
library(macroBiome)
library(tidyterra)
library(purrr)
library(units)

########################### LOADING DATA ########################
#import holdridge classification 
#hist_hold <- rast("output_data/historical_holdridge_hawaii.tiff")
contemp_hold <- rast("output_data/contemporary_holdridge_hawaii.tiff")

#important hawaii climate divisions 
hi_clim_divs <- read_sf("data_raw/Hawaii_Climate_Divs/Hawaii_Climate_Divs.shp")

########################### CHECK CRS ########################
#check the coordinate reference systems for both 
#crs(hist_hold, describe = TRUE)
crs(contemp_hold, describe = TRUE)
st_crs(hi_clim_divs)

###################### AREA CALCULATION  ############################
#area calculation zones contemporary 
contemp_hold_clim_divs <- exact_extract(
  contemp_hold, hi_clim_divs,
  function(df) {
    df |>
      filter(!is.na(value)) |>
      group_by(value, Id, area_sqkm) |>
      summarise(area_contemp = (sum(coverage_area) / 1e6), .groups = "drop") |>
      mutate(pct_clim_div = 100 * (area_contemp  / area_sqkm))
  },
  coverage_area = TRUE,
  include_cols = c("Id", "area_sqkm"),
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
contemp_hold_clim_divs <- left_join(contemp_hold_clim_divs, lookup, 
                                    by = c("value" = "ID"))

########################### EXPORT TO CSV ########################
write.csv(contemp_hold_clim_divs, "output_data/contemp_hold_climate_divs.csv", 
          row.names = FALSE)



