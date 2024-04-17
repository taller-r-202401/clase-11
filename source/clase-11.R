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

### **1.1 Acerca de OpenStreetMap**

### **1.2. Geocodificar direcciones**

## Buscar un lugar público por el nombre
geocode_OSM("Casa de Nariño, Bogotá")

## geocode_OSM no reconoce el caracter #, en su lugar se usa %23% 
cbd <- geocode_OSM("Centro Internacional, Bogotá", as.sf=T) 
cbd

## la función addTiles adiciona la capa de OpenStreetMap
leaflet() %>% addTiles() %>% addCircles(data=cbd)

### **1.3. Librería `osmdata`**

#### **1.3.1. Features disponibles**

available_features() %>% head(20)

available_tags("amenity") %>% head(20)

### **1.4. Descargar features**
  
## obtener la caja de coordenada que contiene el polígono de Bogotá
opq(bbox = getbb("Bogotá Colombia"))

## objeto osm
osm = opq(bbox = getbb("Bogotá Colombia")) %>%
      add_osm_feature(key="amenity" , value="bus_station") 
class(osm)

## extraer Simple Features Collection
osm_sf = osm %>% osmdata_sf()
osm_sf

## Obtener un objeto sf
bus_station = osm_sf$osm_points %>% select(osm_id,amenity) 
bus_station

## Pintar las estaciones de autobus
leaflet() %>% addTiles() %>% addCircleMarkers(data=bus_station , col="red")

## **[2.] Operaciones geometricas**

### **2.1 Importar conjuntos de datos**

## my_house
my_house <- geocode_OSM("Calle 26 %23% 4-29, Bogotá", as.sf=T) 
my_house

## parques
parques <- opq(bbox = getbb("Bogota Colombia")) %>%
           add_osm_feature(key = "leisure", value = "park") %>%
           osmdata_sf() %>% .$osm_polygons %>% select(osm_id,name)

leaflet() %>% addTiles() %>% addPolygons(data=parques)

### **2.2 help:** `sf`

## Help
vignette("sf3")
vignette("sf4")

### **2.3 Afine transformations**
st_crs(my_house) == st_crs(parques) 

### **2.4 Filtrar datos**
  
## usando la geometría
chapinero <- getbb(place_name = "UPZ Chapinero, Bogota", 
                   featuretype = "boundary:administrative", 
                   format_out = "sf_polygon") %>% .$multipolygon

leaflet() %>% addTiles() %>% addPolygons(data=chapinero)

## crop puntos con poligono (opcion 2)
parques_chapi <- st_intersection(x = parques , y = chapinero)

leaflet() %>% addTiles() %>% addPolygons(data=chapinero,col="red") %>% addPolygons(data=parques_chapi)

## crop puntos con poligono (opcion 3)
parques_chapi <- parques[chapinero,]

leaflet() %>% addTiles() %>% addPolygons(data=chapinero,col="red") %>% addPolygons(data=parques_chapi)

### **2.5. Distancia a amenities**
  
## Distancia a un punto
my_house$dist_cbd <- st_distance(x=my_house , y=cbd)

my_house$dist_cbd %>% head()

## Distancia a muchos puntos
matrix_dist_bus <- st_distance(x=my_house , y=bus_station)

matrix_dist_bus[1,1:5]

min_dist_bus <- apply(matrix_dist_bus , 1 , min)

min_dist_bus %>% head()

my_house$dist_buse = min_dist_bus

## **[3.] Visualizaciones**
  
## get Bogota-UPZ 
bog <- opq(bbox = getbb("Bogota Colombia")) %>%
       add_osm_feature(key="boundary", value="administrative") %>% 
       osmdata_sf()
bog <- bog$osm_multipolygons %>% subset(admin_level==9)

## basic plot
ggplot() + geom_sf(data=bog)

## plot variable
bog$normal <- rnorm(nrow(bog),100,10)
ggplot() + geom_sf(data=bog , aes(fill=normal))

## plot variable + scale
map <- ggplot() + geom_sf(data=bog , aes(fill=normal)) +
       scale_fill_viridis(option = "A" , name = "Variable")
map 

## add scale_bar
map <- map +
       scalebar(data = bog , dist = 5 , transform = T , dist_unit = "km") +
       north(data = bog , location = "topleft")
map 

## add theme
map <- map + theme_linedraw() + labs(x="" , y="")
map


