#' Set up a Shiny app to use Mixpanel for event tracking
#'
#' Call this function in a Shiny app's UI in order to initialize Mixpanel on the page. A project
#' token is required, which can either be provided using the `token` parameter or with the
#' `SHINYMIXPANEL_TOKEN` environment variable.
#'
#' @note Tracking can be temporarily disabled, for example while developing or testing, by setting
#' the `SHINYMIXPANEL_DISABLE` environment variable to `"1"`.
#' @param token The Mixpanel project token. If not provided, then an environment variable
#' `SHINYMIXPANEL_TOKEN` will be used.
#' @param userid A user ID to identify with Mixpanel on the current page. If provided, this user ID
#' will be associated with all event tracking calls. If the user ID is not known in the UI and
#' is only known in the server, call `[mp_userid()]` from the server.
#' @param options List of configuration options to pass to Mixpanel. A full list of supported
#' options is available in [Mixpanel's documentation](https://developer.mixpanel.com/docs/javascript-full-api-reference#mixpanelset_config).
#' See the examples below for sample usage.
#' @param default_properties List of properties to send with every event.
#' @param default_properties_js List of properties that need to be computed client-side (with JavaScript
#' in the user's browser) to send with every event. See the examples below for sample usage.
#' @param test_token A Mixpanel project token for a test project. Must be used together with `test_domains`.
#' See the section below on "Using a test Mixpanel project for testing/development".
#' @param test_domains List of domains where the `test_token` should be used. Must be used together
#' with `test_token`. See the section below on "Using a test Mixpanel project for testing/development".
#' @param track_server By default, {shinymixpanel} attempts to send all event tracking via the user's browser.
#' This is the preferred way to use Mixpanel, as it automatically gathers some user data from the web browser.
#' However, some users may disable tracking in their browser (for example using an ad blocker), and for these
#' users it's not possible to connect to Mixpanel through the browser. If you set `track_server = TRUE`,
#' then {shinymixpanel} will send events to Mixpanel using server API calls when the browser blocks Mixpanel
#' tracking. In this case, {shinymixpanel} will try to detect some browser data and send it along:
#' operating system, browser name, screen size, and current URL.
#' @section Using a test Mixpanel project for testing/development:
#' While developing or testing your Shiny app, you can use the `SHINYMIXPANEL_DISABLE` envvar
#' to disable Mixpanel tracking. However, sometimes you may want to still have tracking but send the
#' data to a different "test" project rather than the real production Mixpanel project. The {shinymixpanel}
#' package supports this usecase via the `test_token` and `test_domains` parameters.\cr\cr
#' If both of these parameters are provided, then if the Shiny app is in a domain listed in the
#' `test_domains` list, the data will be sent to the project specified by `test_token` instead.
#' Note that the domains in `test_domains` are assumed to be suffixes. This means that if you provide
#' `"example.com"` as a test domain, then any user on `example.com` or `test.example.com` will use
#' the test project.
#' @examples
#' if (interactive()) {
#'
#'   ### The simplest way to initialize Mixpanel is simply by calling `mp_init(token)`
#'   library(shiny)
#'   library(shinymixpanel)
#'   ui <- fluidPage(
#'     mp_init(YOUR_PROJECT_TOKEN)
#'   )
#'
#'   server <- function(input, output, session) {
#'     mp_track("page init")
#'   }
#'
#'   shinyApp(ui, server)
#'
#'   ### The exapmle below shows how to use the many different parameters
#'
#'   library(shiny)
#'   library(shinymixpanel)
#'
#'   ui <- fluidPage(
#'     mp_init(
#'       YOUR_PROJECT_TOKEN,
#'       userid = "d24ba28c3",
#'       options = list(debug = TRUE),
#'       default_properties = list(foo = "bar", shiny_version = as.character(packageVersion("shiny"))),
#'       default_properties_js = list(size = "screen.width", ua = "navigator.userAgent"),
#'       test_token = TOKEN_FOR_TEST_PROJECT,
#'       test_domains = list("127.0.0.1", "internal.mycompany.com")
#'     )
#'   )
#'
#'   server <- function(input, output, session) {
#'     mp_track("page init")
#'   }
#'
#'   shinyApp(ui, server)
#' }
#' @export
mp_init <- function(
    token, userid = "", options = list(),
    default_properties = list(), default_properties_js = list(),
    test_token = "", test_domains = list("127.0.0.1", "localhost"),
    track_server = FALSE
) {
  if (Sys.getenv("SHINYMIXPANEL_DISABLE", "") != "") {
    message("Note: {shinymixpanel} is disabled through SHINYMIXPANEL_DISABLE envvar")
    return()
  }

  if (Sys.getenv("SHINYMIXPANEL_TOKEN_OVERRIDE", "") != "") {
    token <- Sys.getenv("SHINYMIXPANEL_TOKEN_OVERRIDE")
    test_token <- Sys.getenv("SHINYMIXPANEL_TOKEN_OVERRIDE")
  }

  if (missing(token)) {
    token <- Sys.getenv("SHINYMIXPANEL_TOKEN", "")
    if (token == "") {
      stop("mp_init: Cannot initialize mixpanel without a project token (can set it via `SHINYMIXPANEL_TOKEN` envvar)", call. = FALSE)
    }
  }

  js_vars <- 'shinymixpanel.token = "{ token }";'
  if (!is_empty(options)) {
    js_vars <- paste(js_vars, 'shinymixpanel.options = { jsonlite::toJSON(options, auto_unbox = TRUE) };')
  }
  if (!is_empty(userid)) {
    js_vars <- paste(js_vars, 'shinymixpanel.userid = "{ userid }";')
  }
  if (!is_empty(default_properties)) {
    js_vars <- paste(js_vars, 'shinymixpanel.defaultProps = { jsonlite::toJSON(default_properties, auto_unbox = TRUE) };')
  }
  if (!is_empty(default_properties_js)) {
    js_vars <- paste(js_vars, 'shinymixpanel.defaultPropsJS = { jsonlite::toJSON(default_properties_js, auto_unbox = TRUE) };')
  }
  if (!is_empty(test_token) && !is_empty(test_domains) && length(test_domains) >= 1) {
    js_vars <- paste(js_vars, 'shinymixpanel.testToken = "{ test_token }";')
    js_vars <- paste(js_vars, 'shinymixpanel.testDomains = { jsonlite::toJSON(test_domains, auto_unbox = TRUE) };')
  }
  js_vars <- paste(js_vars, 'shinymixpanel.trackServer = { jsonlite::toJSON(track_server, auto_unbox = TRUE) };')

  htmltools::attachDependencies(
    shiny::singleton(shiny::tags$head(shiny::tags$script(
      glue::glue(js_vars)
    ))),
    html_dependency_mixpanel()
  )
}

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

  if (is.null(session) || client_unreachable()) {
    mp_track_server(event, properties)
  } else {
    mp_track_client(event, properties)
  }
}

client_unreachable <- function() {
  session <- shiny::getDefaultReactiveDomain()
  !is.null(session) &&
    !is.null(session$userData$shinymixpanel_unreachable) &&
    session$userData$shinymixpanel_unreachable
}

#' Track an event to Mixpanel using the server-side API
#'
#' Using the client-side API (`[mp_track()]`) is preferable because sending data through the web
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

mp_track_client <- function(event, properties) {
  session <- shiny::getDefaultReactiveDomain()
  session$sendCustomMessage(
    'shinymixpanel.track',
    list(
      event = event,
      properties = properties
    )
  )
}

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


