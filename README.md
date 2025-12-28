# Tower BTS Management System - Mobile App

Mobile application untuk Tower BTS Management System yang terkoneksi dengan backend Laravel.

## Features

### Authentication
- ✅ Login dengan email dan password
- ✅ Auto-login (persistent session dengan secure storage)
- ✅ Profile management
- ✅ Update profile (phone, WhatsApp, address)
- ✅ Logout & logout all devices

### Trouble Tickets Management
- ✅ Dashboard dengan statistik tickets
- ✅ List tickets dengan filter (status, priority)
- ✅ Ticket detail lengkap
- ✅ Update ticket status
- ✅ Upload foto before/after
- ✅ Engineer notes

### Sites Management
- ✅ List sites dengan search
- ✅ Site detail dengan informasi lengkap
- ✅ PIC Engineer info
- ✅ Recent tickets per site

### Budget Requests
- ✅ List budget requests dengan filter status
- ✅ Budget request detail
- ✅ Create new budget request
- ✅ Link to related ticket

## Tech Stack

- **Framework:** Flutter
- **State Management:** Stateful Widgets (tanpa state management library)
- **HTTP Client:** http package
- **Storage:** shared_preferences (untuk token authentication)
- **Image Picker:** image_picker
- **Maps:** google_maps_flutter, geolocator
- **UI Components:** cached_network_image, intl
- **Environment:** flutter_dotenv

## Setup & Installation

### 1. Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode
- Device fisik atau emulator

### 2. Clone & Install Dependencies

```bash
cd /Applications/mobile/tower_bts
flutter pub get
```

### 3. Konfigurasi Backend URL

Edit file `.env` dan sesuaikan dengan IP server Laravel Anda:

```env
# Untuk emulator Android/iOS
BASE_URL=http://127.0.0.1:8000
API_URL=http://127.0.0.1:8000/api

# Untuk device fisik (ganti dengan IP Mac/PC Anda)
# BASE_URL=http://192.168.1.8:8000
# API_URL=http://192.168.1.8:8000/api
```

**Cara mendapatkan IP address:**

**Mac/Linux:**
```bash
ifconfig | grep "inet "
```

**Windows:**
```bash
ipconfig
```

### 4. Jalankan Laravel Backend

Pastikan backend Laravel sudah berjalan:

```bash
cd /applications/laravel/tower-bts
php artisan serve --host=0.0.0.0 --port=8000
```

### 5. Run Flutter App

**Untuk emulator:**
```bash
flutter run
```

**Untuk device fisik:**
1. Enable USB debugging di Android
2. Sambungkan device via USB
3. Pastikan device dan laptop di WiFi yang sama
4. Update `.env` dengan IP address laptop
5. Run: `flutter run`

## Default Login Credentials

```
Email: andi.wijaya@tower-bts.com
Password: password123
Role: Engineer
Area: Jakarta Selatan
```

## Struktur Folder

```
lib/
├── config/
│   └── api_config.dart          # API endpoints configuration
├── models/
│   ├── user.dart                # User model
│   ├── site.dart                # Site & Engineer models
│   ├── trouble_ticket.dart      # TroubleTicket model
│   └── budget_request.dart      # BudgetRequest models
├── services/
│   └── api_service.dart         # API service layer
├── pages/
│   ├── login_page.dart          # Login screen
│   ├── home_page.dart           # Dashboard dengan bottom nav
│   ├── profile_page.dart        # User profile
│   ├── tickets_page.dart        # Tickets list
│   ├── ticket_detail_page.dart  # Ticket detail & update
│   ├── sites_page.dart          # Sites list
│   ├── site_detail_page.dart    # Site detail
│   ├── budget_requests_page.dart           # Budget requests list
│   ├── budget_request_detail_page.dart     # Budget request detail
│   └── create_budget_request_page.dart     # Create new budget request
└── main.dart                    # App entry point
```

## API Integration

### Authentication Flow

1. User login → API returns token
2. Token disimpan di SharedPreferences
3. Setiap request menggunakan token di header: `Authorization: Bearer {token}`
4. Logout → token dihapus dari storage

### Image Upload

Upload foto menggunakan `multipart/form-data`:

```dart
await ApiService.uploadTicketPhotos(
  ticketId,
  fotoBefore: File('path/to/before.jpg'),
  fotoAfter: File('path/to/after.jpg'),
);
```

### Error Handling

Semua API calls return:

```dart
{
  'error': bool,
  'message': String,
  'data': Map<String, dynamic>,
  'statusCode': int,
}
```

## Features Detail

### 1. Dashboard
- Total assigned tickets
- In progress tickets
- Pending tickets
- Completed tickets
- Quick actions menu

### 2. Tickets Management
- Filter by status: assigned, in_progress, pending, completed, cancelled
- Filter by priority: low, medium, high, critical
- Update status dengan auto-timestamp
- Upload foto before/after dari camera
- Engineer notes untuk setiap ticket

### 3. Sites Management
- Search by site name atau site ID
- View PIC Engineer info
- View recent tickets di site tersebut
- GPS coordinates (latitude, longitude)

### 4. Budget Requests
- Filter by status: pending, approved, rejected, transferred
- Create budget request untuk ticket in_progress
- View specification dan estimated cost
- Track reviewer dan transfer status

## Troubleshooting

### Backend tidak bisa diakses dari device fisik

1. **Check Firewall:**
   - Mac: System Preferences → Security & Privacy → Firewall
   - Windows: Windows Defender Firewall
   - Pastikan port 8000 tidak diblock

2. **Check Network:**
   - Device dan laptop harus di WiFi yang sama
   - Gunakan IP address laptop, bukan `localhost`
   - Test: buka `http://{laptop-ip}:8000` di browser device

3. **Laravel CORS:**
   - Backend Laravel sudah support CORS
   - Jika masih error, check `config/cors.php`

### Token Invalid/Expired

1. Login ulang untuk dapat token baru
2. Check apakah token tersimpan dengan benar
3. Pastikan format header: `Bearer {token}` (ada spasi)

### Image Upload Failed

1. Pastikan permission camera sudah di-grant
2. Check file size (max 5MB per foto)
3. Check format file (hanya JPG/PNG)

## Development Tips

### Hot Reload
```bash
# Tekan 'r' di terminal untuk hot reload
# Tekan 'R' untuk hot restart
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

### Check Dependencies
```bash
flutter pub outdated
```

### Build APK (Production)
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## API Endpoints Reference

Lihat dokumentasi lengkap di backend: `/applications/laravel/tower-bts/API_DOCUMENTATION.md`

**Base URL:** `http://{your-ip}:8000/api`

**Public:**
- `POST /login` - Login
- `GET /settings` - App settings

**Protected (require token):**
- `GET /profile` - Get user profile
- `PUT /profile` - Update profile
- `POST /logout` - Logout
- `GET /tickets` - List tickets
- `GET /tickets/{id}` - Ticket detail
- `POST /tickets/{id}/status` - Update ticket status
- `POST /tickets/{id}/photos` - Upload photos
- `GET /sites` - List sites
- `GET /sites/{id}` - Site detail
- `GET /budget-requests` - List budget requests
- `POST /budget-requests` - Create budget request
- `GET /budget-requests/{id}` - Budget request detail

## License

Private project untuk Tower BTS Management System.

## Support

Untuk pertanyaan atau issue, hubungi tim development.
# tower-bts-flutter
