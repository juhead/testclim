## This script is for reviewing holdridge classifications by island 
install.packages("sf")
install.packages("terra")
install.packages("tidyr")
install.packages("dplyr")
install.packages("exactextractr")
install.packages("macroBiome")
install.packages("ggplot2")
install.packages("tidyterra")
install.packages("purrr")
install.packages("paletteer")

library(sf)
library(terra)
library(dplyr)
library(tidyr)
library(exactextractr)
library(macroBiome)
library(ggplot2)
library(tidyterra)
library(purrr)
library(paletteer)

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
islands <- read_sf("data_raw/dems_coast/dems/coast/coast_geo_shp.shp")

ggplot(islands) +
  geom_sf(aes(fill = factor(COAST_GEO_))) +
  labs(
    fill = "Island ID",
  ) +
  scale_fill_paletteer_d("MetBrewer::Signac")
#check the coordinate reference systems for both 
crs(hold_class, describe = TRUE)
st_crs(islands)

hold_class_NAD83 <- project(hold_class, "EPSG:4269", method = "near")
crs(hold_class_NAD83, describe = TRUE)

island_names <- read_sf("data_raw/Coastline.geojson")
island_names <- st_transform(island_names, crs = st_crs(islands))
st_crs(island_names)

#join islands to data with island names (not using yet)
islands_w_names <- st_join(islands, island_names, join = st_intersects)
plot(st_geometry(islands_w_names))

#calculate area in meters squared for islands 
islands$calc_area <- as.numeric(st_area(islands))

#calculate area covered by the different zones by the island 
island_areas <- islands |>
  mutate(calc_area = as.numeric(st_area(geometry))) |>   # use your geometry column name if it differs
  st_drop_geometry() |>
  select(COAST_GEO_, calc_area)

island_zones <- exact_extract(
  hold_class_NAD83, islands,
  function(df) {
    df |>
      filter(!is.na(value)) |>
      group_by(value, COAST_GEO_) |>
      summarise(area = sum(coverage_area), .groups = "drop")
  },
  coverage_area = TRUE,
  include_cols = "COAST_GEO_",
  summarize_df = TRUE
) |>
  left_join(island_areas, by = "COAST_GEO_") |>
  mutate(percent_island = 100 * area / calc_area)

island_totals <- island_zones |>
  group_by(COAST_GEO_) |>
  summarise(total_percent = sum(percent_island), .groups = "drop")

#get codes from macroBiome
codes <- vegClsNumCodes

lookup <- data.frame(
  ID    = seq_len(nrow(codes)),
  label = codes$Name.HLZ      
)

#assign names of zones to table 
island_zones <- left_join(island_zones, lookup, by = c("value" = "ID"))

#assign island names using islands_w_names (created above)
island_lookup <- islands_w_names |>
  st_drop_geometry() |>
  distinct(COAST_GEO_, isle)

island_zones <- island_zones %>% left_join(island_lookup, by = "COAST_GEO_", 
                                           relationship = "many-to-one")

#seems like the names don't exactly work so we will need to come back to that
#create separate dataframes for each island id
split_island_zones <- split(island_zones, f = island_zones$COAST_GEO_)

#color scheme for classifications
all_classes <- sort(unique(island_zones$label))
n  <- length(all_classes)
cols <- setNames(hcl.colors(n, palette = "Dark 3"), as.character(all_classes))

#graphing percent of island covered by each type 
plots <- imap(split_island_zones, function(df, id) {
  ggplot(df, aes(x = factor(label), y = percent_island, fill = label)) +
    geom_col() +
    labs(
      title = paste("Island", id),
      x = "Class",
      y = "% of island area"
    ) +
    scale_fill_manual(values = cols, drop = FALSE, name = "Class") +
    scale_x_discrete(drop = FALSE) +
    theme_minimal() +
    coord_flip()
})
plots[[3]]

#making pie charts for each island 
plots_pie <- imap(split_island_zones, function(df, id) {
  ggplot(df, aes(x = "", y = percent_island, fill = label)) +
    geom_bar(width = 1, stat = "identity") +
    coord_polar("y", start = 0) +
    labs(
      title = paste("Island", id),
      x = "Class",
      y = "% of island area"
    ) +
    scale_fill_manual(values = cols, drop = FALSE, name = "Class") +
    scale_x_discrete(drop = FALSE) +
    theme_void()
})

plots_pie[[2]]

#used to export piecharts relating to distribution of Holdridge classifications
#iwalk(plots_pie, function(p, id) {
#  ggsave(paste0("island_", id, ".png"), p, width = 6, height = 4, dpi = 300)
#})

#adding in revised island data 
islands_new <- read_sf("data_raw/hawaii_coastline_shp/coast_hawaii.shp")

hold_islands <- exact_extract(
  hold_class_NAD83, islands_new,
  function(df) {
    df |>
      filter(!is.na(value)) |>
      group_by(value, Name, Area_sq_km) |>
      summarise(area = (sum(coverage_area) / 1e6), .groups = "drop") |>
      mutate(pct_island = 100 * (area  / Area_sq_km))
  },
  coverage_area = TRUE,
  include_cols = c("Name", "Area_sq_km"),
  summarize_df = TRUE
)





