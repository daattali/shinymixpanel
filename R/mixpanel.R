# If test_token is supplied then test_domains must also be supplied. domains are treated as suffixes
use_mixpanel <- function(token = NULL, userid = NULL, options = NULL, test_token = NULL, test_domains = NULL) {
  if (is.null(token)) {
    token <- Sys.getenv("MIXPANEL_R_TOKEN", "")
    if (token == "") {
      stop("Cannot initialize mixpanel without a project token", call. = FALSE)
    }
  }
  dep <- htmltools::htmlDependency(
    "mixpanel",
    utils::packageVersion(PACKAGE_NAME),
    src = c(href = "lca-assets/lca/js"),
    package = PACKAGE_NAME,
    script = "lca_mixpanel.js"
  )

  if (!is.null(options) && length(options) == 0) {
    options <- NULL
  }

  js_vars <- 'shinymixpanel.token = "{ token }";'

  options <- jsonlite::toJSON(options, auto_unbox = TRUE)
  js_vars <- paste(js_vars, 'shinymixpanel.options = { options };')

  if (!is.null(userid)) {
    js_vars <- paste(js_vars, 'shinymixpanel.userid = "{ userid }";')
  }
  if (!is.null(test_token) && !is.null(test_domains) && length(test_domains >= 1)) {
    test_domains <- jsonlite::toJSON(test_domains, auto_unbox = TRUE)
    js_vars <- paste(js_vars, 'shinymixpanel.testToken = "{ test_token }";')
    js_vars <- paste(js_vars, 'shinymixpanel.testDomains = { test_domains };')
  }

  htmltools::attachDependencies(
    shiny::singleton(shiny::tags$head(shiny::tags$script(
      glue::glue(js_vars)
    ))),
    dep
  )
}

track <- function(event, properties = list()) {
  session <- shiny::getDefaultReactiveDomain()
  session$sendCustomMessage('shinymixpanel.track', list(event = event, properties = properties))
}
