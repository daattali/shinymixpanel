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
