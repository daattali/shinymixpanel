mp_track_chooser <- function(event, properties) {
  if (client_unreachable()) {
    mp_track_server(event, properties)
  } else {
    mp_track_client(event, properties)
  }
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

mp_track_server <- function(event, properties = list(), userid = "", token = "") {
  mp_track_server_engine(
    event = event, properties = properties, userid = userid, token = token,
    ignore_cache = FALSE
  )
}

# ignore_cache means to only use the parameters that are passed in and not use previously stored values
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
        stop("mp_track: A `token` is required (can set it via `SHINYMIXPANEL_TOKEN` envvar)", call. = FALSE)
      }
    }
  }

  if (!ignore_cache) {
    if (is_empty(userid)) {
      if (in_shiny()) {
        userid <- session$userData$shinymixpanel_userid
      } else {
        userid <- .shinymixpanelenv$userid
      }
    }
  }

  props <- list()
  if (!ignore_cache) {
    if (in_shiny()) {
      props <- session$userData$shinymixpanel_defaultProps
    } else {
      props <- .shinymixpanelenv$defaultProps
    }
  }

  if (in_shiny()) {
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
