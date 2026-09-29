## This script is for reviewing holdridge classifications by island 
install.packages("sf")
install.packages("terra")
install.packages("tidyr")
install.packages("dplyr")
install.packages("exactextractr")
install.packages("geospatialsuite")

library(sf)
library(terra)
library(dplyr)
library(tidyr)
library(exactextractr)
library(geospatialsuite)

#import holdridge classification created for hawaii created previously 
hold_class <- rast("output_data/historical_holdridge_hawaii.tiff")

# creating a discrete color palette 
n <- nrow(cats(hold_class)[[1]])
cols <- hcl.colors(n, palette = "Dark 3")

#plot holdridge zones for the islands 
plot(hold_class,
     col    = cols,
     plg    = list(cex = 0.6, bg = "white"), 
     mar    = c(3, 3, 1, 1))

#import island boundaries 
islands <- read_sf("data_raw/Coastline.geojson")

#check the coordinate reference systems for both 
crs(hold_class, describe = TRUE)
st_crs(islands)

#currently both are in WGS 84 might change later 
island_data <- universal_spatial_join(
  source_data = islands,
  target_data = hold_class,
  method = "auto",
  verbose = TRUE
)

Kauai <- islands %>% filter(isle == "Kauai")

kauai_hold <- crop(hold_class, Kauai, mask = TRUE)

plot(kauai_hold,
     col    = cols,
     plg    = list(cex = 0.6, bg = "white"), 
     mar    = c(3, 3, 1, 1))
