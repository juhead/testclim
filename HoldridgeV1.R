## This script uses the packages terra and macroBiome to classify Hawaii climate 
## zones using legacy and contemporary climate data.  

# install.packages("terra")
# install.packages("macroBiome")
library(terra)
library(macroBiome)

# loading in list of legacy tiffs
temps_12_leg <- list.files("data_raw/legacy_mean_monthly_air_temperature", pattern = "\\.tif$", full.names = TRUE)
precips_12_leg <- list.files("data_raw/legacy_mean_monthly_rainfall", pattern = "\\.tif$", full.names = TRUE)
# stacking monthly tiffs into annual legacy raster stack
temp_leg <- rast(temps_12_leg)
precip_leg <- rast(precips_12_leg) 


# laading in list of contemporary tiffs 
temps_12_con <- list.files("data_raw/contemporary_mean_monthly_air_temperature", pattern = "\\.tif$", full.names = TRUE)
precips_12_con <- list.files("data_raw/contemporary_mean_monthly_rainfall", pattern = "\\.tif$", full.names = TRUE)
# stacking monthly tiffs into annual contemporary raster stack
temp_con <- rast(temps_12_con)
precip_con <- rast(precips_12_con) 


################### data exploration - skip for classification ########

# sanity checks 
nlyr(temp_leg); nlyr(precip_leg); nlyr(temp_con); nlyr(precip_con) # checks number of layers; should be 12
compareGeom(temp_leg, precip_leg) # checks that extent, resolution, and CRS match
compareGeom(temp_con, precip_con)
compareGeom(temp_leg, temp_con)   # same grid across time periods?

global(temp_leg, range, na.rm = TRUE) # temp range in °C 
global(precip_leg, range, na.rm = TRUE) # precip rainge in mm
global(temp_con, range, na.rm = TRUE)
global(precip_con, range, na.rm = TRUE)

#######################################################################

# LEGACY - macroBiome package Holdridge Life Zones function 
result1_leg <- cliHoldridgeGrid(rs.temp = temp_leg, rs.prec = precip_leg)
plot(result1_leg) # result without class labels 

# CONTEMPORARY
result1_con <- cliHoldridgeGrid(rs.temp = temp_con, rs.prec = precip_con)
plot(result1_con) # result without named classes

############# Fixing classification and color-code alignment 

codes  <- vegClsNumCodes
lookup <- data.frame(ID = seq_len(nrow(codes)), label = codes$Name.HLZ)

master_cols <- hcl.colors(nrow(lookup), palette = "Dark 3")
# Neighboring Holdridge classes get near-identical hues in a sequential palette. 
# A fixed shuffle makes adjacent classes easier to tell apart:
set.seed(1); master_cols <- sample(master_cols)

# Helper that classifies, labels, and applies the master colors
make_hlz <- function(result) {
  f <- as.factor(result)
  levels(f) <- lookup
  coltab(f) <- data.frame(value = lookup$ID, col = master_cols)  
  f
}

classified_leg  <- make_hlz(result1_leg)      
classified_con <- make_hlz(result1_con)  

plot(classified_leg,
     plg = list(cex = 0.6, bg = "white", ncol = 2),
     mar = c(3, 3, 1, 14))

plot(classified_con,
     plg = list(cex = 0.6, bg = "white", ncol = 2),
     mar = c(3, 3, 1, 14))

   save_hlz_plot <- function(r, file) {
  png(file,
      width = 10, height = 5.625,   # inches, 16:9 (matches a 13.33 x 7.5 in slide when scaled)
      units = "in", res = 300,
      bg = "white")
  plot(r,
       plg = list(cex = 0.9, bg = "white"),  # bigger legend text for slides
       mar = c(3, 3, 1, 14),
       cex.axis = 1.1)
  dev.off()
}

save_hlz_plot(classified_leg,  "holdridge_legacy_map.png")
save_hlz_plot(classified_con, "holdridge_contemporary_map.png")