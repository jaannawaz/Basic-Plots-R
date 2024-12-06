# Use the official R image
FROM rocker/shiny:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
COPY requirements.txt /usr/local/src/requirements.txt
RUN R -e "install.packages(readLines('/usr/local/src/requirements.txt'), repos='http://cran.rstudio.com/')"

# Copy the app files
COPY app.R /usr/local/src/app.R

# Expose the port
EXPOSE 3838

# Run the app
CMD ["R", "-e", "shiny::runApp('/usr/local/src/app.R', host='0.0.0.0', port=3838)"] 