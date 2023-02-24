#' Set up a Shiny app to use Mixpanel for event tracking
#'
#' Call this function in a Shiny app's UI in order to initialize Mixpanel on the page. A project
#' token is required, which can either be provided using the `token` parameter or with the
#' `SHINYMIXPANEL_TOKEN` environment variable.\cr\cr
#' See the full \href{https://github.com/daattali/shinymixpanel#readme}{README} on
#' GitHub for more details.\cr\cr
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
#' @param track_client Whether to allow tracking via the web browser (client). Default is `TRUE`.
#' Note that an ad blocker may restrict the ability to use client-side tracking. See the section below on
#' "Client-side vs server-side tracking".
#' @param track_server Whether to allow tracking via R API calls (server). Default is `TRUE`.
#' See the section below on "Client-side vs server-side tracking".
#' @section Client-side vs server-side tracking:
#' When calling [mp_track()] inside a Shiny app, events data can be sent to Mixpanel in one of two ways: using client-side
#' or server-side tracking. When calling [mp_track()] outside of Shiny, server-side is always used.\cr\cr
#' **Client-side tracking** is done via the user's browser (with Javascript). This is
#' generally the preferred way to use Mixpanel, since Mixpanel automatically collects some additional information
#' from the web browser. However, some users may disable tracking in their browser (for example using an ad blocker),
#' and for these users it's not possible to perform client-side tracking.\cr\cr
#' With **server-side tracking**, \{shinymixpanel\} will send events to Mixpanel via R API calls. The benefit of
#' server-side tracking is that it's unaffected by ad blockers. However, when using server-side tracking, Mixpanel
#' does not automatically collect the same attributes that it does in client-side. To compensate for that,
#' \{shinymixpanel\} will try to detect some browser data and send it along with any event: user's operating system,
#' browser name, screen size, and current URL (these are a subset of the attributes that client-side tracking detects).\cr\cr
#' The parameters `track_client` and `track_server` of [mp_init()] are both set to `TRUE` by default, and they can be used to
#' disable one of the two tracking methods:
#'   - If both are set to `FALSE`, then Mixpanel tracking is essentially turned off
#'   - If only `track_client` is `TRUE`, then \{shinymixpanel\} will only attempt to use client-side tracking.
#'   Note that this means that if the user has an ad blocker, then no events will be tracked.
#'   - If only `track_server` is `TRUE`, then all event tracking will be done with server-side tracking.
#'   - If both are `TRUE`, then \{shinymixpanel\} will prioritize trying to use client-side tracking. If an ad
#'   blocker is present, then it will automatically switch to using server-side tracking.
#' @section Using a test Mixpanel project for testing/development:
#' While developing or testing your Shiny app, you can use the `SHINYMIXPANEL_DISABLE` envvar
#' to disable Mixpanel tracking. However, sometimes you may want to still have tracking but send the
#' data to a different "test" project rather than the real production Mixpanel project. The \{shinymixpanel\}
#' package supports this usecase via the `test_token` and `test_domains` parameters.\cr\cr
#' When both of these parameters are provided, if the Shiny app is in a domain that's listed in the
#' `test_domains` list, then data will be sent to the `test_token` project instead.
#' Note that the domains in `test_domains` are assumed to be suffixes. This means that if you provide
#' `"example.com"` as a test domain, then any user on `example.com` or `test.example.com` will use
#' the test project.\cr\cr
#' By default, `test_domains` is set to `127.0.0.1` and `localhost`, which means that if you provide a
#' `test_token`, that project will receive all data while you're running the Shiny app locally.
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
    track_client = TRUE, track_server = TRUE
) {
  if (!track_client && !track_server) {
    return()
  }

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
  js_vars <- paste(js_vars, 'shinymixpanel.trackClient = { jsonlite::toJSON(track_client, auto_unbox = TRUE) };')

  htmltools::attachDependencies(
    shiny::singleton(shiny::tags$head(shiny::tags$script(
      glue::glue(js_vars)
    ))),
    html_dependency_mixpanel()
  )
}
