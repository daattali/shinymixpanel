.shinymixpanelenv <- new.env(parent = emptyenv())
.shinymixpanelenv$userid <- ""
.shinymixpanelenv$defaultProps <- list()

.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath(prefix = "shinymixpanel-assets", directoryPath = system.file("assets", package = "shinymixpanel"))

  shiny::registerInputHandler("shinymixpanel", force = TRUE, function(data, session, name) {
    if (name == "shinymixpanel__unreachable") {
      session$userData$shinymixpanel_unreachable <- TRUE
      session$userData$shinymixpanel_token <- data$token
      session$userData$shinymixpanel_defaultProps <- append(
        session$userData$shinymixpanel_defaultProps,
        data$js_props
      )
      lapply(data$events, function(x) {
        mp_track(x$event, x$properties)
      })
      NULL
    } else if (name == "shinymixpanel__track") {
      mp_track(data$event, data$properties)
      NULL
    } else {
      data
    }
  })
}

.onUnload <- function(libname, pkgname) {
  if (utils::packageVersion("shiny") >= "1.4.0") {
    shiny::removeResourcePath("shinymixpanel-assets")
  }

  shiny::removeInputHandler("shinymixpanel")
}
