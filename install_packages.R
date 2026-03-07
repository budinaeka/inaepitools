# Skrip untuk menginstal paket-paket yang diperlukan untuk InaEpiTools
required_packages <- c(
  "shiny",
  "bslib",
  "dplyr",
  "ggplot2",
  "DT",
  "plotly",
  "readxl",      # Untuk membaca file Excel
  "epiR",        # Untuk analisis epidemiologi (OR, RR, Sample Size, Diagnostic Test)
  "sf",          # Untuk data spasial (GIS)
  "leaflet",     # Untuk peta interaktif
  "rmarkdown",   # Untuk laporan otomatis
  "knitr",       # Dependensi laporan
  "e1071"        # Untuk statistik deskriptif (skewness, kurtosis)
)

# Cek paket yang belum terinstal
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

# Instal paket yang belum ada
if(length(new_packages)) {
  message("Menginstal paket: ", paste(new_packages, collapse = ", "))
  install.packages(new_packages)
} else {
  message("Semua paket yang diperlukan sudah terinstal.")
}
