## This script is for downloading and exploring packages and importing tifs

install.packages("terra")
install.packages("macroBiome")

library(terra)
library(macroBiome)

# LEGACY DATA USED HERE
temp_leg <- list.files("data_raw/legacy_mean_monthly_air_temperature", pattern = "\\.tif$", full.names = TRUE)
precip_leg <- list.files("data_raw/legacy_mean_monthly_rainfall", pattern = "\\.tif$", full.names = TRUE)

temp <- rast(temp_leg)
precip <- rast(precip_leg)

# sanity checks 
nlyr(temp) # checks number of layers
nlyr(precip) # checks number of layers
compareGeom(temp, precip) # checks that extent, resolution, and CRS
global(temp, range, na.rm = TRUE) # temp range in °C 
global(precip, range, na.rm = TRUE) # precip rainge in mm

# No biotemperature clipping needed; raw values within 0-30°C range

# Plotting the monthly avgs - just to vizualize 
plot(temp[[1]], range = c(0, 26), main = "Jan")
plot(temp[[2]], range = c(0, 26), main = "Feb")
plot(temp[[3]], range = c(0, 26), main = "Mar")
plot(temp[[4]], range = c(0, 26), main = "Apr")
plot(temp[[5]], range = c(0, 26), main = "May")
plot(temp[[6]], range = c(0, 26), main = "Jun")
plot(temp[[7]], range = c(0, 26), main = "Jul")
plot(temp[[8]], range = c(0, 26), main = "Aug")
plot(temp[[9]], range = c(0, 26), main = "Sep")
plot(temp[[10]], range = c(0, 26), main = "Oct")
plot(temp[[11]], range = c(0, 26), main = "Nov")
plot(temp[[12]], range = c(0, 26), main = "Dec")

plot(precip[[1]], range = c(0, 1000), main = "Jan")
plot(precip[[2]], range = c(0, 1000), main = "Feb")
plot(precip[[3]], range = c(0, 1000), main = "Mar")
plot(precip[[4]], range = c(0, 1000), main = "Apr")
plot(precip[[5]], range = c(0, 1000), main = "May")
plot(precip[[6]], range = c(0, 1000), main = "Jun")
plot(precip[[7]], range = c(0, 1000), main = "Jul")
plot(precip[[8]], range = c(0, 1000), main = "Aug")
plot(precip[[9]], range = c(0, 1000), main = "Sep")
plot(precip[[10]], range = c(0, 1000), main = "Oct")
plot(precip[[11]], range = c(0, 1000), main = "Nov")
plot(precip[[12]], range = c(0, 1000), main = "Dec")

# testing out macroBiome package function 
result1 <- cliHoldridgeGrid(rs.temp = temp, rs.prec = precip)
plot(result1)

# Dataframe within the package with the labels and number codes
codes <- vegClsNumCodes
# simplifying codes to a lookup table
lookup <- data.frame(
  ID    = seq_len(nrow(codes)),
  label = codes$Name.HLZ      
)

# making the original output categorical and setting the labels 
classified <- as.factor(result1)
levels(classified) <- lookup

# creating a discrete color palette 
n <- nrow(cats(classified)[[1]])
cols <- hcl.colors(n, palette = "Dark 3")

# Plotting the improved result 
plot(classified,
     col    = cols,
     plg    = list(cex = 0.6, bg = "white"), 
     mar    = c(3, 3, 1, 1))



#export holdridge classifications for Hawaii
#writeRaster(classified, "historical_holdridge_hawaii.tiff")
#output_data folder was created after and it was moved 
