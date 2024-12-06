library(shiny)
library(ggplot2)
library(ggrepel)

ui <- fluidPage(
    titlePanel("Advanced Data Visualization - Volcano Plot"),
    
    sidebarLayout(
        sidebarPanel(
            # Input format instructions
            tags$div(
                style = "border: 1px solid #ddd; padding: 10px; margin-bottom: 15px; background-color: #f9f9f9;",
                tags$h4("Input Format Instructions:"),
                tags$p("CSV file should contain three columns in this order:"),
                tags$ul(
                    tags$li(tags$b("Column 1: "), "Names (any header)"),
                    tags$li(tags$b("Column 2: "), "logFC"),
                    tags$li(tags$b("Column 3: "), "P.Value")
                ),
                tags$p("Example format:"),
                tags$pre(
                    "Name,logFC,P.Value\n",
                    "Sample1,2.7552,6.01E-14\n",
                    "Sample2,0.9973,8.17E-09\n",
                    "Sample3,1.7747,2.28E-07"
                )
            ),
            
            fileInput("volcano_file", "Upload CSV File", accept = c(".csv")),
            
            numericInput("volcano_pvalue", "P-value Threshold:", 
                        value = 0.05, min = 0, max = 1, step = 0.01),
            numericInput("volcano_fc", "Log2 FC Threshold:", 
                        value = 0.1, min = 0, max = 5, step = 0.1),
            numericInput("volcano_top_n", "Number of Top Labels:", 
                        value = 15, min = 1, max = 50),
            
            # Add axis controls
            numericInput("x_min", "X-axis Minimum:", value = -4, step = 0.5),
            numericInput("x_max", "X-axis Maximum:", value = 4, step = 0.5),
            numericInput("y_min", "Y-axis Minimum:", value = 0, step = 1),
            numericInput("y_max", "Y-axis Maximum:", value = 20, step = 1),
            
            textInput("volcano_title", "Plot Title:", value = "(S)NE vs (S)CN"),
            numericInput("volcano_point_size", "Point Size:", value = 8, min = 1, max = 20)
        ),
        
        mainPanel(
            plotOutput("volcano_plot", height = "600px"),
            verbatimTextOutput("volcano_debug"),
            tags$hr(),
            tags$p("Developed by Dr Babajan Banaganapalli"),
            tags$p("Email: bioinformatics.bb@gmail.com")
        )
    )
)

server <- function(input, output, session) {
    data <- reactive({
        req(input$volcano_file)
        tryCatch({
            results <- read.csv(input$volcano_file$datapath)
            
            # Check if file has at least 3 columns
            if(ncol(results) < 3) {
                stop("File must contain at least 3 columns")
            }
            
            # Rename columns to standard names
            name_col <- colnames(results)[1]
            colnames(results)[2:3] <- c("logFC", "P.Value")
            
            # Set color based on thresholds
            results$Color <- with(results, 
                ifelse(P.Value < input$volcano_pvalue & logFC > input$volcano_fc, "Significant Up",
                       ifelse(P.Value < input$volcano_pvalue & logFC < -input$volcano_fc, 
                              "Significant Down", "Not Significant")))
            results$Color <- factor(results$Color, 
                                  levels = c("Significant Up", "Significant Down", "Not Significant"))
            
            # Calculate alpha
            results$Alpha <- sqrt(abs(results$logFC)) / max(sqrt(abs(results$logFC)))
            
            return(list(results = results, name_col = name_col))
        }, error = function(e) {
            showNotification(paste("Error:", e$message), type = "error")
            return(NULL)
        })
    })
    
    output$volcano_debug <- renderPrint({
        if(is.null(data())) {
            cat("Waiting for data...\n")
            return()
        }
        cat("Data loaded successfully\n")
        cat("Number of rows:", nrow(data()$results), "\n")
        cat("First few rows:\n")
        print(head(data()$results[, 1:3]))
    })
    
    output$volcano_plot <- renderPlot({
        req(data())
        results <- data()$results
        name_col <- data()$name_col
        
        # Select top metabolites
        top_metabolites <- results[order(results$P.Value), ][1:input$volcano_top_n, ]
        
        ggplot(results, aes(x = logFC, y = -log10(P.Value), fill = Color)) +
            geom_point(aes(alpha = Alpha), shape = 21, 
                      color = "black", size = input$volcano_point_size) +
            scale_fill_manual(values = c("Significant Up" = "#2F5597", 
                                       "Significant Down" = "green", 
                                       "Not Significant" = "grey30")) +
            theme_minimal() +
            labs(title = input$volcano_title, 
                 x = "Log2 FC", 
                 y = "-Log10 P-value") +
            theme(legend.position = "none",
                  plot.title = element_text(size = 22, face = "bold"),
                  axis.title = element_text(size = 22),
                  axis.text = element_text(size = 22),
                  axis.line = element_line(size = 1)) +
            xlim(c(input$x_min, input$x_max)) +
            ylim(c(input$y_min, input$y_max)) +
            geom_vline(xintercept = 0, linetype = "longdash", 
                      color = "black", size = 0.9) +
            geom_hline(yintercept = -log10(input$volcano_pvalue), 
                      linetype = "longdash", color = "black", size = 0.9) +
            geom_text_repel(data = top_metabolites, 
                           aes(label = !!sym(name_col)), 
                           color = "black", size = 5,
                           max.overlaps = Inf)
    })
}

list(
    ui = ui,
    server = server
) 