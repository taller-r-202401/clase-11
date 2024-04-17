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
##== 0. Leer un shapefile ==##

## leo shapefile
shp <- st_read("input/MGN_CentroPoblado.shp")

## visualizar
mapview(shp)

## clase 
class(shp)

##=== 1. Geocodificar ===##

## geocode 
geocode_OSM("Calle 32 %23% 13-83")

## convertir un sf
centro <- geocode_OSM("Edificio Mario Laserna, Bogota" , as.sf = T)
mapview(centro)

##
df <- tibble(id=c(1,2) , x=c(-74.0648,-74.0748) , y=c(4.602549,4.502549))

## st_as_sf
df_sf <- st_as_sf(x = df , coords = c("x","y") , crs=4326)
mapview(df_sf)

##=== 2. OSM-Data ===##

## 2.1 tags
available_features() %>% head(10)

available_tags(feature = "amenity")

available_tags("building")

## 2.2 Obtener caja de coordenadas
opq(bbox = getbb("Bogota, Colombia"))

## obtener bibiliotecas de chpinero
bib <- opq(bbox = getbb("Bogota, Colombia")) %>%
       add_osm_feature(key = "amenity" , value="library")

## bib_sf 
bib_sf <- osmdata_sf(bib)

## bib puntos
bib_p <- bib_sf$osm_points
mapview(bib_p)

##=== 3. Operaciones espaciales ===##

## Obetener UPZ
upz <- opq(bbox = getbb("Bogota Colombia")) %>%
       add_osm_feature(key="boundary", value="administrative") %>% 
       osmdata_sf()

## dejo los polygonos
bog <- upz$osm_multipolygons 

## filtro los poligonos de las upz
bog <- bog %>% subset(admin_level==9)
mapview(bog)

## elimino 3 upz
bog <- subset(bog, !osm_id %in% c(16011743,16011744,16011867)) %>%
       select(osm_id,name)
bog <- rename(bog, upz_id=osm_id)

mapview(bog)

## join spacial
bib_p <- st_join(x =bib_p  , y = bog)

## collapsar
st_geometry(bib_p) = NULL
bib_p <- mutate(bib_p,conteo=1) %>% 
         group_by(upz_id) %>% summarise(total_bib=sum(conteo))

## adicionar informcion al polygono
bog_bib <- left_join(x = bog , y=bib_p , "upz_id")
  
##=== 4. Plot ===##

## visualizar
ggplot() + geom_sf(data = bog_bib , aes(fill=total_bib))

## paletas de colores
ggplot() + geom_sf(data = bog_bib , aes(fill=total_bib)) +
scale_fill_viridis_c(na.value = "white")

## agregar tema
ggplot() + geom_sf(data = bog_bib , aes(fill=total_bib)) +
scale_fill_viridis_c(na.value = "white") +
theme_bw()

## agregar barra escalas y la estrella del norte
ggplot() + geom_sf(data = bog_bib , aes(fill=total_bib)) +
scale_fill_viridis_c(na.value = "white") +
theme_bw() + 
scalebar(data = bog_bib , transform = T , dist = 5 , dist_unit = "km") +
north(data = bog_bib , location = "topleft")




