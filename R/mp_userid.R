#' Associate Mixpanel events with a specific user
#'
#' After calling `mp_userid()`, all subsequent Mixpanel events will be associated with
#' this user ID.
#'
#' @param userid A user ID to identify with Mixpanel.
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
#'     mp_userid("fa8762b3a")
#'     mp_track("page init")
#'   }
#'
#'   shinyApp(ui, server)
#' }
#' @export
mp_userid <- function(userid) {
  if (missing(userid)) {
    stop("mp_userid: A `userid` is required", call. = FALSE)
  }
  session <- shiny::getDefaultReactiveDomain()

  if (is.null(session)) {
    .shinymixpanelenv$userid <- userid
  } else {
    session$userData$shinymixpanel_userid <- userid
    if (!client_unreachable()) {
      session$sendCustomMessage('shinymixpanel.setUserID', list(userid = userid))
    }
  }
}
