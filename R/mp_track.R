#' Track an event to Mixpanel
#'
#' When called from a Shiny app, the Mixpanel client-side API is used, which sends events through the
#' user's web browser. This is the preferred way to use Mixpanel, as it automatically gathers some user
#' data from the browser. If you prefer to use the server-side API explicitly, use
#' `[mp_track_server()]`.\cr\cr
#' When called outside a Shiny app, `[mp_track_server()]` is used.
#' @param event Name of the event
#' @param properties List of properties to send for this event
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
#'     mp_track("page init")
#'   }
#'
#'   shinyApp(ui, server)
#' }
#' @export
mp_track <- function(event, properties = list()) {
  if (Sys.getenv("SHINYMIXPANEL_DISABLE", "") != "") {
    return(FALSE)
  }

  if (missing(event)) {
    stop("mp_track: An `event` is required", call. = FALSE)
  }
  mp_track_chooser(event, properties)
}

mp_track_chooser <- function(event, properties) {
  session <- shiny::getDefaultReactiveDomain()

  if (client_unreachable()) {
    mp_track_server(event, properties)
  } else {
    mp_track_client(event, properties)
  }
}
