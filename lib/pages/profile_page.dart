import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../config/app_colors.dart';
import '../config/app_strings.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getProfile();

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal memuat profil')),
        );
      } else {
        setState(() {
          _user = User.fromJson(result['data']['user']);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Iconsax.logout, color: AppColors.danger, size: 24.sp),
            SizedBox(width: 12.w),
            const Text(AppStrings.logout),
          ],
        ),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.logout();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout error: ${e.toString()}')));
    }
  }

  String _formatRole(String role) {
    return role
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ')
        .toUpperCase();
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Iconsax.edit_2,
                      label: 'Edit Profil',
                      color: const Color(0xFF2E7D32),
                      onTap: () async {
                        if (_user != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfilePage(user: _user!),
                            ),
                          );
                          _loadProfile();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildActionCard(
                      icon: Iconsax.logout,
                      label: 'Keluar',
                      color: Colors.red,
                      onTap: _logout,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Budget Balance Card (for engineers only)
              if (_user?.role == 'engineer') ...[
                _buildSectionTitle('Saldo Budget'),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Iconsax.wallet_3,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saldo Tersedia',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Rp ${_formatCurrency(_user?.budgetBalance ?? 0)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Iconsax.arrow_right_3,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Personal Information Card
              _buildSectionTitle('Informasi Pribadi'),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Iconsax.user,
                      label: 'Nama',
                      value: _user?.name ?? '-',
                      color: Colors.blue,
                    ),
                    Divider(
                      height: 24.h,
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    _buildInfoTile(
                      icon: Iconsax.sms,
                      label: 'Email',
                      value: _user?.email ?? '-',
                      color: Colors.purple,
                    ),
                    Divider(
                      height: 24.h,
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    _buildInfoTile(
                      icon: Iconsax.call,
                      label: 'No. HP',
                      value: _user?.noHp ?? '-',
                      color: Colors.green,
                    ),
                    Divider(
                      height: 24.h,
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    _buildInfoTile(
                      icon: Iconsax.message,
                      label: 'WhatsApp',
                      value: _user?.whatsapp ?? '-',
                      color: Colors.teal,
                    ),
                    Divider(
                      height: 24.h,
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    _buildInfoTile(
                      icon: Iconsax.location,
                      label: 'Alamat',
                      value: _user?.alamat ?? '-',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Work Information Card
              _buildSectionTitle('Informasi Pekerjaan'),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Iconsax.shield_tick,
                      label: 'Role',
                      value: _formatRole(_user?.role ?? '-'),
                      color: const Color(0xFF2E7D32),
                    ),
                    Divider(
                      height: 24.h,
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    _buildInfoTile(
                      icon: Iconsax.location,
                      label: 'Area Kerja',
                      value: _user?.areaKerja ?? '-',
                      color: Colors.indigo,
                    ),
                    if (_user?.companyName != null) ...[
                      Divider(
                        height: 24.h,
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                      _buildInfoTile(
                        icon: Iconsax.building_4,
                        label: 'Perusahaan',
                        value: _user!.companyName!,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        color: Colors.black87,
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 20.sp, color: color),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
