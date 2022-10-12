html_dependency_mixpanel <- function() {
  htmltools::htmlDependency(
    name = "shinymixpanel",
    version = packageVersion("shinymixpanel"),
    src = c(href = "shinymixpanel-assets/shinymixpanel"),
    package = "shinymixpanel",
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
