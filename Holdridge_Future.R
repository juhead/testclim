## This script uses the packages terra and macroBiome to classify Hawaii climate 
## zones using 8 mulit-model ensemble climate projections: 4 SSP scenarios to 2
## different projection dates (mid-century and end-of-centruy)

# install.packages("terra")
# install.packages("macroBiome")
library(terra)
library(macroBiome)

########################### Loading data ########################

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

######################## USING CLASSIFICATION FUNCTION #####################

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

################# Assigning class names and colors to codes ###########

codes  <- vegClsNumCodes
lookup <- data.frame(ID = seq_len(nrow(codes)), label = codes$Name.HLZ)

master_cols <- hcl.colors(nrow(lookup), palette = "Dark 3")
set.seed(1); master_cols <- sample(master_cols)

make_hlz <- function(result) {
  f <- as.factor(result)
  levels(f) <- lookup
  coltab(f) <- data.frame(value = lookup$ID, col = master_cols)  
  f
}

#mid century
MID_SSP126_classified <- make_hlz(MID_SSP126)      
MID_SSP245_classified <- make_hlz(MID_SSP245)  
MID_SSP370_classified <- make_hlz(MID_SSP370)  
MID_SSP585_classified <- make_hlz(MID_SSP585)  
#end century
END_SSP126_classified <- make_hlz(END_SSP126)  
END_SSP245_classified <- make_hlz(END_SSP245)  
END_SSP370_classified <- make_hlz(END_SSP370)  
END_SSP585_classified <- make_hlz(END_SSP585)  

########################### PLOTTING ##################################
#mid century
plot(MID_SSP126_classified,
     plg = list(cex = 0.6, bg = "white", ncol = 2),
     mar = c(3, 3, 1, 14))

plot(MID_SSP245_classified,
     plg = list(cex = 0.6, bg = "white", ncol = 2),
     mar = c(3, 3, 1, 14))

plot(MID_SSP370_classified,
     plg = list(cex = 0.6, bg = "white", ncol = 2),
     mar = c(3, 3, 1, 14))

plot(MID_SSP585_classified,
     plg = list(cex = 0.6, bg = "white", ncol = 2),
     mar = c(3, 3, 1, 14))

#end century
plot(END_SSP126_classified,
     plg = list(cex = 0.6, bg = "white", ncol = 2),
     mar = c(3, 3, 1, 14))

plot(END_SSP245_classified,
     plg = list(cex = 0.6, bg = "white", ncol = 2),
     mar = c(3, 3, 1, 14))

plot(END_SSP370_classified,
     plg = list(cex = 0.6, bg = "white", ncol = 2),
     mar = c(3, 3, 1, 14))

plot(END_SSP585_classified,
     plg = list(cex = 0.6, bg = "white", ncol = 2),
     mar = c(3, 3, 1, 14))

############################# Saving Plots ##############################

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

#mid century 
save_hlz_plot(MID_SSP126_classified, "output_maps/holdridge_mid_SSP126_map.png")
save_hlz_plot(MID_SSP245_classified, "output_maps/holdridge_mid_SSP245_map.png")
save_hlz_plot(MID_SSP370_classified, "output_maps/holdridge_mid_SSP370_map.png")
save_hlz_plot(MID_SSP585_classified, "output_maps/holdridge_mid_SSP585_map.png")
#end century
save_hlz_plot(END_SSP126_classified, "output_maps/holdridge_end_SSP126_map.png")
save_hlz_plot(END_SSP245_classified, "output_maps/holdridge_end_SSP245_map.png")
save_hlz_plot(END_SSP370_classified, "output_maps/holdridge_end_SSP370_map.png")
save_hlz_plot(END_SSP585_classified, "output_maps/holdridge_end_SSP585_map.png")

########################### Saving Tiffs ################################
writeRaster(MID_SSP126, "output_data/holdridge_mid_SSP126.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(MID_SSP245, "output_data/holdridge_mid_SSP245.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(MID_SSP370, "output_data/holdridge_mid_SSP370.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(MID_SSP585, "output_data/holdridge_mid_SSP585.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)

writeRaster(END_SSP126, "output_data/holdridge_end_SSP126.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(END_SSP245, "output_data/holdridge_end_SSP245.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(END_SSP370, "output_data/holdridge_end_SSP370.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)
writeRaster(END_SSP585, "output_data/holdridge_end_SSP585.tif",
            datatype = "INT1U", NAflag = 255, overwrite = TRUE)

write.csv(lookup, "output_data/holdridge_lookup.csv", row.names = FALSE)
