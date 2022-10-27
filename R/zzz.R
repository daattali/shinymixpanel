.shinymixpanelenv <- new.env(parent = emptyenv())
.shinymixpanelenv$userid <- ""
.shinymixpanelenv$defaultProps <- list()

.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath(prefix = "shinymixpanel-assets", directoryPath = system.file("assets", package = "shinymixpanel"))

  shiny::registerInputHandler("shinymixpanel", force = TRUE, function(data, session, name) {
    if (name == "shinymixpanel__unreachable") {
      session$userData$shinymixpanel_unreachable <- TRUE
      session$userData$shinymixpanel_token <- data$token
      session$userData$shinymixpanel_clientProps <- data$client_props

      # It's possible that the user set a userID or default properties since the unreachable
      # call was made, so only set these if they don't have a value yet so that we don't
      # overwrite with an old value
      if (is_empty(session$userData$shinymixpanel_userid)) {
        session$userData$shinymixpanel_userid <- data$userid
      }
      if (is_empty(session$userData$shinymixpanel_defaultProps)) {
        session$userData$shinymixpanel_defaultProps <- data$props
      }

      lapply(data$events, function(x) {
        mp_track_server_engine(x$event, x$properties, x$userid, ignore_cache = TRUE)
      })

      NULL
    } else if (name == "shinymixpanel__track") {
      mp_track_server_engine(data$event, data$properties, data$userid, ignore_cache = TRUE)
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
