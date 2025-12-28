import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../models/mbp_request.dart';
import '../models/user.dart';
import '../config/app_colors.dart';
import '../config/app_strings.dart';
import '../utils/role_permissions.dart';
import '../widgets/location_map_widget.dart';
import '../widgets/assign_mbp_dialog.dart';

class MbpDetailPage extends StatefulWidget {
  final int mbpId;

  const MbpDetailPage({super.key, required this.mbpId});

  @override
  State<MbpDetailPage> createState() => _MbpDetailPageState();
}

class _MbpDetailPageState extends State<MbpDetailPage> {
  MbpRequest? _mbp;
  bool _isLoading = true;
  final _notesController = TextEditingController();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadMbpDetail();
  }

  Future<void> _loadUser() async {
    try {
      final result = await ApiService.getProfile();
      if (!mounted) return;
      if (!result['error']) {
        setState(() {
          _currentUser = User.fromJson(result['data']['user']);
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMbpDetail() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getMbpDetail(widget.mbpId);

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? AppStrings.failedToLoad)),
        );
      } else {
        setState(() {
          _mbp = MbpRequest.fromJson(result['data']['mbp_request']);
          _notesController.text = _mbp?.catatanEngineer ?? '';
        });
        debugPrint('MBP loaded successfully. Photos count: ${_mbp?.fotoInstalasi?.length ?? 0}');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error loading MBP: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    Position? position;

    // Get GPS location if status is on_progress
    if (status == 'on_progress') {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location service is disabled')));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Location permission denied')));
          return;
        }
      }

      try {
        position = await Geolocator.getCurrentPosition();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to get location')));
        return;
      }
    }

    final result = await ApiService.updateMbpStatus(
      widget.mbpId,
      status,
      latitudeSetup: position?.latitude,
      longitudeSetup: position?.longitude,
      catatanEngineer: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (result['error']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? AppStrings.failedToUpdate),
          backgroundColor: AppColors.danger,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diupdate'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadMbpDetail();
    }
  }

  Future<void> _uploadPhotos() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();

      if (images.isEmpty) return;

      // Max 5 photos
      List<File> files = images.take(5).map((xFile) => File(xFile.path)).toList();

      if (!mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  'Mengupload foto...',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      try {
        debugPrint('Uploading ${files.length} photos for MBP ${widget.mbpId}');
        final result = await ApiService.uploadMbpDocumentation(widget.mbpId, files);

        debugPrint('Upload result: $result');

        if (!mounted) return;

        // Close loading dialog
        Navigator.pop(context);

        if (result['error'] == true) {
          debugPrint('Upload failed: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']?.toString() ?? 'Gagal mengupload foto'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          debugPrint('Upload success, reloading MBP detail...');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['data']?['message']?.toString() ?? 'Foto berhasil diunggah'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Reload data to show new photos
          await _loadMbpDetail();
        }
      } catch (e, stackTrace) {
        debugPrint('Upload exception: $e');
        debugPrint('Stack trace: $stackTrace');

        if (!mounted) return;

        // Close loading dialog
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error upload: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Error during image picking
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih foto: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStatusDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and close button
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Iconsax.edit_2,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perbarui Status',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Pilih status baru untuk MBP ini',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Iconsax.close_circle, color: Colors.grey[400]),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Status options
              _buildStatusOption(
                'Mulai Instalasi',
                'Tandai MBP sedang dalam proses instalasi',
                'on_progress',
                Iconsax.flash,
                Colors.purple,
              ),
              SizedBox(height: 12.h),
              _buildStatusOption(
                'Selesai',
                'Tandai instalasi MBP telah selesai',
                'completed',
                Iconsax.tick_circle,
                Colors.green,
              ),
              SizedBox(height: 12.h),
              _buildStatusOption(
                'Batalkan',
                'Batalkan permintaan MBP ini',
                'cancelled',
                Iconsax.close_circle,
                Colors.red,
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(
    String title,
    String subtitle,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            _updateStatus(status);
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: Colors.grey[400],
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Detail MBP',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Show Assign button if HD RSS and MBP not yet assigned
          if (RolePermissions.canAssignMbp(_currentUser?.role) &&
              _mbp != null &&
              _mbp!.engineer == null)
            IconButton(
              icon: const Icon(Iconsax.user_add),
              tooltip: 'Assign MBP',
              onPressed: () async {
                final result = await showAssignMbpDialog(
                  context,
                  mbpId: widget.mbpId,
                  mbpNumber: _mbp?.mbpNumber ?? 'MBP-???',
                );
                if (result == true) {
                  _loadMbpDetail(); // Refresh MBP details
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _mbp == null
          ? Center(child: Text('MBP tidak ditemukan'))
          : RefreshIndicator(
              onRefresh: _loadMbpDetail,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MBP Info Card
                    _buildInfoCard(),
                    SizedBox(height: 16.h),

                    // Site Info Card
                    _buildSiteCard(),
                    SizedBox(height: 16.h),

                    // Photos Section
                    if (_mbp!.fotoInstalasi != null &&
                        _mbp!.fotoInstalasi!.isNotEmpty) ...[
                      _buildPhotosSection(),
                      SizedBox(height: 16.h),
                    ],

                    // Notes Section
                    _buildNotesSection(),
                    SizedBox(height: 24.h),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _mbp!.getStatusColor().withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _mbp!.getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Iconsax.flash,
                    color: _mbp!.getStatusColor(),
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permintaan MBP',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _mbp!.mbpNumber,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _mbp!.getStatusColor(),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    _mbp!.getStatusLabel(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (_mbp!.keteranganGangguan != null) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      size: 16.sp,
                      color: Colors.orange[700],
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keterangan Gangguan',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _mbp!.keteranganGangguan!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.orange[900],
                              height: 1.4,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSiteCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Iconsax.building_4,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Informasi Site',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (_mbp!.site != null) ...[
              _buildInfoRow(
                Iconsax.location,
                'ID Site',
                _mbp!.site!['site_id'] ?? '-',
              ),
              _buildInfoRow(
                Iconsax.building,
                'Nama Site',
                _mbp!.site!['name'] ?? '-',
              ),
              _buildInfoRow(Iconsax.map, 'Area', _mbp!.site!['area'] ?? '-'),
              if (_mbp!.site!['address'] != null)
                _buildInfoRow(
                  Iconsax.location_tick,
                  'Alamat',
                  _mbp!.site!['address'],
                ),
              if (_mbp!.site!['latitude'] != null &&
                  _mbp!.site!['longitude'] != null) ...[
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: LocationMapWidget(
                    latitude: double.tryParse(
                      _mbp!.site!['latitude'].toString(),
                    ),
                    longitude: double.tryParse(
                      _mbp!.site!['longitude'].toString(),
                    ),
                    title: _mbp!.site!['name'],
                    height: 250,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                Text(value, style: TextStyle(fontSize: 14.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Instalasi',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemCount: _mbp!.fotoInstalasi!.length,
          itemBuilder: (context, index) {
            final photoUrl = _mbp!.fotoInstalasi![index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.gallery_slash,
                            size: 32.sp,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Gagal memuat',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Iconsax.note_text,
                    color: Colors.amber[700],
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Catatan Engineer',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _notesController,
              maxLines: 4,
              style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan instalasi, kondisi site, dll...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_mbp!.status == 'assigned' || _mbp!.status == 'on_progress')
          ElevatedButton.icon(
            onPressed: _showStatusDialog,
            icon: Icon(Iconsax.edit_2, size: 20.sp),
            label: Text(
              'Perbarui Status',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 52.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _uploadPhotos,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 52.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.camera, color: AppColors.primary, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Upload Foto Instalasi',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 50.h),
      ],
    );
  }
}
