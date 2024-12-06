library(shiny)

# Add error handling for source files
tryCatch({
    basic_plots_ui <- source("basic_plots_app.R")$value$ui
    volcano_ui <- source("volcano_app.R")$value$ui
}, error = function(e) {
    stop("Error loading UI files: ", e$message)
})

ui <- navbarPage(
    "Data Visualization Suite",
    
    tabPanel("Basic Plots",
             basic_plots_ui
    ),
    
    tabPanel("Advanced Plots",
             volcano_ui
    )
)

server <- function(input, output, session) {
    tryCatch({
        source("basic_plots_app.R")$value$server(input, output, session)
        source("volcano_app.R")$value$server(input, output, session)
    }, error = function(e) {
        stop("Error loading server files: ", e$message)
    })
}

shinyApp(ui = ui, server = server)