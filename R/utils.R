html_dependency_mixpanel <- function() {
  htmltools::htmlDependency(
    name = "shinymixpanel",
    version = packageVersion("shinymixpanel"),
    src = c(href = "shinymixpanel-assets/shinymixpanel"),
    package = "shinymixpanel",
    script = c("js/shinymixpanel.js")
  )
}

list_to_null <- function(x) {
  if (!is.null(x) && length(x) == 0) NULL else x
}
