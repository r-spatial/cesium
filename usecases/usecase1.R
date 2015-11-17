library(cesium)
library(htmltools)

rstudioapi::viewer("http://localhost:8000")

c <- cesium("new1")
c
utils::browseURL("http://localhost:8100")

html_print(c, background = "white", viewer = utils::browseURL)


library(leaflet)
leaflet() %>% addTiles()
