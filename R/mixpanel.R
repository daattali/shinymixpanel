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
#' is only known in the server, call [mp_userid()] from the server.
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
#' }
#' @export
mp_init <- function(
    token, userid = "", options = list(),
    default_properties = list(), default_properties_js = list(),
    test_token = "", test_domains = list("127.0.0.1", "localhost")
) {
  if (Sys.getenv("SHINYMIXPANEL_DISABLE", "") != "") {
    message("Note: {shinymixpanel} is disabled through SHINYMIXPANEL_DISABLE envvar")
    return()
  }

  if (missing(token)) {
    token <- Sys.getenv("SHINYMIXPANEL_TOKEN", "")
    if (token == "") {
      stop("mp_init: Cannot initialize mixpanel without a project token", call. = FALSE)
    }
  }

  userid <- empty_to_null(userid)
  options <- empty_to_null(options)
  default_properties <- empty_to_null(default_properties)
  default_properties_js <- empty_to_null(default_properties_js)
  test_token <- empty_to_null(test_token)
  test_domains <- empty_to_null(test_domains)

  js_vars <- 'shinymixpanel.token = "{ token }";'
  if (!is.null(options)) {
    js_vars <- paste(js_vars, 'shinymixpanel.options = { jsonlite::toJSON(options, auto_unbox = TRUE) };')
  }
  if (!is.null(userid)) {
    js_vars <- paste(js_vars, 'shinymixpanel.userid = "{ userid }";')
  }
  if (!is.null(default_properties)) {
    js_vars <- paste(js_vars, 'shinymixpanel.defaultProps = { jsonlite::toJSON(default_properties, auto_unbox = TRUE) };')
  }
  if (!is.null(default_properties_js)) {
    js_vars <- paste(js_vars, 'shinymixpanel.defaultPropsJS = { jsonlite::toJSON(default_properties_js, auto_unbox = TRUE) };')
  }
  if (!is.null(test_token) && !is.null(test_domains) && length(test_domains >= 1)) {
    js_vars <- paste(js_vars, 'shinymixpanel.testToken = "{ test_token }";')
    js_vars <- paste(js_vars, 'shinymixpanel.testDomains = { jsonlite::toJSON(test_domains, auto_unbox = TRUE) };')
  }

  htmltools::attachDependencies(
    shiny::singleton(shiny::tags$head(shiny::tags$script(
      glue::glue(js_vars)
    ))),
    html_dependency_mixpanel()
  )
}

#' Track an event to Mixpanel
#'
#' @param event Name of the event
#' @param properties List of properties to send for this event
#' @param properties_js List of properties to be computed client-side (with JavaScript
#' in the user's browser)
#' @export
mp_track <- function(event, properties = list(), properties_js = list()) {
  if (missing(event)) {
    stop("mp_track: An `event` is required", call. = FALSE)
  }

  session <- shiny::getDefaultReactiveDomain()
  session$sendCustomMessage(
    'shinymixpanel.track',
    list(
      event = event,
      properties = properties,
      properties_js = properties_js
    )
  )
}

#' Associate all Mixpanel events to a user
#'
#' After calling `mp_userid()`, all subsequent Mixpanel events will be associated with
#' this user ID.
#'
#' @param userid A user ID to identify with Mixpanel.
#' @export
mp_userid <- function(userid) {
  if (missing(userid)) {
    stop("mp_userid: A `userid` is required", call. = FALSE)
  }
  session <- shiny::getDefaultReactiveDomain()
  session$sendCustomMessage(
    'shinymixpanel.setUserID',
    list(
      userid = userid
    )
  )
}
