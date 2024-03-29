html_dependency_mixpanel <- function() {
  htmltools::htmlDependency(
    name = "shinymixpanel-binding",
    version = as.character(utils::packageVersion("shinymixpanel")),
    package = "shinymixpanel",
    src = "assets/shinymixpanel",
    script = c("js/shinymixpanel.js")
  )
}

empty_to_null <- function(x) {
  if (is.null(x)) {
    NULL
  } else if (length(x) == 0) {
    NULL
  } else if (length(x) == 1 && is.character(x) && x == "") {
    NULL
  } else {
    x
  }
}

is_empty <- function(x) {
  is.null(empty_to_null(x))
}

in_shiny <- function() {
  session <- shiny::getDefaultReactiveDomain()
  !is.null(session)
}

client_unreachable <- function() {
  if (in_shiny()) {
    session <- shiny::getDefaultReactiveDomain()
    !is.null(session$userData$shinymixpanel_unreachable) &&
      session$userData$shinymixpanel_unreachable
  } else {
    return(TRUE)
  }
}
