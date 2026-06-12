# Jadwal Sholat App

Aplikasi Flutter sederhana untuk menampilkan jadwal sholat berdasarkan lokasi pengguna, dengan pengingat sebelum waktu sholat masuk.

Fokus aplikasi ini bukan menjadi aplikasi Islami yang penuh fitur, tetapi menjadi alat praktis untuk menjawab pertanyaan sederhana:

> “Sekarang sudah dekat waktu sholat atau belum?”

## Tujuan

Aplikasi ini dibuat karena tidak semua tempat terdengar suara adzan dengan jelas. Pengguna tetap bisa mengetahui waktu sholat berikutnya melalui jadwal, countdown, dan notifikasi sebelum masuk waktu sholat.

## Fitur Utama

- Menampilkan jadwal sholat harian
- Mengambil lokasi pengguna dengan GPS
- Mengambil jadwal sholat dari API berdasarkan koordinat
- Menyimpan jadwal ke cache lokal
- Menampilkan label Jumat untuk pengguna laki-laki pada hari Jumat
- Notifikasi sebelum waktu sholat
  - Sholat biasa: 10 menit sebelum waktu masuk
  - Jumat untuk laki-laki: 30 menit sebelum waktu masuk
- Mode perjalanan manual direncanakan untuk pengguna yang akan pergi ke luar kota

## Prinsip Desain

Aplikasi ini sengaja dibuat sederhana.

Tidak ada fitur berlebihan seperti:
- login
- cloud sync
- komunitas
- artikel
- statistik ibadah
- fitur fiqih kompleks

Fokus utama:

```text
Lokasi → Jadwal → Sholat berikutnya → Notifikasi
```

## Struktur Proyek
```bash
lib/
├── main.dart
└── features/
    └── prayer/
        ├── models/
        │   ├── prayer_day.dart
        │   └── prayer_settings.dart
        ├── pages/
        │   ├── prayer_page.dart
        │   └── prayer_onboarding_page.dart
        └── services/
            ├── location_service.dart
            ├── prayer_api_service.dart
            ├── prayer_cache_service.dart
            ├── prayer_notification_service.dart
            └── prayer_settings_service.dart
```

## Alur Aplikasi
```text
Pertama buka app
↓
Pilih jenis pengguna
↓
Ambil lokasi pengguna
↓
Simpan lokasi utama
↓
Ambil jadwal sholat dari API
↓
Simpan ke cache lokal
↓
Tampilkan jadwal hari ini
↓
Jadwalkan notifikasi
```

## Catatan Notifikasi

Aplikasi tidak berjalan terus-menerus selama 24 jam.

Setelah jadwal berhasil dimuat, aplikasi mendaftarkan notifikasi ke sistem Android. Setelah itu, Android yang bertugas memunculkan notifikasi pada waktu yang sudah dijadwalkan.

## Catatan Offline

Jika internet tidak tersedia, aplikasi akan mencoba menggunakan cache jadwal terakhir.

Jika pengguna berpindah kota dalam kondisi offline dan belum pernah menyimpan jadwal kota tersebut, jadwal mungkin tidak sesuai dengan lokasi terbaru.

## Roadmap

> MVP
 -  Struktur awal Flutter
 -  Ambil lokasi pengguna
 -  Ambil jadwal dari API
 -  Cache jadwal lokal
 -  Onboarding sederhana
 -  Notifikasi sebelum waktu sholat
 -  Label Jumat untuk pengguna laki-laki
> Next
 - Countdown sholat berikutnya
 - Mode perjalanan manual
 - Simpan lokasi tujuan perjalanan
 - Refresh jadwal berdasarkan lokasi aktif
 - Tampilan sholat berikutnya di halaman utama
 - Perbaikan handling offline

## Status

Project ini masih dalam tahap pengembangan awal.

Fokus saat ini adalah membuat aplikasi yang:

bisa menampilkan jadwal dengan benar
bisa memberi notifikasi sebelum waktu sholat
tetap sederhana dan mudah dirawat