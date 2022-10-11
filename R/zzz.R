.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath(prefix = "shinymixpanel-assets", directoryPath = system.file("assets", package = "shinymixpanel"))
}

.onUnload <- function(libname, pkgname) {
  if (utils::packageVersion("shiny") >= "1.4.0") {
    shiny::removeResourcePath("shinymixpanel-assets")
  }
}
