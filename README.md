# shinymixpanel

**This package is a work in progress**

Track user data with Mixpanel in Shiny apps

```r
library(shiny)
library(shinymixpanel)

mixpanel_token <- "PROJECT_TOKEN_HERE"

ui <- fluidPage(
  mp_init(mixpanel_token, default_properties_js = list(size = "screen.width")),
  actionButton("send", "send"),
  selectInput("event_name", "Event name", c("sign up", "navigate", "click")),
  textInput("prop", "Property text to send with event", "Some text")
)

server <- function(input, output, session) {
  observeEvent(input$send,{
    mp_track(
      input$event_name,
      list(prop = input$prop, shiny_version = as.character(packageVersion("shiny")))
    )
  })
}

shinyApp(ui, server)
```

## Support for both client-side API and server-side API

## Automatically switch to server-side if Mixpanel is blocked on the client-side and send browser info


