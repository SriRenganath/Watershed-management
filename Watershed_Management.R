# Install and load necessary libraries
install.packages(c("raster", "hydroTSM", "gstat", "rasterVis"))
library(raster)
library(hydroTSM)
library(gstat)
library(rasterVis)

# Set working directory and read digital elevation model (DEM)
setwd("F:/Watershed/Dem/Input/")
dem <- raster("dem_loc.tif")

# Delineate watershed
watershed <- watershed(dem)

# Calculate flow accumulation
flow_acc <- flowAccumulation(watershed)

# Calculate flow direction
flow_dir <- terrain(dem, opt = "flowdir")

# Extract river network
river_network <- streamNet(flow_dir, p = 0.1)

# Plot results
par(mfrow = c(2, 2))
plot(dem, main = "Digital Elevation Model (DEM)")
plot(watershed, main = "Watershed Delineation")
plot(flow_acc, main = "Flow Accumulation")
plot(river_network, main = "River Network")

# Calculate hydrological characteristics
stream_order <- streamOrder(river_network)
basin_area <- basinArea(watershed)
basin_length <- basinLength(watershed)

# Spatial interpolation of precipitation data (example)
# Assuming precipitation data in a data frame with columns 'lon', 'lat', 'precip'
precip_data <- read.csv("precip_data.csv")
coordinates(precip_data) <- c("lon", "lat")
gridded(precip_data) <- ~precip
interp_dem <- idw(precip_data$precip, cbind(precip_data$lon, precip_data$lat), dem)

# Visualize interpolated precipitation on DEM
levelplot(interp_dem, main = "Interpolated Precipitation on DEM", col.regions = terrain.colors(20))

# Assess land use impacts (example)
# Assuming land_use raster with land use information
land_use <- raster("land_use.tif")
land_use_impact <- zonal(river_network, land_use, stat = "mean")

# Visualize land use impacts
plot(land_use_impact, main = "Land Use Impact on River Network")

# Save results
writeRaster(watershed, "watershed.tif", format = "GTiff")
writeRaster(interp_dem, "interpolated_precip.tif", format = "GTiff")
