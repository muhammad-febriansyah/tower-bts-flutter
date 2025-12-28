import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';
import '../models/mbp_request.dart';
import '../models/user.dart';
import '../config/app_colors.dart';
import '../config/app_strings.dart';
import '../utils/role_permissions.dart';
import 'mbp_detail_page.dart';
import 'create_mbp_page.dart';

class MbpPage extends StatefulWidget {
  const MbpPage({super.key});

  @override
  State<MbpPage> createState() => _MbpPageState();
}

class _MbpPageState extends State<MbpPage> {
  List<MbpRequest> _mbpRequests = [];
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = true;
  String? _statusFilter;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDashboard();
    _loadMbpRequests();
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

  Future<void> _loadDashboard() async {
    try {
      final result = await ApiService.getMbpDashboard();

      if (!mounted) return;

      if (!result['error']) {
        setState(() {
          _dashboardStats = result['data']['stats'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error loading dashboard: $e');
    }
  }

  Future<void> _loadMbpRequests() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getMbpRequests(
        status: _statusFilter,
      );

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? AppStrings.failedToLoad)),
        );
      } else {
        final List<dynamic> mbpData = result['data']['mbp_requests'] ?? [];
        setState(() {
          _mbpRequests = mbpData.map((json) => MbpRequest.fromJson(json)).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onStatusFilterChanged(String? status) {
    setState(() {
      _statusFilter = status;
    });
    _loadMbpRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'MBP Requests',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDashboard();
          await _loadMbpRequests();
        },
        child: CustomScrollView(
          slivers: [
            // Dashboard Stats
            if (_dashboardStats != null)
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistik MBP',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total',
                              _dashboardStats!['total_requests']?.toString() ?? '0',
                              Iconsax.document_text,
                              AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildStatCard(
                              'Ditugaskan',
                              _dashboardStats!['assigned']?.toString() ?? '0',
                              Iconsax.user_square,
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Dalam Proses',
                              _dashboardStats!['on_progress']?.toString() ?? '0',
                              Iconsax.flash,
                              Colors.purple,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildStatCard(
                              'Selesai',
                              _dashboardStats!['completed']?.toString() ?? '0',
                              Iconsax.tick_circle,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Status Filters
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua', null),
                      SizedBox(width: 8.w),
                      _buildFilterChip('Ditugaskan', 'assigned'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('Dalam Proses', 'on_progress'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('Selesai', 'completed'),
                    ],
                  ),
                ),
              ),
            ),

            // MBP List
            _isLoading
                ? SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _mbpRequests.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.flash_slash,
                                size: 64.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Tidak ada MBP',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.all(16.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildMbpCard(_mbpRequests[index]);
                            },
                            childCount: _mbpRequests.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    // Only HD RSS can create MBP
    if (RolePermissions.canCreateMbp(_currentUser?.role)) {
      return FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateMbpPage(),
            ),
          );
          if (result == true) {
            _loadMbpRequests();
            _loadDashboard();
          }
        },
        icon: const Icon(Iconsax.add),
        label: const Text('Buat MBP'),
        backgroundColor: Colors.blue,
      );
    }
    return null;
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _statusFilter == status;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _onStatusFilterChanged(selected ? status : null);
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontFamily: 'Poppins',
        fontSize: 13.sp,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildMbpCard(MbpRequest mbp) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: mbp.getStatusColor().withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MbpDetailPage(mbpId: mbp.id),
              ),
            ).then((_) => _loadMbpRequests());
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status badge
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: mbp.getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Iconsax.flash,
                        color: mbp.getStatusColor(),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mbp.mbpNumber,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Colors.black87,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _formatDate(mbp.createdAt),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontFamily: 'Poppins',
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: mbp.getStatusColor(),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        mbp.getStatusLabel(),
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

                SizedBox(height: 16.h),
                Divider(height: 1, color: Colors.grey[200]),
                SizedBox(height: 12.h),

                // Site Info
                if (mbp.site != null) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(Iconsax.location, size: 14.sp, color: AppColors.primary),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lokasi Site',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontFamily: 'Poppins',
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '${mbp.site!['site_id'] ?? '-'} - ${mbp.site!['name'] ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontFamily: 'Poppins',
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (mbp.site!['area'] != null) ...[
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(Iconsax.map, size: 12.sp, color: Colors.grey[500]),
                              SizedBox(width: 6.w),
                              Text(
                                mbp.site!['area'] ?? '-',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                // Keterangan Gangguan
                if (mbp.keteranganGangguan != null && mbp.keteranganGangguan!.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Iconsax.info_circle, size: 14.sp, color: Colors.orange[700]),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            mbp.keteranganGangguan!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: 'Poppins',
                              color: Colors.orange[900],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],

                // Engineer Info
                if (mbp.engineer != null && mbp.engineer!['name'] != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.user, size: 14.sp, color: Colors.blue[700]),
                        SizedBox(width: 6.w),
                        Text(
                          mbp.engineer!['name'] ?? '-',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'Poppins',
                            color: Colors.blue[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} menit lalu';
        }
        return '${difference.inHours} jam lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
