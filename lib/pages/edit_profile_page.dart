import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _noHpController;
  late TextEditingController _whatsappController;
  late TextEditingController _alamatController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _noHpController = TextEditingController(text: widget.user.noHp ?? '');
    _whatsappController = TextEditingController(text: widget.user.whatsapp ?? '');
    _alamatController = TextEditingController(text: widget.user.alamat ?? '');
  }

  @override
  void dispose() {
    _noHpController.dispose();
    _whatsappController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.updateProfile({
        'no_hp': _noHpController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'alamat': _alamatController.text.trim(),
      });

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal update profile'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Info (Read-only)
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Akun',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildInfoRow('Nama', widget.user.name),
                      SizedBox(height: 8.h),
                      _buildInfoRow('Email', widget.user.email),
                      SizedBox(height: 8.h),
                      _buildInfoRow('Role', widget.user.role.toUpperCase()),
                      if (widget.user.areaKerja != null) ...[
                        SizedBox(height: 8.h),
                        _buildInfoRow('Area Kerja', widget.user.areaKerja!),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // No HP Field
                Text(
                  'Nomor HP',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _noHpController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nomor HP',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(Iconsax.call, color: Colors.grey.shade600, size: 20.sp),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: const Color(0xFF2E7D32), width: 2.w),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor HP tidak boleh kosong';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Nomor HP hanya boleh angka';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // WhatsApp Field
                Text(
                  'WhatsApp',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nomor WhatsApp',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(Iconsax.message, color: Colors.grey.shade600, size: 20.sp),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: const Color(0xFF2E7D32), width: 2.w),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'WhatsApp hanya boleh angka';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Alamat Field
                Text(
                  'Alamat',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _alamatController,
                  maxLines: 3,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Masukkan alamat lengkap',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: const Color(0xFF2E7D32), width: 2.w),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Simpan Perubahan',
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'Poppins',
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          ': ',
          style: TextStyle(
            fontSize: 13.sp,
            fontFamily: 'Poppins',
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'Poppins',
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
