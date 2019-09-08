dispatch <- function(globe,
                     funcName,
                     cesium = stop(paste(funcName, "requires a globe proxy object")),
                     cesium_proxy = stop(paste(funcName, "does not support globe proxy objects"))
) {
  if (inherits(globe, "cesium"))
    return(cesium)
  else if (inherits(globe, "cesium_proxy"))
    return(cesium_proxy)
  else
    stop("Invalid globe parameter")
}



invokeMethod <- function(globe, data, method, ...) {
  if (crosstalk::is.SharedData(data)) {
    globe$dependencies <- c(globe$dependencies, crosstalk::crosstalkLibs())
    data <- data$data()
  } else {
    NULL
  }

  args <- leaflet::evalFormula(list(...), data)

  dispatch(globe,
           method,
           cesium = {
             x <- globe$x$calls
             if (is.null(x)) x <- list()
             n <- length(x)
             x[[n + 1]] <- list(method = method, args = args)
             globe$x$calls <- x
             globe
           },
           cesium_proxy = {
             invokeRemote(globe, method, args)
             globe
           }
  )
}


cesiumProxy <- function(globeId, session = shiny::getDefaultReactiveDomain(),
                         data = NULL, deferUntilFlush = TRUE) {

  if (is.null(session)) {
    stop("cesiumProxy must be called from the server function of a Shiny app")
  }

  # If this is a new enough version of Shiny that it supports modules, and
  # we're in a module (nzchar(session$ns(NULL))), and the globeId doesn't begin
  # with the current namespace, then add the namespace.
  #
  # We could also have unconditionally done `globeId <- session$ns(globeId)`, but
  # older versions of cesium would have broken unless the user did session$ns
  # themselves, and we hate to break their code unnecessarily.
  #
  # This won't be necessary in future versions of Shiny, as session$ns (and
  # other forms of ns()) will be smart enough to only namespace un-namespaced
  # IDs.
  if (
    !is.null(session$ns) &&
    nzchar(session$ns(NULL)) &&
    substring(globeId, 1, nchar(session$ns(""))) != session$ns("")
  ) {
    globeId <- session$ns(globeId)
  }

  structure(
    list(
      session = session,
      id = globeId,
      x = structure(
        list(),
        cesiumData = data
      ),
      deferUntilFlush = deferUntilFlush,
      dependencies = NULL
    ),
    class = "cesium_proxy"
  )
}

# Shiny versions <= 0.12.0.9001 can't guarantee that onFlushed
# callbacks are called in the order they were registered. Rather
# than wait for this to be fixed in Shiny and released to CRAN,
# work around this for older versions by maintaining our own
# queue of work items. The names in this environment are session
# tokens, and the values are lists of invokeRemote msg objects.
# During the course of execution, cesiumProxy() should cause
# deferred messages to be appended to the appropriate value in
# sessionFlushQueue. It's the responsibility of invokeRemote to
# ensure that the sessionFlushQueue values are properly reaped
# as soon as possible, to prevent session objects from being
# leaked.
#
# When Shiny >0.12.0 goes to CRAN, we should update our version
# dependency and remove this entire mechanism.
sessionFlushQueue <- new.env(parent = emptyenv())

invokeRemote <- function(globe, method, args = list()) {
  if (!inherits(globe, "cesium_proxy"))
    stop("Invalid globe parameter; globe proxy object was expected")

  deps <- htmltools::resolveDependencies(globe$dependencies)

  msg <- list(
    id = globe$id,
    calls = list(
      list(
        dependencies = lapply(deps, shiny::createWebDependency),
        method = method,
        args = args
      )
    )
  )

  sess <- globe$session
  if (globe$deferUntilFlush) {
    if (packageVersion("shiny") < "0.12.1.9000") {

      # See comment on sessionFlushQueue.

      if (is.null(sessionFlushQueue[[sess$token]])) {
        # If the current session doesn't have an entry in the sessionFlushQueue,
        # initialize it with a blank list.
        sessionFlushQueue[[sess$token]] <- list()

        # If the session ends before the next onFlushed call, remove the entry
        # for this session from the sessionFlushQueue.
        endedUnreg <- sess$onSessionEnded(function() {
          rm(list = sess$token, envir = sessionFlushQueue)
        })

        # On the next flush, pass all the messages to the client, and remove the
        # entry from sessionFlushQueue.
        sess$onFlushed(function() {
          on.exit(rm(list = sess$token, envir = sessionFlushQueue), add = TRUE)
          endedUnreg()
          for (msg in sessionFlushQueue[[sess$token]]) {
            sess$sendCustomMessage("cesium-calls", msg)
          }
        }, once = TRUE) # nolint
      }

      # Append the current value to the apporpriate sessionFlushQueue entry,
      # which is now guaranteed to exist.
      sessionFlushQueue[[sess$token]] <- c(sessionFlushQueue[[sess$token]], list(msg))

    } else {
      sess$onFlushed(function() {
        sess$sendCustomMessage("cesium-calls", msg)
      }, once = TRUE) # nolint
    }
  } else {
    sess$sendCustomMessage("cesium-calls", msg)
  }
  globe
}

# A helper function to generate the body of function(x, y) list(x = x, y = y),
# to save some typing efforts in writing tileOptions(), markerOptions(), ...
makeListFun <- function(list) {
  if (is.function(list)) list <- formals(list)
  nms <- names(list)
  cat(sprintf("list(%s)\n", paste(nms, nms, sep = " = ", collapse = ", ")))
}

"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

