# Base R Shiny image
FROM rocker/shiny:latest

# Install system libraries required by R packages
# Added: libfontconfig1-dev, libharfbuzz-dev, libfribidi-dev, libfreetype6-dev, libpng-dev, libtiff5-dev, libjpeg-dev
# These are often required by 'systemfonts', 'textshaping', 'ragg' which are dependencies of modern ggplot2/pkgdown
RUN apt-get update && apt-get install -y \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libudunits2-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R packages separately to isolate failures
# 1. Core packages
RUN R -e "install.packages(c('shiny', 'bslib', 'dplyr', 'ggplot2', 'DT', 'plotly', 'readxl', 'rmarkdown', 'knitr', 'e1071'), repos='https://cran.rstudio.com/')"

# 2. Spatial packages (heavy dependencies)
RUN R -e "install.packages(c('sf', 'leaflet'), repos='https://cran.rstudio.com/')"

# 3. EpiR and its dependencies (often fails due to survival/Exact/etc)
# Install dependencies explicitly first to ensure they are present
RUN R -e "install.packages(c('survival', 'BiasedUrn', 'pROC'), repos='https://cran.rstudio.com/')"
RUN R -e "install.packages('epiR', repos='https://cran.rstudio.com/')"

# Remove default shiny app
RUN rm -rf /srv/shiny-server/*

# Copy application code
COPY app.R /srv/shiny-server/
COPY dummy_pmk.csv /srv/shiny-server/

# Copy custom configuration
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Ensure permissions are correct
RUN chown -R shiny:shiny /srv/shiny-server

# Expose port 3838
EXPOSE 3838

# Run shiny server
CMD ["/usr/bin/shiny-server"]
