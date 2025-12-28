# Audit Fitur Flutter berdasarkan Role Features Summary

## Status Audit: 2025-12-05

### RINGKASAN TEMUAN

Berdasarkan audit terhadap aplikasi Flutter Tower BTS dan perbandingan dengan `role_features_summary.md`, ditemukan beberapa fitur yang **BELUM DIIMPLEMENTASIKAN** di aplikasi mobile.

---

## 1. ROLE: RSS (Remote Site Supervisor)

### Fitur yang Sudah Ada ✅
- View all tickets
- View sites
- View MBP requests

### Fitur yang KURANG ❌
- **Budget Request Review & Approval** - BELUM ADA UI untuk review dan approve budget requests
- **Budget Transfer** - BELUM ADA fitur untuk transfer budget ke engineer
- **Assign Tickets** - BELUM ADA tombol/fitur untuk assign ticket ke engineer
- **Budget Dashboard** - Statistik budget belum lengkap di home page

---

## 2. ROLE: MANAGER OPERASIONAL RSS

### Fitur yang Sudah Ada ✅
- Semua fitur RSS (view tickets, sites, MBP)

### Fitur yang KURANG ❌
- **Special Team Management** - BELUM ADA SAMA SEKALI
  - Assign civil team
  - Assign electrical team
  - Monitor special team assignments
  - Update assignment status
- **Budget for Special Work** - BELUM ADA

### Kesimpulan
Manager Operasional RSS saat ini TIDAK BERBEDA dengan RSS biasa di Flutter app. Fitur khusus untuk special team management belum ada.

---

## 3. ROLE: HD RSS (Help Desk RSS)

### Fitur yang Sudah Ada ✅
- View all tickets
- View MBP requests
- View sites

### Fitur yang KURANG ❌
- **Create Trouble Ticket** - BELUM ADA tombol/halaman untuk create ticket
- **Assign Ticket** - BELUM ADA fitur assign ticket ke engineer
- **Create MBP Request** - BELUM ADA tombol/halaman untuk create MBP
- **Assign MBP** - BELUM ADA fitur assign MBP ke engineer

### Kesimpulan
HD RSS saat ini HANYA BISA MELIHAT data, TIDAK BISA CREATE atau ASSIGN apapun. Ini TIDAK SESUAI dengan role definition.

---

## 4. ROLE: ENGINEER / MITRA (Field Users)

### Fitur yang Sudah Ada ✅
- View assigned tickets
- Create budget requests
- View budget requests
- View my MBP tasks
- View sites

### Fitur yang KURANG ❌
- **Preventive Maintenance - Aset Lumpsum** - BELUM ADA SAMA SEKALI
  - Create asset records
  - Upload asset photos
  - Mark asset status
  - View asset history

- **Budget Operasional (Dropping)** - BELUM ADA
  - View received budget from RSS
  - Track available balance
  - Budget dashboard

- **Budget Realisasi (GPS Required)** - BELUM ADA
  - Record spending with GPS
  - Categories: Fuel, Materials, Transport, Other
  - Upload proof photos
  - GPS coordinates REQUIRED

- **Update Ticket Status** - Fitur update status TIDAK JELAS di UI
- **Upload Before/After Photos** - Ada di ticket detail tapi perlu dicek lebih lanjut
- **Update MBP Status & Documentation** - BELUM JELAS implementasinya

### Kesimpulan
Engineer/Mitra KEHILANGAN 3 FITUR BESAR:
1. Aset Lumpsum (PM)
2. Budget Operasional
3. Budget Realisasi (GPS tracking spending)

---

## 5. ANALISIS ROLE PERMISSIONS (role_permissions.dart)

### Issues yang Ditemukan:

1. **canCreateTickets()** - Sudah benar (HD RSS only) ✅
2. **canUpdateTicketStatus()** - Sudah benar (Field workers only) ✅
3. **canCreateBudgetRequests()** - Sudah benar (Field workers only) ✅
4. **canApproveBudgetRequests()** - Sudah benar (Management roles) ✅
5. **canCreateMbp()** - SALAH ❌
   - Saat ini: HD RSS, RSS, Admin
   - Seharusnya: HD RSS ONLY (sesuai dokumentasi)
6. **TIDAK ADA permission untuk:**
   - canAssignTickets (RSS, Manager Ops, HD RSS)
   - canTransferBudget (RSS, Manager Ops)
   - canManageSpecialTeams (Manager Ops only)
   - canAccessAsetLumpsum (Engineer, Mitra)
   - canAccessBudgetOperasional (Engineer, Mitra)
   - canAccessBudgetRealisasi (Engineer, Mitra)

---

## 6. NAVIGASI / BOTTOM BAR

### Masalah:
- Engineer/Mitra hanya punya: Dashboard, Tickets, Sites, Budget, MBP, Profile
- KURANG: Menu untuk Aset Lumpsum, Budget Operasional, Budget Realisasi
- HD RSS tidak punya tombol Create Ticket atau Create MBP
- RSS tidak punya akses ke Budget Management

---

## PRIORITAS PERBAIKAN

### CRITICAL (Harus segera ditambahkan):
1. **Create Ticket Page** untuk HD RSS
2. **Assign Ticket Button** untuk RSS/Manager/HD RSS
3. **Budget Review & Approval** untuk RSS/Manager
4. **Budget Transfer** untuk RSS/Manager
5. **Aset Lumpsum Pages** untuk Engineer/Mitra (PM feature)
6. **Budget Operasional Pages** untuk Engineer/Mitra
7. **Budget Realisasi Pages** untuk Engineer/Mitra (dengan GPS)

### HIGH (Important):
8. **Create MBP Page** untuk HD RSS
9. **Assign MBP Button** untuk HD RSS
10. **Special Team Management** untuk Manager Ops
11. Update MBP Status & Documentation untuk Engineer

### MEDIUM:
12. Perbaiki MBP create permission (HD RSS only)
13. Tambahkan role permission functions yang kurang
14. Update navigation menu sesuai role

---

## API ENDPOINTS YANG PERLU DICEK

Pastikan API sudah tersedia untuk:
- `POST /api/tickets` - Create ticket (HD RSS)
- `POST /api/tickets/{id}/assign` - Assign ticket
- `POST /api/rss/budget/requests/{id}/review` - Approve/reject budget
- `POST /api/rss/budget/requests/{id}/transfer` - Transfer budget
- `GET /api/aset-lumpsum` - List assets
- `POST /api/aset-lumpsum` - Create asset
- `GET /api/budget-operasional` - List operational budget
- `POST /api/budget-realisasi` - Create realization (GPS required)
- `POST /api/mbp` - Create MBP (HD RSS)
- `POST /api/mbp/{id}/assign` - Assign MBP
- `POST /api/special-teams/assignments` - Assign special team
- `GET /api/special-teams` - List special teams

---

## KESIMPULAN

Aplikasi Flutter saat ini HANYA mengimplementasikan **30-40%** dari fitur yang seharusnya ada berdasarkan role features summary.

**FITUR BESAR YANG HILANG:**
1. Preventive Maintenance (Aset Lumpsum) - 0%
2. Budget Operasional - 0%
3. Budget Realisasi with GPS - 0%
4. Create & Assign Tickets - 0%
5. Create & Assign MBP - 0%
6. Budget Review & Transfer - 0%
7. Special Team Management - 0%

**NEXT STEPS:**
1. Tambahkan models untuk Aset Lumpsum, Budget Operasional, Budget Realisasi
2. Buat pages untuk fitur-fitur yang kurang
3. Update role_permissions.dart dengan permissions lengkap
4. Update navigation menu untuk semua role
5. Implementasi GPS tracking untuk Budget Realisasi dan MBP Documentation
6. Testing per role untuk memastikan semua fitur berfungsi

---

## REKOMENDASI STRUKTUR FOLDER

```
lib/
├── models/
│   ├── aset_lumpsum.dart          # NEW
│   ├── budget_operasional.dart    # NEW
│   ├── budget_realisasi.dart      # NEW
│   ├── special_team.dart          # NEW
│   ├── special_assignment.dart    # NEW
│   └── ... (existing models)
│
├── pages/
│   ├── aset_lumpsum/
│   │   ├── aset_lumpsum_page.dart         # NEW - List assets
│   │   ├── create_aset_page.dart          # NEW - Document asset
│   │   └── aset_detail_page.dart          # NEW - View asset
│   │
│   ├── budget_operasional/
│   │   ├── budget_operasional_page.dart   # NEW - List received budget
│   │   └── budget_operasional_detail.dart # NEW - View budget details
│   │
│   ├── budget_realisasi/
│   │   ├── budget_realisasi_page.dart     # NEW - List realizations
│   │   ├── create_realisasi_page.dart     # NEW - Record spending (GPS)
│   │   └── realisasi_detail_page.dart     # NEW - View realization
│   │
│   ├── create_ticket_page.dart            # NEW - HD RSS create ticket
│   ├── assign_ticket_page.dart            # NEW - Assign ticket dialog
│   ├── review_budget_page.dart            # NEW - RSS approve/reject budget
│   ├── transfer_budget_page.dart          # NEW - RSS transfer budget
│   ├── create_mbp_page.dart               # NEW - HD RSS create MBP
│   ├── assign_mbp_page.dart               # NEW - Assign MBP dialog
│   │
│   └── special_teams/
│       ├── special_teams_page.dart        # NEW - Manager Ops only
│       ├── assign_special_team_page.dart  # NEW - Assign team
│       └── special_assignment_detail.dart # NEW - View assignment
│
└── services/
    └── gps_service.dart                   # NEW - Handle GPS for realisasi & MBP
```

---

**Status:** AUDIT COMPLETED - READY FOR IMPLEMENTATION
**Auditor:** Claude Code Assistant
**Date:** 2025-12-05
