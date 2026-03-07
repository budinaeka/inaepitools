# Panduan Deployment dengan Portainer.io

Dokumen ini menjelaskan cara men-deploy aplikasi **InaEpiTools** menggunakan [Portainer](https://www.portainer.io/), sebuah platform manajemen Docker berbasis web.

## Prasyarat

1. **Portainer** sudah terinstal dan berjalan.
2. **Docker** sudah terinstal di server/komputer tujuan.
3. Kode sumber aplikasi ini sudah tersedia di repository Git (GitHub/GitLab/Bitbucket) atau file `docker-compose.yml` sudah siap.

---

## Metode 1: Deploy Menggunakan Git (Recommended)

Metode ini memungkinkan Portainer untuk secara otomatis menarik kode terbaru dan membangun ulang container saat ada perubahan di repository.

1. Login ke dashboard Portainer Anda.
2. Pilih **Environment** (biasanya `local` atau nama server Anda).
3. Klik menu **Stacks** di sidebar kiri.
4. Klik tombol **+ Add stack** di pojok kanan atas.
5. Isi form sebagai berikut:
   - **Name**: `inaepitools` (atau nama lain yang diinginkan, huruf kecil semua).
   - **Build method**: Pilih `Repository`.
   - **Repository URL**: Masukkan URL repository Git proyek ini (contoh: `https://github.com/username/InaEpiTools.git`).
   - **Repository reference**: `refs/heads/main` (atau `master`, sesuaikan dengan branch utama Anda).
   - **Compose path**: `docker-compose.yml` (biarkan default jika file ada di root).
   - **Automatic updates** (Opsional): Aktifkan jika ingin Portainer mengecek perubahan secara berkala.
6. Scroll ke bawah dan klik tombol **Deploy the stack**.

Portainer akan melakukan proses *pull* code, *build* image (jika belum ada), dan menjalankan container. Proses ini mungkin memakan waktu beberapa menit tergantung kecepatan internet dan spesifikasi server.

---

## Metode 2: Deploy Menggunakan Web Editor (Manual)

Gunakan metode ini jika Anda tidak ingin menghubungkan Portainer ke Git, atau hanya ingin copy-paste konfigurasi.

1. Login ke dashboard Portainer.
2. Pilih **Environment** -> **Stacks** -> **+ Add stack**.
3. Isi form:
   - **Name**: `inaepitools`.
   - **Build method**: Pilih `Web editor`.
4. Pada kolom editor, masukkan konten dari file `docker-compose.yml` berikut:

   ```yaml
   version: '3.8'

   services:
     inaepitools:
       # Jika Anda belum memiliki image di registry, gunakan build context
       # Pastikan Anda mengupload file proyek jika menggunakan metode build manual di server,
       # atau lebih mudah gunakan image yang sudah dibuild jika ada.
       # Untuk metode Web Editor tanpa Git, disarankan menggunakan image yang sudah di-push.
       # Contoh: image: ghcr.io/username/inaepitools:latest
       
       # Jika menggunakan Git (Metode 1), baris 'build: .' akan bekerja.
       build: .
       
       container_name: inaepitools
       restart: unless-stopped
       ports:
         - "3838:3838"
       volumes:
         - shiny_logs:/var/log/shiny-server

   volumes:
     shiny_logs:
   ```

   > **Catatan**: Jika Anda menggunakan metode Web Editor tanpa koneksi Git, Portainer mungkin tidak bisa melakukan `build: .` kecuali konteks filenya tersedia. **Sangat disarankan menggunakan Metode 1 (Git)** atau pastikan Anda sudah memiliki image Docker yang siap pakai (ganti `build: .` dengan `image: nama_image_anda`).

5. Klik **Deploy the stack**.

---

## Akses Aplikasi

Setelah status stack menjadi **Running** (berwarna hijau):

- Buka browser dan akses: `http://IP-SERVER-ANDA:3838/`
- Jika di local, akses: `http://localhost:3838/`

## Troubleshooting

Jika aplikasi tidak berjalan:

1. Buka menu **Containers** di Portainer.
2. Klik ikon **Logs** (kertas list) pada container `inaepitools`.
3. Periksa pesan error. Masalah umum meliputi:
   - Port `3838` sudah digunakan oleh aplikasi lain. Solusi: Ganti mapping port di `docker-compose.yml` (misal `"8080:3838"`).
   - Gagal build karena memori tidak cukup (R package compilation butuh RAM).
