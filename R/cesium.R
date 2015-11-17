#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
cesium <- function(message, width = NULL, height = NULL) {

  # forward options using x
  x = list(
    message = message
  )

  sizing <- htmlwidgets::sizingPolicy(padding = 0, browser.fill = TRUE)

  # create widget
  htmlwidgets::createWidget(
    name = 'cesium',
    x,
    width = width,
    height = height,
    package = 'cesium',
    sizingPolicy = sizing
  )
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
