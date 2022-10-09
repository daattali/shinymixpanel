# shinymixpanel
Track user data with Mixpanel in Shiny apps

```r
library(shiny)

ui <- fluidPage(
  use_mixpanel(
    token
    userid
  ),
  actionButton("go","go"),
  textInput("event","event", "something happened")
)

server <- function(input, output, session) {
  observeEvent(input$go,{
    track(input$event, list("ff"="45","browser"="chrom", distinct_id ="ggg"))
  })
}

shinyApp(ui, server)
```
