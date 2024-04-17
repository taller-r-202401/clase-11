## Eduard Martinez
## Update: 

## llamar pacman (contiene la función p_load)
require(pacman)

## llamar y/o instalar librerias
p_load(tidyverse,rio,skimr,
       sf, ## datos espaciales
       mapview, ## visualizaciones
       tmaptools, ## geocodificar
       ggsn, ## map scale bar 
       osmdata) ## osm data

##=== 1. Geocodificar ===##


##=== 2. OSM-Data ===##

## 2.1 tags
available_features() %>% head(10)

available_tags("amenity")

available_tags("building")

## 2.2 Obtener caja de coordenadas
opq(bbox = getbb("Bogota, Colombia"))


##=== 3. Operaciones espaciales ===##

## Obetener UPZ

##=== 4. Plot ===##





