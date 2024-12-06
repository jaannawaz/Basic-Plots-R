# Use the official R image
FROM rocker/shiny:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages with specific version
RUN R -e "install.packages(c('rstatix', 'ggpubr', 'tidyr', 'dplyr', 'ggplot2', 'gridExtra'), \
    repos='https://cloud.r-project.org/', \
    dependencies=TRUE)"

# Copy the app files
COPY app.R /usr/local/src/app.R

# Expose the port
EXPOSE 3838

# Run the app
CMD ["R", "-e", "shiny::runApp('/usr/local/src/app.R', host='0.0.0.0', port=3838)"] 