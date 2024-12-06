# Data Visualization Suite

A comprehensive R Shiny application for statistical analysis and data visualization.

## Features

### Basic Plots
- Multiple plot types (Violin, Box, Bar, Scatter)
- Statistical tests
- Customizable plot parameters
- High-resolution plot downloads
- Multiple variable analysis

### Advanced Plots
- Volcano Plot for differential expression analysis
- Customizable thresholds
- Interactive labeling
- Publication-ready figures

## File Structure
- `app.R`: Main application entry point
- `basic_plots_app.R`: Basic visualization functionality
- `volcano_app.R`: Advanced volcano plot functionality
- `Dockerfile`: Docker configuration
- `requirements.txt`: R package dependencies

## Example Datasets
- Basic Plots: [Example Dataset](https://drive.google.com/file/d/1o9w_ZXecKibmNlf8Dl9QjHiw0NMScsI3/view?usp=sharing)
- Volcano Plot: Requires CSV file with columns including 'logFC' and 'P.Value'

## Local Development
To run the app locally:
1. Install R and required packages
2. Run `shiny::runApp('app.R')`

## Developer
Developed by Dr Babajan Banaganapalli
Email: bioinformatics.bb@gmail.com
