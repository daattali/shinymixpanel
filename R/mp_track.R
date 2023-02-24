#' Track an event to Mixpanel
#'
#' See the section below on "Client-side vs server-side tracking" to understand how
#' events data will be sent to Mixpanel.\cr\cr
#' See the full \href{https://github.com/daattali/shinymixpanel#readme}{README} on
#' GitHub for more details.\cr\cr
#' @param event Name of the event
#' @param properties List of properties to send for this event
#' @param userid A user ID to identify with this event. **Do not use this parameter in Shiny apps.**
#' @param token The Mixpanel project token. If not provided, then an environment variable
#' `SHINYMIXPANEL_TOKEN` will be used. **Do not use this parameter in Shiny apps.**
#' @inheritSection mp_init Client-side vs server-side tracking
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
mp_track <- function(event, properties = list(), userid = "", token = "") {
  if (Sys.getenv("SHINYMIXPANEL_DISABLE", "") != "") {
    return(FALSE)
  }

  if (missing(event)) {
    stop("mp_track: An `event` is required", call. = FALSE)
  }

  if (in_shiny()) {
    if (is.null(userid) || nzchar(userid)) {
      stop("mp_track: Do not use `userid` in Shiny apps. Use `mp_userid()` or `mp_init(userid)` instead.", call. = FALSE)
    }
    if (is.null(token) || nzchar(token)) {
      stop("mp_track: Do not use `token` in Shiny apps. Use `mp_init(token)` or the `SHINYMIXPANEL_TOKEN` envvar instead.", call. = FALSE)
    }
  }

  if (in_shiny()) {
    mp_track_chooser(event, properties)
  } else {
    mp_track_server(event, properties, userid = userid, token = token)
  }
}
