# Skrip untuk deployment ke shinyapps.io
# Dokumentasi: https://shiny.rstudio.com/articles/shinyapps.html

# Pastikan paket rsconnect terinstal
if (!require("rsconnect")) {
  install.packages("rsconnect")
  library(rsconnect)
}

# --- KONFIGURASI ---
# Anda harus membuat akun di https://www.shinyapps.io/
# Kemudian dapatkan token dan secret dari dashboard shinyapps.io
# Ganti nilai di bawah ini dengan kredensial Anda:

# setAccountInfo(name='NAMA_AKUN_ANDA',
#               token='TOKEN_ANDA',
#               secret='SECRET_ANDA')

# --- DEPLOYMENT ---
# Jalankan baris berikut di console R untuk men-deploy aplikasi:

# deployApp(appDir = ".", 
#           appName = "InaEpiTools", 
#           appTitle = "InaEpiTools: Analisis Epidemiologi Indonesia")

message("Skrip ini hanya panduan. Silakan uncomment dan isi kredensial Anda untuk men-deploy.")
