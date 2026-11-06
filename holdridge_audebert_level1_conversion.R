## This script is for converting holdridge classifications to audebert level 1
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
#import holdridge classification and audebert reclassification table
audebertlvl1 <- read.csv("data_raw/audebert_reclass.csv")

contemp_hold <- rast("output_data/contemporary_holdridge_hawaii.tiff")
hist_hold <- rast("output_data/historical_holdridge_hawaii.tiff")

mid_ssp126_hold <- rast("output_data/holdridge_mid_SSP126.tif")
mid_ssp245_hold <- rast("output_data/holdridge_mid_SSP245.tif")
mid_ssp370_hold <- rast("output_data/holdridge_mid_SSP370.tif")
mid_ssp585_hold <- rast("output_data/holdridge_mid_SSP585.tif")

end_ssp126_hold <- rast("output_data/holdridge_end_SSP126.tif")
end_ssp245_hold <- rast("output_data/holdridge_end_SSP245.tif")
end_ssp370_hold <- rast("output_data/holdridge_end_SSP370.tif")
end_ssp585_hold <- rast("output_data/holdridge_end_SSP585.tif")

########################### RECLASSIFYING ########################
#convert audbebert level 1 matrix 
lvl1_class <- as.matrix(audebertlvl1)

#reclassify all maps 
contemp_hold_lvl1 <- classify(contemp_hold, lvl1_class)
hist_hold_lvl1 <- classify(hist_hold, lvl1_class)

mid_ssp126_hold_lvl1 <- classify(mid_ssp126_hold, lvl1_class)
mid_ssp245_hold_lvl1 <- classify(mid_ssp245_hold, lvl1_class)
mid_ssp370_hold_lvl1 <- classify(mid_ssp370_hold, lvl1_class)
mid_ssp585_hold_lvl1 <- classify(mid_ssp585_hold, lvl1_class)

end_ssp126_hold_lvl1 <- classify(end_ssp126_hold, lvl1_class)
end_ssp245_hold_lvl1 <- classify(end_ssp245_hold, lvl1_class)
end_ssp370_hold_lvl1 <- classify(end_ssp370_hold, lvl1_class)
end_ssp585_hold_lvl1 <- classify(end_ssp585_hold, lvl1_class)

########################### EXPORT ########################
writeRaster(contemp_hold_lvl1, 
            "output_data/holdridge_audebert_lvl1_class/contemp_hold_lvl1.tiff",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(hist_hold_lvl1, 
            "output_data/holdridge_audebert_lvl1_class/hist_hold_lvl1.tiff",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)

writeRaster(mid_ssp126_hold_lvl1, 
            "output_data/holdridge_audebert_lvl1_class/mid_ssp126_hold_lvl1.tiff",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(mid_ssp245_hold_lvl1, 
            "output_data/holdridge_audebert_lvl1_class/mid_ssp245_hold_lvl1.tiff",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(mid_ssp370_hold_lvl1, 
            "output_data/holdridge_audebert_lvl1_class/mid_ssp370_hold_lvl1.tiff",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(mid_ssp585_hold_lvl1, 
            "output_data/holdridge_audebert_lvl1_class/mid_ssp585_hold_lvl1.tiff",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)

writeRaster(end_ssp126_hold_lvl1, 
            "output_data/holdridge_audebert_lvl1_class/end_ssp126_hold_lvl1.tiff",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(end_ssp245_hold_lvl1, 
            "output_data/holdridge_audebert_lvl1_class/end_ssp245_hold_lvl1.tiff",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(end_ssp370_hold_lvl1, 
            "output_data/holdridge_audebert_lvl1_class/end_ssp370_hold_lvl1.tiff",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(end_ssp585_hold_lvl1, 
            "output_data/holdridge_audebert_lvl1_class/end_ssp585_hold_lvl1.tiff",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
