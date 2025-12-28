# Testing Role-Based Features - Tower BTS App

## 📋 Daftar Isi
- [Overview](#overview)
- [Role Field Workers](#role-field-workers-engineer--mitra)
- [Role Management](#role-management-rss-manager-hd-admin)
- [Cara Testing](#cara-testing)
- [File yang Mengatur Role](#file-yang-mengatur-role)

---

## 🎯 Overview

Aplikasi Tower BTS memiliki 2 kategori utama role dengan akses yang berbeda:

1. **Field Workers**: Engineer & Mitra (pekerja lapangan)
2. **Management**: RSS, Manager Operasional RSS, HD RSS, Admin (supervisor/management)

---

## 👷 Role Field Workers (Engineer & Mitra)

### ✅ Fitur yang Bisa Diakses

#### 1. Dashboard
- Melihat statistik **tiket mereka sendiri** saja
- Total tiket yang assigned ke mereka
- Breakdown status tiket mereka

#### 2. Tickets Page
- **Hanya melihat tiket yang ditugaskan ke mereka**
- Filter berdasarkan status dan prioritas
- Klik tiket untuk lihat detail

#### 3. Ticket Detail
- Melihat detail lengkap tiket mereka
- ✅ **Button "Upload Foto"** - Upload foto before/after
- ✅ **Button "Update Status"** - Ubah status tiket
- ✅ **Form Catatan Engineer** - Tambah catatan dalam dialog update status

#### 4. Sites Page
- Melihat semua site (read-only)
- Search site
- Lihat detail site

#### 5. Budget Requests
- ✅ **Menu "Budget" muncul di Bottom Navigation**
- Melihat **permintaan anggaran mereka sendiri** saja
- ✅ **FAB "Buat Permintaan"** - Buat permintaan anggaran baru
- Filter berdasarkan status
- Lihat detail budget request

#### 6. Profile
- Melihat dan edit profil mereka sendiri
- Logout

### ❌ Yang Tidak Bisa Diakses

- ❌ Tidak bisa lihat tiket engineer/mitra lain
- ❌ Tidak bisa lihat budget request orang lain
- ❌ Tidak bisa approve/reject budget request
- ❌ Tidak bisa akses data statistik keseluruhan

---

## 👔 Role Management (RSS, Manager Operasional RSS, HD RSS, Admin)

### ✅ Fitur yang Bisa Diakses

#### 1. Dashboard
- Melihat statistik **semua tiket** dari semua engineer
- Total tiket keseluruhan
- Breakdown status semua tiket untuk monitoring

#### 2. Tickets Page
- **Melihat SEMUA tiket dari semua engineer/mitra**
- Filter berdasarkan status dan prioritas
- Monitoring progress semua tiket
- Klik tiket untuk lihat detail

#### 3. Ticket Detail
- Melihat detail lengkap semua tiket
- Melihat foto before/after yang diupload
- Melihat catatan engineer
- Melihat history status
- ❌ **TIDAK ada button "Upload Foto"**
- ❌ **TIDAK ada button "Update Status"**
- ❌ **TIDAK bisa ubah/tambah catatan engineer**

#### 4. Sites Page
- Melihat semua site
- Search site
- Lihat detail site

#### 5. Budget Requests
- ❌ **Menu "Budget" TIDAK muncul di Bottom Navigation**
- Management tidak perlu buat budget request
- (Fitur approval budget akan ada di web admin)

#### 6. Profile
- Melihat dan edit profil mereka sendiri
- Logout

### ❌ Yang Tidak Bisa Diakses

- ❌ Tidak bisa update status tiket (hanya engineer yang bisa)
- ❌ Tidak bisa upload foto tiket (hanya engineer yang bisa)
- ❌ Tidak bisa buat budget request (hanya field workers yang perlu)
- ❌ Tidak ada menu Budget di bottom navigation

---

## 🧪 Cara Testing

### Test 1: Login sebagai Engineer/Mitra

```
Step 1: Login
- Buka aplikasi
- Login dengan akun role: engineer atau mitra
  Example credentials (sesuaikan dengan database):
  - Email: engineer@example.com
  - Password: password

Step 2: Cek Dashboard
- ✅ Harus melihat statistik HANYA tiket yang assigned ke user ini
- ✅ Jumlah tiket harus sesuai dengan tiket mereka saja

Step 3: Cek Tickets Page
- ✅ List tiket yang muncul HANYA tiket yang assigned ke user ini
- ✅ Tidak boleh muncul tiket engineer/mitra lain
- ✅ Test filter status dan prioritas

Step 4: Cek Ticket Detail
- Klik salah satu tiket
- ✅ Harus ada button "Upload Foto" (kamera icon)
- ✅ Harus ada button "Update Status" (refresh icon)
- ✅ Klik "Update Status" → Harus muncul dialog dengan:
  - Radio button pilihan status
  - TextField untuk catatan engineer
  - Button "Update"

Step 5: Test Update Status
- ✅ Pilih status baru
- ✅ Isi catatan engineer (opsional)
- ✅ Klik "Update"
- ✅ Status harus berubah
- ✅ Catatan harus tersimpan

Step 6: Test Upload Foto
- ✅ Klik button "Upload Foto"
- ✅ Harus navigate ke halaman upload
- ✅ Bisa pilih foto before dan after
- ✅ Upload berhasil

Step 7: Cek Bottom Navigation
- ✅ Harus ada 5 menu: Dashboard, Tickets, Sites, Budget, Profile
- ✅ Menu "Budget" harus terlihat

Step 8: Cek Budget Requests
- Klik menu "Budget"
- ✅ Harus melihat HANYA budget request milik user ini
- ✅ Tidak boleh muncul budget request engineer/mitra lain
- ✅ Harus ada FAB (Floating Action Button) "Buat Permintaan"
- ✅ Klik FAB → Navigate ke form create budget request
- ✅ Test buat budget request baru

Step 9: Test Logout
- Klik menu "Profile"
- Klik button "Keluar"
- ✅ Harus logout dan kembali ke login page
```

---

### Test 2: Login sebagai RSS/Manager/HD/Admin

```
Step 1: Login
- Buka aplikasi
- Login dengan akun role: rss / manager_operasional_rss / hd_rss / admin
  Example credentials (sesuaikan dengan database):
  - Email: rss@example.com
  - Password: password

Step 2: Cek Dashboard
- ✅ Harus melihat statistik SEMUA tiket dari semua engineer
- ✅ Jumlah tiket harus total keseluruhan (bukan per engineer)

Step 3: Cek Tickets Page
- ✅ List tiket yang muncul adalah SEMUA tiket dari semua engineer/mitra
- ✅ Harus bisa lihat tiket dari berbagai engineer berbeda
- ✅ Test filter status dan prioritas
- ✅ Semua tiket harus terlihat (tidak terfilter by engineer)

Step 4: Cek Ticket Detail
- Klik salah satu tiket
- ❌ TIDAK boleh ada button "Upload Foto"
- ❌ TIDAK boleh ada button "Update Status"
- ✅ Bisa lihat detail tiket (read-only)
- ✅ Bisa lihat foto before/after (jika ada)
- ✅ Bisa lihat catatan engineer (jika ada)
- ✅ Bisa lihat history status

Step 5: Cek Sites Page
- ✅ Bisa lihat semua site
- ✅ Bisa search dan filter
- ✅ Bisa lihat detail site

Step 6: Cek Bottom Navigation
- ✅ Harus ada 4 menu saja: Dashboard, Tickets, Sites, Profile
- ❌ Menu "Budget" TIDAK boleh terlihat
- ✅ Tidak ada menu Budget di posisi manapun

Step 7: Test Logout
- Klik menu "Profile"
- Klik button "Keluar"
- ✅ Harus logout dan kembali ke login page
```

---

## 📂 File yang Mengatur Role

### Backend (Laravel)

#### 1. Middleware Role
```
File: /Applications/laravel/tower-bts/app/Http/Middleware/CheckRole.php
Fungsi: Mengecek apakah user memiliki role yang sesuai untuk mengakses endpoint
```

#### 2. API Routes dengan Middleware
```
File: /Applications/laravel/tower-bts/routes/api.php
Contoh:
- Route dengan role engineer & mitra:
  POST /api/tickets/{id}/status
  POST /api/tickets/{id}/photos
  GET  /api/budget-requests
  POST /api/budget-requests

- Route tanpa middleware (semua role):
  GET /api/tickets
  GET /api/sites
```

#### 3. Controller - Trouble Ticket
```
File: /Applications/laravel/tower-bts/app/Http/Controllers/Api/TroubleTicketController.php

Method: index()
- Field workers: Filter query by engineer_id
- Management: Tidak filter, tampilkan semua

Method: updateStatus()
- Hanya bisa diakses oleh engineer & mitra
- Menggunakan middleware role

Method: uploadPhotos()
- Hanya bisa diakses oleh engineer & mitra
- Menggunakan middleware role
```

#### 4. Controller - Budget Request
```
File: /Applications/laravel/tower-bts/app/Http/Controllers/Api/BudgetRequestController.php

Method: index()
- Field workers: Filter query by requester_id
- Management: Tidak ada akses (error 403)

Method: store()
- Hanya bisa diakses oleh engineer & mitra
- Menggunakan middleware role
```

---

### Frontend (Flutter)

#### 1. Role Permissions Helper
```
File: /Applications/mobile/tower_bts/lib/utils/role_permissions.dart

Class: RolePermissions
Methods:
- canAccessBudgetRequests(role) → true jika engineer/mitra
- canUpdateTicketStatus(role) → true jika engineer/mitra
- canUploadPhotos(role) → true jika engineer/mitra
- canCreateBudgetRequests(role) → true jika engineer/mitra
```

#### 2. Dynamic Bottom Navigation
```
File: /Applications/mobile/tower_bts/lib/widgets/main_bottom_navigation.dart

Logic:
- Cek role user
- Jika engineer/mitra → Tampilkan menu Budget
- Jika bukan → Tidak tampilkan menu Budget
```

#### 3. Ticket Detail Page
```
File: /Applications/mobile/tower_bts/lib/pages/ticket_detail_page.dart

Logic:
- Cek role user
- Jika engineer/mitra → Tampilkan button "Upload Foto" dan "Update Status"
- Jika bukan → Sembunyikan button tersebut
```

#### 4. Budget Requests Page
```
File: /Applications/mobile/tower_bts/lib/pages/budget_requests_page.dart

Logic:
- Cek role user
- Jika engineer/mitra → Tampilkan FAB "Buat Permintaan"
- Jika bukan → Sembunyikan FAB (tapi seharusnya tidak sampai page ini)
```

#### 5. Home Page
```
File: /Applications/mobile/tower_bts/lib/pages/home_page.dart

Logic:
- Load user profile untuk mendapatkan role
- Adjust navigation berdasarkan role
- Pass role ke bottom navigation
```

---

## 🔍 Checklist Testing

### ✅ Test Engineer/Mitra
- [ ] Login berhasil
- [ ] Dashboard hanya tampilkan statistik tiket mereka
- [ ] Tickets hanya tampilkan tiket mereka
- [ ] Ticket detail ada button "Upload Foto"
- [ ] Ticket detail ada button "Update Status"
- [ ] Bisa update status tiket
- [ ] Bisa upload foto tiket
- [ ] Menu Budget muncul di bottom nav
- [ ] Budget requests hanya tampilkan request mereka
- [ ] FAB "Buat Permintaan" muncul
- [ ] Bisa buat budget request baru
- [ ] Logout berhasil

### ✅ Test RSS/Manager/HD/Admin
- [ ] Login berhasil
- [ ] Dashboard tampilkan statistik semua tiket
- [ ] Tickets tampilkan semua tiket dari semua engineer
- [ ] Ticket detail TIDAK ada button "Upload Foto"
- [ ] Ticket detail TIDAK ada button "Update Status"
- [ ] Bisa lihat detail tiket (read-only)
- [ ] Menu Budget TIDAK muncul di bottom nav
- [ ] Tidak bisa akses halaman budget requests
- [ ] Logout berhasil

---

## ⚠️ Catatan Penting

1. **Database User**
   - Pastikan di database ada user dengan role berbeda untuk testing
   - Minimal buat 2 user: 1 engineer, 1 rss

2. **Token Authentication**
   - Aplikasi menggunakan Laravel Sanctum
   - Token disimpan di SharedPreferences
   - Logout akan menghapus token

3. **Error Handling**
   - Jika role tidak sesuai, API akan return 403 Forbidden
   - Frontend sudah handle error dan tampilkan pesan yang sesuai

4. **Development vs Production**
   - Pastikan BASE_URL di .env sesuai dengan server yang digunakan
   - Untuk testing lokal: http://192.168.1.7:8080
   - Untuk production: sesuaikan dengan server production

---

## 📞 Troubleshooting

### Issue: Menu Budget tidak muncul untuk Engineer
**Solusi:**
1. Cek role user di database (harus 'engineer' atau 'mitra')
2. Restart aplikasi setelah login
3. Clear app data dan login ulang

### Issue: Engineer bisa lihat tiket orang lain
**Solusi:**
1. Cek backend TroubleTicketController.php
2. Pastikan filter by engineer_id sudah aktif
3. Cek response API di network inspector

### Issue: Button Update Status tidak muncul di Ticket Detail
**Solusi:**
1. Cek role user di SharedPreferences
2. Pastikan RolePermissions.canUpdateTicketStatus() return true
3. Restart aplikasi

---

**Dokumentasi ini dibuat untuk memudahkan testing role-based features.**

Jika ada pertanyaan atau issue, silakan hubungi tim developer.
