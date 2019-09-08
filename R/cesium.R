#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
# cesium <- function(message, width = NULL, height = NULL) {
#
#   # forward options using x
#   x = list(
#     message = message
#   )
#
#   sizing <- htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE)
#
#   # create widget
#   htmlwidgets::createWidget(
#     name = 'cesium',
#     x,
#     width = width,
#     height = height,
#     package = 'cesium',
#     sizingPolicy = sizing
#   )
# }
cesium <- function(data = NULL, width = NULL, height = NULL,
                   padding = 0, options = cesiumOptions(),
                   elementId = NULL,
                   sizingPolicy = cesiumSizingPolicy(padding = padding)) {

  globe <- htmlwidgets::createWidget(
    "cesium",
    structure(
      list(options = options,
           ## cesiumData withing this list needs to be deleted
           ## once we have proper add* functions
           cesiumData = data),
      cesiumData = data
    ),
    width = width, height = height,
    sizingPolicy = sizingPolicy,
    preRenderHook = function(widget) {
      if (!is.null(widget$jsHooks$render)) {
        widget$jsHooks$render <- lapply(widget$jsHooks$render, function(hook) {
          if (is.list(hook)) {
            hook$code <- sprintf(hookWrapperTemplate, paste(hook$code, collapse = "\n"))
          } else if (is.character(hook)) {
              hook <- sprintf(hookWrapperTemplate, paste(hook, collapse = "\n"))
          } else {
            stop("Unknown hook class ", class(hook))
          }
          hook
        })
      }
      widget
    },
    elementId = elementId
  )

  if (crosstalk::is.SharedData(data)) {
    globe <- addSelect(globe)
  }

  globe
}


cesiumOptions <- function(animation = FALSE,
                          baseLayerPicker = FALSE,
                          fullscreenButton = FALSE,
                          geocoder = FALSE,
                          homeButton = TRUE,
                          infoBox = FALSE,
                          sceneModePicker = TRUE,
                          selectionIndicator = FALSE,
                          timeline = TRUE,
                          navigationHelpButton = FALSE,
                          navigationInstructionsInitiallyVisible = FALSE,
                          scene3DOnly = FALSE,
                          skyBox = FALSE,
                          skyAtmosphere = FALSE,
                          sceneMode = NULL,
                          imageryProvider = NULL,
                          targetFrameRate = 100,
                          orderIndependentTranslucency = FALSE,
                          projectionPicker = TRUE,
                          ...) {

  filterNULL(
    list(
      animation = animation,
      baseLayerPicker = baseLayerPicker,
      fullscreenButton = fullscreenButton,
      geocoder = geocoder,
      homeButton = homeButton,
      infoBox = infoBox,
      sceneModePicker = sceneModePicker,
      selectionIndicator = selectionIndicator,
      timeline = timeline,
      navigationHelpButton = navigationHelpButton,
      navigationInstructionsInitiallyVisible = navigationInstructionsInitiallyVisible,
      scene3DOnly = scene3DOnly,
      skyBox = skyBox,
      skyAtmosphere = skyAtmosphere,
      sceneMode = sceneMode,
      imageryProvider = imageryProvider,
      targetFrameRate = targetFrameRate,
      orderIndependentTranslucency = orderIndependentTranslucency,
      projectionPicker = projectionPicker,
      ...
    )
  )
}

cesiumSizingPolicy <- function(defaultWidth = "100%",
                               defaultHeight = 400,
                               padding = 0,
                               browser.fill = TRUE,
                               ...) {
  htmlwidgets::sizingPolicy(
    defaultWidth = defaultWidth,
    defaultHeight = defaultHeight,
    padding = padding,
    browser.fill = browser.fill,
    ...
  )
}

hookWrapperTemplate <- "function(el, x, data) {
  return (%s).call(this.getglobe(), el, x, data);
}"


getglobeData <- function(globe) {
  attr(globe$x, "cesiumData", exact = TRUE)
}


filterNULL = function (x) {
  if (length(x) == 0 || !is.list(x))
    return(x)
  x[!unlist(lapply(x, is.null))]
}

#' Widget output function for use in Shiny
#'
#' @export
cesiumOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'cesium', width, height, package = 'cesium')
}

#' Widget render function for use in Shiny
#'
#' @export
renderCesium <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, cesiumOutput, env, quoted = TRUE)
}
