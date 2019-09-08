library(sf)
library(mapview)
library(cesium)
library(geojsonsf)

## standard data sets
fran = geojsonsf::sf_geojson(mapview::franconia)
cesium(data = fran)

brew = geojsonsf::sf_geojson(mapview::breweries)
cesium(data = brew)

trls = geojsonsf::sf_geojson(sf::st_transform(mapview::trails, 4326))
cesium(data = trls)

## some large data
pls = sf::st_read("/home/timpanse/software/data/large.gpkg", "buildings")
geom = sf::st_geometry(pls[1:100000, ])
data = sf::st_sf(id = 1:length(geom), geometry = geom)
pls_jsn = geojsonsf::sf_geojson(data)

options(viewer = NULL)

cesium(data = pls_jsn)
