## by Christian Zang

install.packages("rgdal")
install.packages("rgeos")
install.packages("xlsx")

library(rgdal)
library(sp)
library(raster)

## get shapefile from
## http://www.geodaten.bayern.de/opendata/Bayern.zip
## unzip somewhere...

## read in shape
bav_shape <- rgdal::readOGR(dsn = path.expand("C:\\Users\\Hello\\Documents\\R\\Bayern"),
                            layer = "bayern_ex")

## reproject to WGS84
WGS84 <- CRS("+proj=longlat +datum=WGS84")
bav_shape <- sp::spTransform(bav_shape, CRSobj = WGS84)
plot(bav_shape)

## get spatial extent of Bavaria
ex <- raster::extent(bav_shape)

## create full raster based on spatial extent. Choose .125 or .25 degree resolution.
lon <- seq(floor(ex@xmin), ceiling(ex@xmax), by = 0.25)
lat <- seq(floor(ex@ymin), ceiling(ex@ymax), by = 0.25)
full_grid <- expand.grid(lon, lat)
names(full_grid) <- c("x", "y")
full_grid <- SpatialPoints(full_grid, proj4string = WGS84)

## intersect full grid with shapefile and verify intersection
i <- raster::intersect(full_grid, bav_shape)
i_coords <- i@coords
head(i_coords)
plot(i_coords)
write.table(i_coords, "C:\\Users\\Hello\\Documents\\R\\Bayern\\Bayern_coords_025.txt", sep="\t")

library(xlsx)
write.csv(i_coords, "C:\\Users\\Hello\\Documents\\R\\Bayern\\Bayern_coords_025.csv", sep="\t")

