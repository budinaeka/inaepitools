# InaEpiTools

Aplikasi R Shiny untuk analisis epidemiologi di Indonesia.

## Fitur
- **Visualisasi Tren**: Grafik interaktif menggunakan Plotly.
- **Analisis Deskriptif**: Ringkasan statistik dan histogram otomatis.
- **Kalkulator Epidemiologi**:
  - Odds Ratio (OR) & Relative Risk (RR)
  - Ukuran Sampel (Sample Size)
  - Uji Diagnostik (Sensitivitas/Spesifisitas)
- **Uji Asosiasi**: Chi-Square, T-Test, ANOVA, Korelasi (deteksi otomatis).
- **Peta Sebaran (GIS)**: Visualisasi titik kasus pada peta interaktif.

## Cara Instalasi Lokal

1. Pastikan R dan RStudio terinstal.
2. Jalankan skrip instalasi paket:
   ```r
   source("install_packages.R")
   ```
3. Jalankan aplikasi:
   ```r
   source("run.R")
   ```

## Deployment ke shinyapps.io

1. Buat akun di [shinyapps.io](https://www.shinyapps.io/).
2. Buka file `deploy.R`.
3. Masukkan Token dan Secret yang didapatkan dari dashboard shinyapps.io.
4. Jalankan perintah `rsconnect::deployApp()`.

## Deployment dengan Portainer

Untuk panduan lengkap deployment menggunakan Portainer (Stack/Git), silakan baca file:
[DEPLOY_PORTAINER.md](DEPLOY_PORTAINER.md)

## Deployment dengan Docker (Self-Hosted)

Aplikasi ini sudah dilengkapi dengan `Dockerfile` untuk deployment di server sendiri.

### 1. Build Image
Jalankan perintah berikut di terminal (pastikan Docker Desktop sudah berjalan):
```bash
docker build -t inaepitools .
```

### 2. Run Container
Jalankan container di port 3838:
```bash
docker run -d -p 3838:3838 --name inaepitools inaepitools
```

Akses aplikasi di browser: `http://localhost:3838/`

### Catatan Dependensi Sistem (Linux)
Jika Anda men-deploy di server Linux tanpa Docker (misal Ubuntu), pastikan library sistem berikut terinstal untuk mendukung paket `sf` dan `leaflet`:
```bash
sudo apt-get install -y libgdal-dev libgeos-dev libproj-dev libudunits2-dev libssl-dev libxml2-dev libcurl4-openssl-dev
```
