addFeatures = function(globe, data) {

  globe$dependencies <- c(
    globe$dependencies,
    list(
      htmltools::htmlDependency(
        "features",
        '0.0.1',
        system.file("htmlwidgets", package = "cesium"),
        script = c("features.js")
      )
    )
  )

  invokeMethod(globe, getglobeData(globe), "addFeatures", data)

}
