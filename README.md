# 📱 InternetDesa Mobile - All-in-One App (Admin, Teknisi, & Sales)

Aplikasi mobile terpadu berbasis **Flutter (Android & iOS)** yang dirancang untuk kebutuhan operasional ISP RT/RW Net (**Internet Desa Sukorejo**). Aplikasi ini menggabungkan seluruh peran tim lapangan dan kantor (**Admin**, **Teknisi**, dan **Sales**) ke dalam satu aplikasi cerdas dengan hak akses dinamis (*Role-Based Access Control*).

---

## 🌟 Fitur Utama Berdasarkan Peran

### 1. 👑 Admin & Super Admin
* **Dashboard Finansial & Operasional**:
  * Monitoring omzet bulanan, tagihan belum lunas, total pelanggan aktif vs isolir secara realtime.
  * 5 transaksi pembayaran terbaru.
* **Manajemen Pelanggan**:
  * Pencarian cepat berdasarkan nama, ID pelanggan, nomor WhatsApp, atau username PPPoE.
  * Filter status: *Semua*, *Aktif*, *Isolir / Menunggak*.
  * Detail pelanggan lengkap: profil, kontak (Telepon & WhatsApp langsung), paket internet, kredensial PPPoE, dan data Wi-Fi.
* **Billing & Kasir Lapangan**:
  * Daftar tagihan *Unpaid* & *Paid*.
  * Pencatatan pembayaran tunai atau transfer bank (+ unggah foto bukti transfer dari kamera/galeri).
  * **Otomasi Terintegrasi**: Saat pembayaran disimpan, sistem otomatis membuka isolir di MikroTik dan mengirimkan notifikasi kuitansi PDF via WhatsApp.

### 2. 🔧 Teknisi Lapangan
* **Tiket Gangguan & Perbaikan**:
  * Daftar tiket gangguan aktif lengkap dengan tingkat prioritas (*Normal*, *High*, *Critical*).
  * Navigasi rute langsung ke titik lokasi rumah pelanggan via **Google Maps**.
  * Selesaikan tiket dengan catatan perbaikan teknisi.
* **Alat Diagnostik & Remote ONT Jarak Jauh**:
  * **Remote Reboot ONT Modem**: Eksekusi perintah reboot ONT modem pelanggan dari HP via TR-069 GenieACS atau OLT C-Data OMCI tanpa harus login ke dashboard router/OLT.
  * **Remote Ganti SSID & Password Wi-Fi**: Ubah nama Wi-Fi dan kata sandi pelanggan langsung dari HP teknisi dan otomatis disinkronkan ke modem.

### 3. 📋 Sales & Pemasaran
* **Formulir Pendaftaran Pasang Baru**:
  * Input data calon pelanggan (Nama, Nomor WhatsApp, Alamat Lengkap, dan Estimasi Panjang Dropcore).
  * Pilihan paket internet aktif dari server.
* **Fitur Hardware HP di Lapangan**:
  * **Kunci Koordinat GPS Otomatis**: Membaca latitude & longitude posisi calon pelanggan di lapangan dengan satu ketukan tombol.
  * **Unggah Foto Berkas**: Foto KTP calon pelanggan dan foto depan rumah via Kamera atau Galeri.
* **Notifikasi Tim Real-time**: Pendaftaran baru langsung otomatis masuk ke database antrean teknisi dan mengirimkan notifikasi bot ke grup Telegram tim.

---

## 🏗️ Struktur Arsitektur Kode

```text
lib/
├── config/
│   ├── app_config.dart          # Konfigurasi endpoint server & constants
│   └── theme.dart               # Tema Material 3 Cyber Blue & Dark Mode
├── models/
│   ├── user_model.dart          # Model user & role logic
│   ├── dashboard_model.dart     # Model statistik per role
│   ├── customer_model.dart      # Model data pelanggan & WiFi
│   ├── invoice_model.dart       # Model tagihan & pembayaran
│   ├── ticket_model.dart        # Model tiket gangguan & koordinat
│   └── registration_model.dart  # Model registrasi sales & paket
├── services/
│   ├── api_service.dart         # HTTP Client (Dio) + Interceptor JWT & Multipart
│   └── storage_service.dart     # Penyimpanan lokal token & sesi pengguna
├── providers/
│   ├── auth_provider.dart       # State auth & login
│   ├── dashboard_provider.dart  # State metrik beranda
│   ├── customer_provider.dart   # State data pelanggan
│   ├── invoice_provider.dart    # State billing & bayar tagihan
│   ├── ticket_provider.dart     # State tiket & alat remote teknisi
│   └── sales_provider.dart      # State registrasi sales & paket
├── screens/
│   ├── auth/                    # Layar Login & Pengaturan Server IP
│   ├── home/                    # Dynamic Bottom Navigation sesuai role
│   ├── admin/                   # Beranda Admin, List Pelanggan, Billing, Bayar Dialog
│   ├── technician/              # Tiket Teknisi, Detail Tiket, Tools Reboot & WiFi
│   ├── sales/                   # Beranda Sales & Form Pasang Baru + GPS & Foto
│   └── profile/                 # Profil Akun, Ganti Password, & Logout
└── widgets/
    ├── stat_card.dart           # Kartu indikator metrik
    ├── status_badge.dart        # Badge warna status dinamis
    └── empty_state.dart         # Tampilan data kosong yang rapi
```

---

## 🚀 Panduan Menjalankan & Build Aplikasi

### 1. Prasyarat
* Flutter SDK versi 3.2.0 atau lebih baru.
* Android Studio / VS Code dengan ekstensi Flutter & Dart.

### 2. Instalasi Dependensi
Jalankan perintah berikut di dalam direktori `internetdesa_mobile`:
```bash
flutter pub get
```

### 3. Menjalankan di Perangkat / Emulator
```bash
flutter run
```

### 4. Build APK Android Release
Untuk menghasilkan file installer `.apk` yang siap diinstal ke HP teknisi, sales, maupun admin:
```bash
flutter build apk --release
```
File APK akan berada di: `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🔐 Akun Uji Coba (Login Defaults)

| Peran | Username Contoh | Hak Akses |
|---|---|---|
| **Admin** | `admin` | Akses penuh ke semua modul: Beranda, Pelanggan, Billing, Teknisi, & Sales |
| **Teknisi** | `rudi` / `teknisi` | Tiket Lapangan, Diagnostik Remote Modem, dan Data Pelanggan |
| **Sales** | `hariyanto` / `sales` | Form Pasang Baru + GPS, Foto Berkas, & Monitoring Pendaftaran |

> Catatan: Alamat server default disetel ke `http://202.155.16.152:3000`. Jika menggunakan domain atau IP lain, cukup tekan ikon gerigi ⚙️ di pojok kanan atas layar login untuk mengubahnya kapan saja tanpa perlu mengubah kode.
