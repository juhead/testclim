#####################################################################
#This script is for converting Holdridge classifications to Audebert level 1 
#####################################################################

########################### LOAD PACKAGES ########################
library(terra)

########################### LOAD DATA  ########################
#legacy and contemporary filepaths 
contemp <- c(
  contemp_hold = file.path("output_data", "contemporary_holdridge_hawaii.tiff")
)
#scenario names
scenarios <- expand.grid(
  period = c("mid", "end"),
  ssp    = c("126", "245", "370", "585"),
  stringsAsFactors = FALSE
)
#scenario filepaths 
scenario_paths <- setNames(
  file.path("output_data", sprintf("holdridge_%s_SSP%s.tif",
                                   scenarios$period, scenarios$ssp)),
  sprintf("%s_ssp%s_hold", scenarios$period, scenarios$ssp)
)
#all inputs 
inputs <- c(contemp, scenario_paths)
#import holdridge classification and audebert reclassification table
audebertlvl1 <- read.csv("data_raw/audebert_reclass.csv")
#convert audbebert level 1 matrix 
lvl1_class <- as.matrix(audebertlvl1)

########################### RECLASSIFY AND EXPORT  ########################
#reclassify and write
for (nm in names(inputs)) {
  r <- rast(inputs[[nm]])
  r_lvl1 <- classify(r, lvl1_class)
  writeRaster(
    r_lvl1,
    file.path("output_data/", paste0(nm, "_lvl1.tiff")),
    datatype = "INT1U", NAflag = 255, overwrite = TRUE
  )
}

