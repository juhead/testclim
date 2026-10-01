## This script is for reviewing holdridge classifications by island 
install.packages("sf")
install.packages("terra")
install.packages("tidyr")
install.packages("dplyr")
install.packages("exactextractr")
install.packages("macroBiome")

library(sf)
library(terra)
library(dplyr)
library(tidyr)
library(exactextractr)
library(macroBiome)

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

#calculate area covered by the different zones by the island 
island_zones <- exact_extract(hold_class, islands, function(df) {
  df |>
    group_by(value, isle) |>
    summarise(area = sum(coverage_area))
}, coverage_area = TRUE, include_cols = "isle", summarize_df = TRUE)

island_zones <- island_zones %>% mutate(area = area / 1e6)

#get codes from macroBiome
codes <- vegClsNumCodes

lookup <- data.frame(
  ID    = seq_len(nrow(codes)),
  label = codes$Name.HLZ      
)

#assign names of zones to table 
island_zones <- left_join(island_zones, lookup, by = c("value" = "ID"))
