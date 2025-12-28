import 'dart:io';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class UploadTicketPhotosPage extends StatefulWidget {
  final int ticketId;
  final String? existingFotoBefore;
  final String? existingFotoAfter;

  const UploadTicketPhotosPage({
    super.key,
    required this.ticketId,
    this.existingFotoBefore,
    this.existingFotoAfter,
  });

  @override
  State<UploadTicketPhotosPage> createState() => _UploadTicketPhotosPageState();
}

class _UploadTicketPhotosPageState extends State<UploadTicketPhotosPage> {
  final ImagePicker _picker = ImagePicker();
  File? _fotoBefore;
  File? _fotoAfter;
  bool _isUploading = false;

  Future<void> _pickImage(bool isBefore) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isBefore) {
            _fotoBefore = File(image.path);
          } else {
            _fotoAfter = File(image.path);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error mengambil foto: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery(bool isBefore) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isBefore) {
            _fotoBefore = File(image.path);
          } else {
            _fotoAfter = File(image.path);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error mengambil foto: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog(bool isBefore) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Icon(Iconsax.camera, color: const Color(0xFF2E7D32), size: 28.sp),
                  title: Text(
                    'Kamera',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(isBefore);
                  },
                ),
                ListTile(
                  leading: Icon(Iconsax.gallery, color: const Color(0xFF2E7D32), size: 28.sp),
                  title: Text(
                    'Galeri',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery(isBefore);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadPhotos() async {
    if (_fotoBefore == null && _fotoAfter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu foto untuk diupload'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final result = await ApiService.uploadTicketPhotos(
        widget.ticketId,
        fotoBefore: _fotoBefore,
        fotoAfter: _fotoAfter,
      );

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Upload gagal'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil diupload'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Upload Foto Ticket'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.blue.shade700, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Upload foto sebelum dan sesudah perbaikan untuk dokumentasi',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Foto Before
              Text(
                'Foto Sebelum Perbaikan',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              _buildPhotoCard(
                isBefore: true,
                photo: _fotoBefore,
                existingUrl: widget.existingFotoBefore,
              ),
              SizedBox(height: 24.h),

              // Foto After
              Text(
                'Foto Sesudah Perbaikan',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              _buildPhotoCard(
                isBefore: false,
                photo: _fotoAfter,
                existingUrl: widget.existingFotoAfter,
              ),
              SizedBox(height: 32.h),

              // Upload Button
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadPhotos,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
                child: _isUploading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Upload Foto',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard({
    required bool isBefore,
    File? photo,
    String? existingUrl,
  }) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300, width: 2.w),
      ),
      child: photo != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    photo,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _showImageSourceDialog(isBefore),
                        icon: Icon(Iconsax.edit_2, color: Colors.white, size: 24.sp),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (isBefore) {
                              _fotoBefore = null;
                            } else {
                              _fotoAfter = null;
                            }
                          });
                        },
                        icon: Icon(Iconsax.trash, color: Colors.white, size: 24.sp),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: () => _showImageSourceDialog(isBefore),
              borderRadius: BorderRadius.circular(12.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.camera, size: 48.sp, color: Colors.grey.shade400),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap untuk ${existingUrl != null ? 'ganti' : 'tambah'} foto',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (existingUrl != null) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Sudah ada foto',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
