#####################################################################
## This script uses the packages terra and macroBiome to classify Hawaii Holdridge 
## Life Zones (HLZs) using contemporary and future predictions (8 mulit-model 
## ensemble climate projections: 4 SSP scenarios to 2 different projection dates
## (mid-century and end-of-centruy)) 
#####################################################################

########################### LOAD PACKAGES ########################
library(terra)
library(macroBiome)

########################### LOAD DATA  ########################
# laading in list of contemporary tiffs 
temps_12_con <- list.files("data_raw/contemporary_mean_monthly_air_temperature", pattern = "\\.tif$", full.names = TRUE)
precips_12_con <- list.files("data_raw/contemporary_mean_monthly_rainfall", pattern = "\\.tif$", full.names = TRUE)
# stacking monthly tiffs into annual contemporary raster stack
temp_con <- rast(temps_12_con)
precip_con <- rast(precips_12_con) 

#loading in future predictions 
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

######################## USING CLASSIFICATION FUNCTION #####################
# CONTEMPORARY
result1_con <- cliHoldridgeGrid(rs.temp = temp_con, rs.prec = precip_con)
plot(result1_con) # result without named classes

# MID, SSP126
MID_SSP126 <- cliHoldridgeGrid(rs.temp = temp_mid_126, rs.prec = prec_mid_126)
plot(MID_SSP126)

# MID, SSP245
MID_SSP245 <- cliHoldridgeGrid(rs.temp = temp_mid_245, rs.prec = prec_mid_245)
plot(MID_SSP245)

# MID, SSP370
MID_SSP370 <- cliHoldridgeGrid(rs.temp = temp_mid_370, rs.prec = prec_mid_370)
plot(MID_SSP370)

# MID, SSP585
MID_SSP585 <- cliHoldridgeGrid(rs.temp = temp_mid_585, rs.prec = prec_mid_585)
plot(MID_SSP585)

# END, SSP126
END_SSP126 <- cliHoldridgeGrid(rs.temp = temp_end_126, rs.prec = prec_end_126)
plot(END_SSP126)

# END, SSP245
END_SSP245 <- cliHoldridgeGrid(rs.temp = temp_end_245, rs.prec = prec_end_245)
plot(END_SSP245)

# END, SSP370
END_SSP370 <- cliHoldridgeGrid(rs.temp = temp_end_370, rs.prec = prec_end_370)
plot(END_SSP370)

# END, SSP585
END_SSP585 <- cliHoldridgeGrid(rs.temp = temp_end_585, rs.prec = prec_end_585)
plot(END_SSP585)

########################### Saving Tiffs ################################
#contemporary
writeRaster(result1_con, "output_data/holdridge_contemporary.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
#MID SSP126
writeRaster(MID_SSP126, "output_data/holdridge_mid_SSP126.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
#MIDSSP245
writeRaster(MID_SSP245, "output_data/holdridge_mid_SSP245.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
#MIDSSP370
writeRaster(MID_SSP370, "output_data/holdridge_mid_SSP370.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
#MIDSSP585
writeRaster(MID_SSP585, "output_data/holdridge_mid_SSP585.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
#END SSP126
writeRaster(END_SSP126, "output_data/holdridge_end_SSP126.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
#END SSP 245
writeRaster(END_SSP245, "output_data/holdridge_end_SSP245.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
#END SSP370
writeRaster(END_SSP370, "output_data/holdridge_end_SSP370.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
#END SSP585
writeRaster(END_SSP585, "output_data/holdridge_end_SSP585.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
