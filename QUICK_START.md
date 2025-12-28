# Quick Start Guide - Tower BTS Mobile App

## ⚡ Cara Cepat Menjalankan Aplikasi

### 1️⃣ Start Backend Laravel

```bash
cd /applications/laravel/tower-bts
php artisan serve --host=0.0.0.0 --port=8000
```

Pastikan backend sudah running di: `http://192.168.1.8:8000`

### 2️⃣ Check IP Address (Jika Pakai Device Fisik)

**Mac:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Hasil contoh:** `inet 192.168.1.8 netmask...`

### 3️⃣ Update .env File

Edit `/Applications/mobile/tower_bts/.env`:

```env
# Untuk emulator
BASE_URL=http://127.0.0.1:8000
API_URL=http://127.0.0.1:8000/api

# Untuk device fisik (ganti IP sesuai hasil step 2)
# BASE_URL=http://192.168.1.8:8000
# API_URL=http://192.168.1.8:8000/api
```

### 4️⃣ Run Flutter App

```bash
cd /Applications/mobile/tower_bts
flutter run
```

**Pilih device:**
- Tekan angka device yang mau digunakan
- Contoh: `1` untuk Chrome, `2` untuk Android Emulator, dll.

### 5️⃣ Login

```
Email: andi.wijaya@tower-bts.com
Password: password123
```

---

## 🔧 Troubleshooting

### Error: MissingPluginException

**Solusi:**
```bash
flutter clean
flutter pub get
flutter run
```

### Backend tidak bisa diakses

**Cek:**
1. Backend Laravel running? → `http://192.168.1.8:8000` di browser
2. Device & Laptop di WiFi yang sama?
3. IP di `.env` sudah benar?
4. Firewall tidak block port 8000?

**Test koneksi:**
```bash
# Di laptop
ifconfig | grep "inet "

# Buka di browser device
http://{IP-LAPTOP}:8000
```

### Hot Reload

**Saat app running:**
- Tekan `r` → Hot reload
- Tekan `R` → Hot restart
- Tekan `q` → Quit

---

## 📱 Features

### ✅ Dashboard
- Statistik tickets (Total, In Progress, Pending, Completed)
- Quick actions menu

### ✅ Tickets
- List dengan filter (status, priority)
- Update status
- Upload foto before/after
- Engineer notes

### ✅ Sites
- List dengan search
- Site detail
- PIC Engineer info
- Recent tickets

### ✅ Budget Requests
- List dengan filter status
- Create new request
- View detail & tracking

---

## 🚀 Build APK (Production)

```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

**Install ke device:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 📚 Dokumentasi Lengkap

Lihat `README.md` untuk dokumentasi lengkap.

## 🆘 Support

Jika ada masalah, cek:
1. Backend Laravel logs: `storage/logs/laravel.log`
2. Flutter console output
3. README.md → Troubleshooting section
