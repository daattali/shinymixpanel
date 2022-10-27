#' Set default properties for Mixpanel events
#'
#' These properties will be sent with every subsequent Mixpanel event. Calling this function
#' multiple times will override the previous defaults.
#' @param properties List of properties.
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinymixpanel)
#'
#'   ui <- fluidPage(
#'     mp_init(YOUR_PROJECT_TOKEN)
#'   )
#'
#'   server <- function(input, output, session) {
#'     mp_default_props(list(foo = "bar", shiny_version = as.character(packageVersion("shiny"))))
#'     mp_track("page init")
#'   }
#'
#'   shinyApp(ui, server)
#' }
#' @export
mp_default_props <- function(properties) {
  if (missing(properties)) {
    stop("mp_default_props: A `properties` list is required", call. = FALSE)
  }

  session <- shiny::getDefaultReactiveDomain()

  if (is.null(session)) {
    .shinymixpanelenv$defaultProps <- properties
  } else {
    session$userData$shinymixpanel_defaultProps <- properties
    if (!client_unreachable()) {
      session$sendCustomMessage('shinymixpanel.setDefaultProps', list(props = properties))
    }
  }
}
