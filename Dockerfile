# Base R Shiny image
FROM rocker/shiny:latest

# Install system libraries required by R packages (e.g., sf, leaflet)
# - libgdal-dev, libgeos-dev, libproj-dev, libudunits2-dev: Required for sf/spatial packages
# - libssl-dev, libxml2-dev, libcurl4-openssl-dev: Common R package dependencies
RUN apt-get update && apt-get install -y \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
# Using a fixed CRAN mirror for reproducibility
RUN R -e "install.packages(c( \
    'shiny', \
    'bslib', \
    'dplyr', \
    'ggplot2', \
    'DT', \
    'plotly', \
    'readxl', \
    'epiR', \
    'sf', \
    'leaflet', \
    'rmarkdown', \
    'knitr', \
    'e1071' \
), repos='https://cran.rstudio.com/')"

# Remove default shiny app
RUN rm -rf /srv/shiny-server/*

# Copy application code
COPY app.R /srv/shiny-server/

# Copy install script just in case, though packages are already installed
COPY install_packages.R /srv/shiny-server/

# Expose port 3838
EXPOSE 3838

# Run shiny server
CMD ["/usr/bin/shiny-server"]
