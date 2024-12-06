# Data Visualization Shiny App

A Shiny application for statistical analysis and data visualization.

## Features
- Multiple plot types (Violin, Box, Bar, Scatter)
- Statistical tests
- Customizable plot parameters
- High-resolution plot downloads
- Multiple variable analysis

## Deployment Instructions

### Prerequisites
- Docker installed on your system
- A Render account

### Steps to Deploy on Render

1. Fork or clone this repository
2. Log in to your Render account
3. Create a new Web Service
4. Connect to your repository
5. Select "Docker" as the environment
6. Configure the service:
   - Build Command: `docker build -t shiny-app .`
   - Start Command: `docker run -p 3838:3838 shiny-app`
7. Click "Create Web Service"

## Local Development
To run the app locally:
1. Install R and required packages
2. Run `shiny::runApp('app.R')`

## File Structure
- `app.R`: Main application code
- `Dockerfile`: Docker configuration
- `requirements.txt`: R package dependencies

## Developer
Developed by Dr Babajan Banaganapalli
Email: bioinformatics.bb@gmail.com
