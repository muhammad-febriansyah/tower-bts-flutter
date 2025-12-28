# MBP Mobile App Implementation Guide

## ✅ Status: **API & Model READY** - UI Pending

### 📋 What's Already Done:

1. ✅ **Backend API** - Complete with 7 endpoints
2. ✅ **Flutter Model** - `lib/models/mbp_request.dart`
3. ✅ **API Service Methods** - `lib/services/api_service.dart`
4. ✅ **API Config** - `lib/config/api_config.dart`

### 🚧 What Needs to be Built:

1. ⏳ MBP List Page (`lib/pages/mbp_page.dart`)
2. ⏳ MBP Detail Page (`lib/pages/mbp_detail_page.dart`)
3. ⏳ Add to Navigation Menu
4. ⏳ Add MBP Dashboard Widget (optional)

---

## 📦 **Files Already Created:**

### 1. Model: `/lib/models/mbp_request.dart`

```dart
class MbpRequest {
  final int id;
  final String mbpNumber;
  final Map<String, dynamic>? site;
  final String? keteranganGangguan;
  final String status;
  final Map<String, dynamic>? engineer;
  // ... more fields

  // Helper methods:
  String getStatusLabel(); // Returns Indonesian label
  Color getStatusColor();  // Returns color for status
}
```

**Status Values:**
- `requested` → "Diminta" (Orange)
- `assigned` → "Ditugaskan" (Blue)
- `on_progress` → "Dalam Proses" (Purple)
- `completed` → "Selesai" (Green)
- `cancelled` → "Dibatalkan" (Red)

---

### 2. API Service: `/lib/services/api_service.dart`

**Available Methods:**

```dart
// Get all MBP requests (filtered by role)
ApiService.getMbpRequests({String? status})

// Get MBP dashboard statistics
ApiService.getMbpDashboard()

// Get single MBP detail
ApiService.getMbpDetail(int id)

// Update MBP status
ApiService.updateMbpStatus(
  int id,
  String status, {
  double? latitudeSetup,
  double? longitudeSetup,
  String? catatanEngineer,
})

// Upload installation photos
ApiService.uploadMbpDocumentation(int id, List<File> photos)
```

---

### 3. API Config: `/lib/config/api_config.dart`

**Endpoints:**
- `ApiConfig.mbpRequests` → `/api/mbp`
- `ApiConfig.mbpDashboard` → `/api/mbp/dashboard`
- `ApiConfig.mbpDetail(id)` → `/api/mbp/{id}`
- `ApiConfig.mbpStatus(id)` → `/api/mbp/{id}/status`
- `ApiConfig.mbpDocumentation(id)` → `/api/mbp/{id}/documentation`

---

## 🎨 **UI Implementation Guide**

### Page 1: MBP List Page

**File:** `lib/pages/mbp_page.dart`

**Features Needed:**
1. ✅ AppBar with title "MBP Requests"
2. ✅ Dashboard stats cards (Total, Assigned, On Progress, Completed)
3. ✅ List of MBP requests
4. ✅ Status filter tabs
5. ✅ Pull to refresh
6. ✅ Tap to open detail

**Example Structure:**
```dart
class MbpPage extends StatefulWidget {
  @override
  State<MbpPage> createState() => _MbpPageState();
}

class _MbpPageState extends State<MbpPage> {
  List<MbpRequest> _mbpRequests = [];
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = true;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadMbpRequests();
  }

  Future<void> _loadDashboard() async {
    final result = await ApiService.getMbpDashboard();
    if (!result['error']) {
      setState(() {
        _dashboardStats = result['data']['stats'];
      });
    }
  }

  Future<void> _loadMbpRequests() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getMbpRequests(
      status: _statusFilter,
    );

    if (!result['error']) {
      final List<dynamic> mbpData = result['data']['mbp_requests'] ?? [];
      setState(() {
        _mbpRequests = mbpData
            .map((json) => MbpRequest.fromJson(json))
            .toList();
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MBP Requests'),
      ),
      body: Column(
        children: [
          // Dashboard Stats
          if (_dashboardStats != null)
            _buildDashboardStats(),

          // Status Filter Tabs
          _buildStatusFilters(),

          // MBP List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMbpRequests,
                    child: ListView.builder(
                      itemCount: _mbpRequests.length,
                      itemBuilder: (context, index) {
                        return _buildMbpCard(_mbpRequests[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
```

---

### Page 2: MBP Detail Page

**File:** `lib/pages/mbp_detail_page.dart`

**Features Needed:**
1. ✅ Display MBP details (number, site, status, etc)
2. ✅ Show installation photos (if any)
3. ✅ Update status button (for engineer)
4. ✅ Upload photos button (for engineer)
5. ✅ Show location map (if coordinates available)
6. ✅ Engineer notes textarea

**Key Actions:**

**1. Update Status:**
```dart
Future<void> _updateStatus(String status) async {
  // Get current location if on_progress
  Position? position;
  if (status == 'on_progress') {
    position = await Geolocator.getCurrentPosition();
  }

  final result = await ApiService.updateMbpStatus(
    widget.mbpId,
    status,
    latitudeSetup: position?.latitude,
    longitudeSetup: position?.longitude,
    catatanEngineer: _notesController.text.trim(),
  );

  if (!result['error']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status berhasil diupdate')),
    );
    _loadMbpDetail();
  }
}
```

**2. Upload Photos:**
```dart
Future<void> _uploadPhotos() async {
  final picker = ImagePicker();
  final images = await picker.pickMultiImage();

  if (images.isEmpty) return;

  // Convert to File list (max 5)
  List<File> files = images
      .take(5)
      .map((xFile) => File(xFile.path))
      .toList();

  final result = await ApiService.uploadMbpDocumentation(
    widget.mbpId,
    files,
  );

  if (!result['error']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Foto berhasil diunggah')),
    );
    _loadMbpDetail();
  }
}
```

---

## 🗺️ **Navigation Menu Integration**

### Add to Main Navigation

**File:** `lib/main.dart` or navigation widget

Add MBP menu item:

```dart
ListTile(
  leading: Icon(Iconsax.flash),
  title: Text('MBP Requests'),
  subtitle: Text('Mobile Backup Power'),
  onTap: () {
    Navigator.pushNamed(context, '/mbp');
  },
),
```

**Add Route:**
```dart
'/mbp': (context) => MbpPage(),
'/mbp/detail': (context) => MbpDetailPage(
  mbpId: ModalRoute.of(context)!.settings.arguments as int,
),
```

---

## 🎨 **UI Components to Reuse**

You can reuse components from existing pages:

### 1. **Stat Cards** (from dashboard)
```dart
// Similar to ticket_page.dart stat cards
_buildStatCard('Total MBP', totalCount, icon, color)
```

### 2. **Status Badges** (from tickets)
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: mbp.getStatusColor(),
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(
    mbp.getStatusLabel(),
    style: TextStyle(color: Colors.white, fontSize: 11),
  ),
)
```

### 3. **Photo Grid** (from ticket detail)
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: mbp.fotoInstalasi?.length ?? 0,
  itemBuilder: (context, index) {
    return Image.network(
      mbp.fotoInstalasi![index],
      fit: BoxFit.cover,
    );
  },
)
```

---

## 🔧 **Required Packages**

Make sure these packages are in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  iconsax: ^0.0.8
  flutter_screenutil: ^5.9.0
  geolocator: ^10.1.0           # For GPS location
  image_picker: ^1.0.4          # For photo upload
  permission_handler: ^11.0.1    # For permissions
```

---

## 📱 **Permissions**

### Android: `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS: `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Kami perlu akses kamera untuk upload foto instalasi MBP</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Kami perlu akses galeri untuk upload foto instalasi MBP</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Kami perlu akses lokasi untuk mencatat koordinat instalasi MBP</string>
```

---

## 🧪 **Testing Checklist**

### Engineer User Flow:

1. ✅ Login sebagai Engineer (Andi Wijaya)
2. ✅ Buka menu MBP
3. ✅ Lihat list MBP yang di-assign
4. ✅ Tap pada MBP untuk lihat detail
5. ✅ Update status ke "On Progress" (auto capture GPS)
6. ✅ Upload foto instalasi (max 5 photos)
7. ✅ Add catatan engineer
8. ✅ Update status ke "Completed"

### API Response Format:

**GET /api/mbp (List):**
```json
{
  "mbp_requests": [
    {
      "id": 1,
      "mbp_number": "MBP-202512-5131",
      "site": {
        "id": 1,
        "site_id": "SITE001",
        "name": "Tower ABC",
        "area": "Jakarta Pusat"
      },
      "keterangan_gangguan": "PLN mati",
      "status": "assigned",
      "engineer": {
        "id": 5,
        "name": "Andi Wijaya"
      },
      "assigned_at": "2025-12-04 10:30:00",
      "created_at": "2025-12-04 10:00:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "total": 1
  }
}
```

---

## 📚 **Additional Resources**

### Similar Pages for Reference:
- `lib/pages/tickets_page.dart` - For list page structure
- `lib/pages/ticket_detail_page.dart` - For detail page structure
- `lib/pages/budget_requests_page.dart` - For dashboard stats

### Color Scheme:
```dart
// MBP Brand Colors (suggestion)
const Color mbpPrimary = Color(0xFFFF6B00);    // Orange
const Color mbpSecondary = Color(0xFF2E7D32);  // Green
const Color mbpAccent = Color(0xFF1976D2);     // Blue
```

---

## 🎯 **Quick Start Implementation:**

### Minimal Viable Product (MVP):

**Step 1:** Create `mbp_page.dart` with basic list
**Step 2:** Create `mbp_detail_page.dart` with detail view
**Step 3:** Add status update functionality
**Step 4:** Add photo upload
**Step 5:** Add to navigation menu

**Estimated Time:** 4-6 hours for MVP

---

**Date:** 2025-12-04
**Status:** ✅ **API READY** - UI Implementation Pending
**Backend:** Complete
**Mobile Foundation:** Complete (Model + API Service)
**Next:** Build UI Pages

---

## 💡 **Need Help?**

Jika perlu bantuan implementasi UI-nya, saya bisa:
1. Buatkan template lengkap untuk `mbp_page.dart`
2. Buatkan template lengkap untuk `mbp_detail_page.dart`
3. Buatkan widget components yang reusable

Just let me know! 🚀
