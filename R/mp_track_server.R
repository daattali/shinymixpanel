#' Track an event to Mixpanel using the server-side API
#'
#' Using the client-side API ([mp_track()]) is preferable because sending data through the web
#' browser automatically includes more data about the user. The advantage of using the server-side
#' API is that it cannot be blocked with an ad blocker.\cr\cr
#' The server-side API can also be used by any R script outside of a Shiny app, while the client-side
#' API can only be used in a Shiny app.
#' @param event Name of the event.
#' @param properties List of properties to send for this event.
#' @param userid A user ID to identify with this event.
#' @param token The Mixpanel project token. If not provided, then an environment variable
#' `SHINYMIXPANEL_TOKEN` will be used.
#' @examples
#' \dontrun{
#'   Sys.setenv("SHINYMIXPANEL_TOKEN" = YOUR_PROJECT_TOKEN)
#'   mp_userid("abcd1234")
#'   mp_default_props(list("foo" = "bar", "text" = "hello"))
#'   mp_track_server("greet", list(name = "dean"))
#' }
#' @export
mp_track_server <- function(event, properties = list(), userid = "", token = "") {
  if (missing(event)) {
    stop("mp_track_server: An `event` is required", call. = FALSE)
  }
  mp_track_server_engine(event = event, properties = properties, userid = userid, token = token,
                         ignore_cache = FALSE)
}

# ignore_cache means to only use the parameters that are passed in and not use previous stored values
mp_track_server_engine <- function(event, properties = list(), userid = "", token = "", ignore_cache = FALSE) {
  if (Sys.getenv("SHINYMIXPANEL_DISABLE", "") != "") {
    return(FALSE)
  }

  session <- shiny::getDefaultReactiveDomain()

  if (is_empty(token)) {
    token <- session$userData$shinymixpanel_token
    if (is_empty(token)) {
      token <- Sys.getenv("SHINYMIXPANEL_TOKEN", "")
      if (is_empty(token)) {
        stop("mp_track_server: A `token` is required (can set it via `SHINYMIXPANEL_TOKEN` envvar)", call. = FALSE)
      }
    }
  }

  if (!ignore_cache) {
    if (is_empty(userid)) {
      if (is.null(session)) {
        userid <- .shinymixpanelenv$userid
      } else {
        userid <- session$userData$shinymixpanel_userid
      }
    }
  }

  props <- list()
  if (!ignore_cache) {
    if (is.null(session)) {
      props <- .shinymixpanelenv$defaultProps
    } else {
      props <- session$userData$shinymixpanel_defaultProps
    }
  }

  if (!is.null(session)) {
    clientProps <- session$userData$shinymixpanel_clientProps
    lapply(names(clientProps), function(name) {
      props[[name]] <<- clientProps[[name]]
    })
  }

  lapply(names(properties), function(name) {
    props[[name]] <<- properties[[name]]
  })

  props$token <- token

  if (!is_empty(userid)) {
    props[["distinct_id"]] <- userid
    props[["$user_id"]] <- userid
  }

  tryCatch({
    res <- httr::POST(
      url = "https://api.mixpanel.com/track",
      encode = "json",
      body = list(
        list(event = event, properties = props)
      )
    )
    httr::status_code(res) == 200
  }, error = function(err) {
    FALSE
  })
}
