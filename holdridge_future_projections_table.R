#this is a script to create a table of holdridge prediction area for paper 
#load required packages 
install.packages("tidyverse")
install.packages("readxl")
install.packages("dplyr")

library(tidyverse)
library(readxl)
library(dplyr)

########################### LOADING DATA ########################
#read in mid century files
mid_ssp585 <- read_excel("output_data/holdridge_mid_century_sheet.xlsx", sheet = 1)
mid_ssp370 <- read_excel("output_data/holdridge_mid_century_sheet.xlsx", sheet = 2)
mid_ssp245 <- read_excel("output_data/holdridge_mid_century_sheet.xlsx", sheet = 3)
mid_ssp126 <- read_excel("output_data/holdridge_mid_century_sheet.xlsx", sheet = 4)

#read in end century files
end_ssp585 <- read_excel("output_data/holdridge_end_century_sheet.xlsx", sheet = 1)
end_ssp370 <- read_excel("output_data/holdridge_end_century_sheet.xlsx", sheet = 2)
end_ssp245 <- read_excel("output_data/holdridge_end_century_sheet.xlsx", sheet = 3)
end_ssp126 <- read_excel("output_data/holdridge_end_century_sheet.xlsx", sheet = 4)

#rounding values
mid_ssp126 <- mid_ssp126 %>% mutate(across(where(is.numeric), round, digits = 2))
mid_ssp245 <- mid_ssp245 %>% mutate(across(where(is.numeric), round, digits = 2))
mid_ssp370 <- mid_ssp370 %>% mutate(across(where(is.numeric), round, digits = 2))
mid_ssp585 <- mid_ssp585 %>% mutate(across(where(is.numeric), round, digits = 2))

end_ssp126 <- end_ssp126 %>% mutate(across(where(is.numeric), round, digits = 2))
end_ssp245 <- end_ssp245 %>% mutate(across(where(is.numeric), round, digits = 2))
end_ssp370 <- end_ssp370 %>% mutate(across(where(is.numeric), round, digits = 2))
end_ssp585 <- end_ssp126 %>% mutate(across(where(is.numeric), round, digits = 2))

########################### TABLE CONVERSION ########################
#writing function 
format_stats <- function(polygon, column) {
  polygon %>% 
    mutate({{ column }} := paste0(area_km2, " (", pct_state, ")")) %>% 
    select(Label, {{ column }})
}
#format stats mid century   
mid_ssp126 <- format_stats(polygon = mid_ssp126, column = "mid_ssp126")
mid_ssp245 <- format_stats(polygon = mid_ssp245, column = "mid_ssp245")
mid_ssp370 <- format_stats(polygon = mid_ssp370, column = "mid_ssp370")
mid_ssp585 <- format_stats(polygon = mid_ssp585, column = "mid_ssp585")

#format stats end century
end_ssp126 <- format_stats(polygon = end_ssp126, column = "end_ssp126")
end_ssp245 <- format_stats(polygon = end_ssp245, column = "end_ssp245")
end_ssp370 <- format_stats(polygon = end_ssp370, column = "end_ssp370")
end_ssp585 <- format_stats(polygon = end_ssp585, column = "end_ssp585")

########################### EXPORTING ########################
#list all mid century 
mid_century <- list(mid_ssp126, mid_ssp245, mid_ssp370, mid_ssp585)

#list all end century
end_century <- list(end_ssp126, end_ssp245, end_ssp370, end_ssp585)

#join together by holdridge climate class mid century
mid_century_table <- mid_century %>% 
  reduce(full_join, by = "Label")

#join together by holdridge climate class end century 
end_century_table <- end_century %>% 
  reduce(full_join, by = "Label")

#export csv mid century  
write.csv(mid_century_table, 
          "output_data/mid_century_holdridge_table.csv", row.names = FALSE)

#export csv end century
write.csv(end_century_table, 
          "output_data/end_century_holdridge_table.csv", row.names = FALSE)
