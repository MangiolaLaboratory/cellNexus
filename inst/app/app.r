library(cellNexus)
library(shiny)

app <- create_interface_app(ui_choices, return_as_list = TRUE)

shinyApp(ui = app$ui, server = app$server)