library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(rstatix)
library(ggpubr)
library(gridExtra)

ui <- fluidPage(
    titlePanel("Data Visualization"),
    
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "Upload CSV File", accept = c(".csv")),
            
            selectInput("plot_type", "Select Plot Type:",
                       choices = list(
                           "Violin Plot" = "violin",
                           "Box Plot" = "box",
                           "Bar Plot" = "bar",
                           "Scatter Plot" = "scatter"
                       )),
            
            uiOutput("var_select"),
            
            selectInput("stat_test", "Statistical Test:",
                       choices = list(
                           "T-test" = "t.test",
                           "Wilcoxon" = "wilcox.test",
                           "ANOVA" = "anova",
                           "Kruskal-Wallis" = "kruskal"
                       )),
            
            # Plot customization
            conditionalPanel(
                condition = "input.plot_type == 'violin'",
                sliderInput("violin_width", "Violin Width:",
                           min = 0.3, max = 2, value = 0.8, step = 0.1),
                sliderInput("violin_alpha", "Violin Transparency:",
                           min = 0, max = 1, value = 0.7, step = 0.1)
            ),
            
            # Axis customization
            numericInput("y_min", "Y-axis Minimum:", value = NA),
            numericInput("y_max", "Y-axis Maximum:", value = NA),
            numericInput("y_breaks", "Y-axis Break Step:", value = NA),
            
            numericInput("axis_label_size", "Axis Label Size:", 
                        value = 12, min = 8, max = 20),
            numericInput("axis_text_size", "Axis Text Size:", 
                        value = 10, min = 6, max = 18),
            
            tags$hr(),
            tags$h4("Download Options"),
            numericInput("download_width", "Download Width (inches):", 
                        value = 10, min = 5, max = 20),
            numericInput("download_height", "Download Height (inches):", 
                        value = 8, min = 4, max = 16),
            numericInput("download_dpi", "Resolution (DPI):", 
                        value = 300, min = 72, max = 600),
            selectInput("download_format", "File Format:",
                       choices = list(
                           "PNG" = "png",
                           "PDF" = "pdf",
                           "TIFF" = "tiff"
                       )),
            downloadButton("downloadPlot", "Download Plot")
        ),
        
        mainPanel(
            plotOutput("plot", height = "600px"),
            verbatimTextOutput("stats")
        )
    )
)

server <- function(input, output, session) {
    # Read data
    data <- reactive({
        req(input$file)
        df <- read.csv(input$file$datapath)
        df[[1]] <- factor(df[[1]])  # Convert first column to factor
        return(df)
    })
    
    # Dynamic variable selection
    output$var_select <- renderUI({
        req(data())
        vars <- names(data())[-1]
        selectInput("variables", 
                   "Select Variables:", 
                   choices = vars,
                   multiple = TRUE,
                   selected = vars[1])
    })
    
    # Create plot
    output$plot <- renderPlot({
        req(data(), input$variables, input$plot_type)
        
        plots <- lapply(input$variables, function(var) {
            df <- data()
            
            p <- ggplot(df, aes(x = df[[1]], y = .data[[var]], fill = df[[1]])) +
                labs(x = "Group", y = var, title = var)
            
            # Base plot
            if(input$plot_type == "violin") {
                p <- p + 
                    geom_violin(trim = FALSE, 
                               alpha = input$violin_alpha,
                               width = input$violin_width) +
                    geom_boxplot(width = 0.2, alpha = 0.7, fill = "white")
            } else if(input$plot_type == "box") {
                p <- p + geom_boxplot(alpha = 0.7)
            } else if(input$plot_type == "bar") {
                p <- p + 
                    stat_summary(fun = mean, geom = "bar") +
                    stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2)
            } else if(input$plot_type == "scatter") {
                p <- p + 
                    geom_point(aes(color = df[[1]]), alpha = 0.6) +
                    geom_smooth(method = "lm", se = TRUE)
            }
            
            # Add statistical comparisons
            if(input$plot_type != "scatter") {
                group_levels <- levels(df[[1]])
                if(length(group_levels) >= 2) {
                    p <- p + stat_compare_means(
                        comparisons = combn(group_levels, 2, simplify = FALSE),
                        method = input$stat_test,
                        label = "p.format"
                    )
                }
            }
            
            # Set axis limits if provided and valid
            if(!is.na(input$y_min) && !is.na(input$y_max)) {
                p <- p + coord_cartesian(
                    ylim = c(input$y_min, input$y_max)
                )
            }
            
            # Add breaks if provided and valid
            if(!is.na(input$y_breaks)) {
                y_min <- if(is.na(input$y_min)) min(df[[var]], na.rm = TRUE) else input$y_min
                y_max <- if(is.na(input$y_max)) max(df[[var]], na.rm = TRUE) else input$y_max
                p <- p + scale_y_continuous(
                    breaks = seq(y_min, y_max, by = input$y_breaks)
                )
            }
            
            # Theme and colors
            p <- p + 
                theme_classic() +
                scale_fill_brewer(palette = "Set2") +
                scale_color_brewer(palette = "Set2") +
                theme(
                    axis.text = element_text(size = input$axis_text_size),
                    axis.title = element_text(size = input$axis_label_size),
                    legend.position = "top",
                    plot.margin = margin(t = 40, r = 20, b = 20, l = 20, unit = "pt")
                )
            
            return(p)
        })
        
        if(length(plots) > 1) {
            grid.arrange(grobs = plots, ncol = 2)
        } else {
            plots[[1]]
        }
    })
    
    # Statistical summary
    output$stats <- renderPrint({
        req(data(), input$variables)
        df <- data()
        
        for(var in input$variables) {
            cat("\nAnalysis for", var, ":\n")
            cat("\nSummary Statistics:\n")
            print(df %>%
                  group_by(across(1)) %>%
                  summarise(
                      n = n(),
                      mean = mean(get(var), na.rm = TRUE),
                      sd = sd(get(var), na.rm = TRUE),
                      se = sd/sqrt(n)
                  ))
        }
    })
    
    # Download handler
    output$downloadPlot <- downloadHandler(
        filename = function() {
            paste0("plot_", format(Sys.time(), "%Y%m%d_%H%M%S"), 
                   ".", input$download_format)
        },
        content = function(file) {
            # Recreate the plot for high resolution
            p <- NULL
            
            if(length(input$variables) > 1) {
                # For multiple plots
                plots <- lapply(input$variables, function(var) {
                    df <- data()
                    
                    p <- ggplot(df, aes(x = df[[1]], y = .data[[var]], 
                                      fill = df[[1]])) +
                        labs(x = "Group", y = var, title = var)
                    
                    # Add plot elements based on type
                    if(input$plot_type == "violin") {
                        p <- p + 
                            geom_violin(trim = FALSE, 
                                      alpha = input$violin_alpha,
                                      width = input$violin_width) +
                            geom_boxplot(width = 0.2, alpha = 0.7, 
                                       fill = "white")
                    } else if(input$plot_type == "box") {
                        p <- p + geom_boxplot(alpha = 0.7)
                    } else if(input$plot_type == "bar") {
                        p <- p + 
                            stat_summary(fun = mean, geom = "bar") +
                            stat_summary(fun.data = mean_se, 
                                       geom = "errorbar", width = 0.2)
                    } else if(input$plot_type == "scatter") {
                        p <- p + 
                            geom_point(aes(color = df[[1]]), alpha = 0.6) +
                            geom_smooth(method = "lm", se = TRUE)
                    }
                    
                    # Add statistical comparisons
                    if(input$plot_type != "scatter") {
                        group_levels <- levels(df[[1]])
                        if(length(group_levels) >= 2) {
                            p <- p + stat_compare_means(
                                comparisons = combn(group_levels, 2, 
                                                  simplify = FALSE),
                                method = input$stat_test,
                                label = "p.format"
                            )
                        }
                    }
                    
                    # Theme and colors
                    p <- p + 
                        theme_classic() +
                        scale_fill_brewer(palette = "Set2") +
                        scale_color_brewer(palette = "Set2") +
                        theme(
                            axis.text = element_text(size = input$axis_text_size),
                            axis.title = element_text(size = input$axis_label_size),
                            legend.position = "top",
                            plot.margin = margin(t = 40, r = 20, b = 20, l = 20, 
                                              unit = "pt")
                        )
                    
                    return(p)
                })
                
                # Arrange multiple plots
                p <- gridExtra::arrangeGrob(grobs = plots, ncol = 2)
            } else {
                # For single plot
                p <- plots[[1]]
            }
            
            # Save with high resolution
            ggsave(file, plot = p,
                   width = input$download_width,
                   height = input$download_height,
                   dpi = input$download_dpi,
                   device = input$download_format)
        }
    )
}

shinyApp(ui = ui, server = server)