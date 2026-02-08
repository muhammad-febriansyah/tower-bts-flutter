import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/budget_request.dart';
import '../models/user.dart';
import '../config/app_strings.dart';
import '../config/app_colors.dart';
import '../utils/role_permissions.dart';
import 'budget_request_detail_page.dart';
import 'create_budget_request_page.dart';

class BudgetRequestsPage extends StatefulWidget {
  const BudgetRequestsPage({super.key});

  @override
  State<BudgetRequestsPage> createState() => _BudgetRequestsPageState();
}

class _BudgetRequestsPageState extends State<BudgetRequestsPage> {
  List<BudgetRequestDetail> _budgetRequests = [];
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = true;
  String? _selectedStatus;
  User? _currentUser;

  final List<String> _statuses = [
    'pending',
    'approved',
    'rejected',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDashboard();
    _loadBudgetRequests();
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
      final result = await ApiService.getBudgetRequestsDashboard();

      if (!mounted) return;

      if (!result['error']) {
        setState(() {
          _dashboardStats = result['data']['stats'];
        });
      }
    } catch (e) {
      // Silent fail for stats
    } finally {
      if (mounted) {}
    }
  }

  Future<void> _loadBudgetRequests() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getBudgetRequests(
        status: _selectedStatus,
      );

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? AppStrings.failedToLoad)),
        );
      } else {
        final List<dynamic> data = result['data']['budget_requests'] ?? [];
        setState(() {
          _budgetRequests = data
              .map((json) => BudgetRequestDetail.fromJson(json))
              .toList();
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

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'transferred':
        return 'Ditransfer';
      default:
        return status;
    }
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? const Color(0xFF2E7D32))
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? const Color(0xFF2E7D32))
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontFamily: 'Poppins',
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _showFilters() {
    String? tempStatus = _selectedStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.filterBudgetRequests,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        IconButton(
                          icon: Icon(Iconsax.close_circle),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status Filter
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'Semua',
                          isSelected: tempStatus == null,
                          onTap: () {
                            setModalState(() => tempStatus = null);
                          },
                        ),
                        ..._statuses.map((status) => _buildFilterChip(
                              label: _getStatusLabel(status),
                              isSelected: tempStatus == status,
                              color: _getStatusColor(status),
                              onTap: () {
                                setModalState(() => tempStatus = status);
                              },
                            )),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setModalState(() => tempStatus = null);
                              setState(() => _selectedStatus = null);
                              Navigator.pop(context);
                              _loadBudgetRequests();
                            },
                            icon: Icon(Iconsax.refresh),
                            label: const Text('Atur Ulang'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _selectedStatus = tempStatus);
                              Navigator.pop(context);
                              _loadBudgetRequests();
                            },
                            icon: Icon(Iconsax.tick_circle),
                            label: const Text('Terapkan'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'transferred':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';

    // Handle both String and number types
    double? value;
    if (amount is String) {
      value = double.tryParse(amount);
    } else if (amount is num) {
      value = amount.toDouble();
    }

    if (value == null) return 'Rp 0';

    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              fontFamily: 'Poppins',
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDashboard();
          await _loadBudgetRequests();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Current Balance Card (for engineers/mitra)
                  if (_currentUser?.role == 'engineer' || _currentUser?.role == 'mitra')
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _currentUser!.budgetBalance < 500000
                                  ? [Colors.orange.shade700, Colors.orange.shade900]
                                  : [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: (_currentUser!.budgetBalance < 500000
                                        ? Colors.orange
                                        : const Color(0xFF2E7D32))
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Iconsax.wallet_3, color: Colors.white, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Saldo Budget Anda',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_currentUser!.budgetBalance < 500000)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Iconsax.warning_2, color: Colors.white, size: 12.sp),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Saldo Rendah',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                _formatCurrency(_currentUser!.budgetBalance),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (_currentUser!.budgetBalance < 500000) ...[
                                SizedBox(height: 8.h),
                                Text(
                                  'Hubungi admin untuk penambahan saldo jika diperlukan',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Dashboard Cards
                  if (_dashboardStats != null)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistik Budget',
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
                                    'Total Permintaan',
                                    _dashboardStats!['total_requests']
                                            ?.toString() ??
                                        '0',
                                    Iconsax.document_text,
                                    AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildStatCard(
                                    'Menunggu',
                                    _dashboardStats!['pending']?.toString() ??
                                        '0',
                                    Iconsax.timer_1,
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Ditransfer',
                                    _dashboardStats!['transferred']?.toString() ??
                                        '0',
                                    Iconsax.wallet_check,
                                    Colors.blue,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildStatCard(
                                    'Ditolak',
                                    _dashboardStats!['rejected']?.toString() ??
                                        '0',
                                    Iconsax.close_square,
                                    Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryDark],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Anggaran Disetujui',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: 'Poppins',
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _formatCurrency(
                                      _dashboardStats!['total_amount'],
                                    ),
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Divider(height: 1.h),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),

                  // Budget Requests List
                  _budgetRequests.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.wallet_3,
                                  size: 64.sp,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Belum ada permintaan anggaran',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: 'Poppins',
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final request = _budgetRequests[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BudgetRequestDetailPage(
                                          requestId: request.id,
                                        ),
                                      ),
                                    );
                                    _loadBudgetRequests();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(request.status).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Iconsax.wallet,
                                                size: 20,
                                                color: _getStatusColor(request.status),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    request.requestNumber,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  if (request.createdAt != null)
                                                    Row(
                                                      children: [
                                                        Icon(Iconsax.clock, size: 12, color: Colors.grey[500]),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          DateFormat('dd MMM yyyy').format(
                                                            DateTime.parse(request.createdAt!),
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(request.status),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _getStatusLabel(request.status),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (request.troubleTicket != null) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withValues(alpha: 0.05),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Iconsax.receipt, size: 14, color: Colors.blue[700]),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      request.troubleTicket!.ticketNumber,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blue[700],
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  request.troubleTicket!.title,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Iconsax.dollar_square, size: 18, color: AppColors.primary),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _formatCurrency(request.estimatedCost),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Iconsax.arrow_right_3,
                                              size: 14,
                                              color: Colors.grey[400],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }, childCount: _budgetRequests.length),
                          ),
                        ),
                ],
              ),
      ),
      floatingActionButton: RolePermissions.canCreateBudgetRequests(_currentUser?.role)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'filter',
                  onPressed: _showFilters,
                  child: const Icon(Iconsax.filter),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'create',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateBudgetRequestPage(),
                      ),
                    );
                    _loadBudgetRequests();
                  },
                  icon: const Icon(Iconsax.add),
                  label: const Text('Buat Permintaan'),
                ),
              ],
            )
          : FloatingActionButton(
              heroTag: 'filter',
              onPressed: _showFilters,
              child: const Icon(Iconsax.filter),
            ),
    );
  }
}
