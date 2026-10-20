## This script uses the packages terra and macroBiome to classify Hawaii climate 
## zones using 8 mulit-model ensemble climate projections: 4 SSP scenarios to 2
## different projection dates (mid-century and end-of-centruy)

# install.packages("terra")
# install.packages("macroBiome")
library(terra)
library(macroBiome)

# loading in all rasters
temp_end_126 <- rast("data_raw/Thrasher_etal_Projections/temperature/MME_END_ssp126_MONTHLY_tas_mean.tif")
temp_end_245 <- rast("data_raw/Thrasher_etal_Projections/temperature/MME_END_ssp245_MONTHLY_tas_mean.tif")
temp_end_370 <- rast("data_raw/Thrasher_etal_Projections/temperature/MME_END_ssp370_MONTHLY_tas_mean.tif")
temp_end_585 <- rast("data_raw/Thrasher_etal_Projections/temperature/MME_END_ssp585_MONTHLY_tas_mean.tif")
temp_mid_126 <- rast("data_raw/Thrasher_etal_Projections/temperature/MME_MID_ssp126_MONTHLY_tas_mean.tif")
temp_mid_245 <- rast("data_raw/Thrasher_etal_Projections/temperature/MME_MID_ssp245_MONTHLY_tas_mean.tif")
temp_mid_370 <- rast("data_raw/Thrasher_etal_Projections/temperature/MME_MID_ssp370_MONTHLY_tas_mean.tif")
temp_mid_585 <- rast("data_raw/Thrasher_etal_Projections/temperature/MME_MID_ssp585_MONTHLY_tas_mean.tif")

prec_end_126 <- rast("data_raw/Thrasher_etal_Projections/rainfall/MME_END_ssp126_MONTHLY_pr_mean.tif")
prec_end_245 <- rast("data_raw/Thrasher_etal_Projections/rainfall/MME_END_ssp245_MONTHLY_pr_mean.tif")
prec_end_370 <- rast("data_raw/Thrasher_etal_Projections/rainfall/MME_END_ssp370_MONTHLY_pr_mean.tif")
prec_end_585 <- rast("data_raw/Thrasher_etal_Projections/rainfall/MME_END_ssp585_MONTHLY_pr_mean.tif")
prec_mid_126 <- rast("data_raw/Thrasher_etal_Projections/rainfall/MME_MID_ssp126_MONTHLY_pr_mean.tif")
prec_mid_245 <- rast("data_raw/Thrasher_etal_Projections/rainfall/MME_MID_ssp245_MONTHLY_pr_mean.tif")
prec_mid_370 <- rast("data_raw/Thrasher_etal_Projections/rainfall/MME_MID_ssp370_MONTHLY_pr_mean.tif")
prec_mid_585 <- rast("data_raw/Thrasher_etal_Projections/rainfall/MME_MID_ssp585_MONTHLY_pr_mean.tif")



