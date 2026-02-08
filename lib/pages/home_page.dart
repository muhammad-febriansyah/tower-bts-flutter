// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../config/app_colors.dart';
import '../config/app_strings.dart';
import '../widgets/main_bottom_navigation.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/ticket_statistics_section.dart';
import '../utils/role_permissions.dart';
// import '../widgets/quick_actions_section.dart'; // Hidden
import 'tickets_page.dart';
import 'sites_page.dart';
import 'budget_requests_page.dart';
import 'mbp_page.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import 'maintenance_orders_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? _user;
  Map<String, dynamic>? _ticketStats;
  bool _isLoading = true;
  int _unreadNotificationsCount = 0;
  final GlobalKey<TicketsPageState> _ticketsPageKey = GlobalKey<TicketsPageState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final profileResult = await ApiService.getProfile();
      final dashboardResult = await ApiService.getTicketsDashboard();
      final notifCountResult = await ApiService.getUnreadNotificationsCount();

      if (mounted) {
        setState(() {
          if (!profileResult['error']) {
            _user = User.fromJson(profileResult['data']['user']);
          }
          if (!dashboardResult['error']) {
            _ticketStats = dashboardResult['data']['stats'];
          }
          if (!notifCountResult['error']) {
            _unreadNotificationsCount = notifCountResult['data']['unread_count'] ?? 0;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(user: _user),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TicketStatisticsSection(
                    ticketStats: _ticketStats,
                    isLoading: _isLoading,
                  ),
                  // Quick Actions Section - Hidden
                  // const SizedBox(height: 24),
                  // QuickActionsSection(
                  //   onViewTickets: () => setState(() => _selectedIndex = 1),
                  //   onBrowseSites: () => setState(() => _selectedIndex = 2),
                  //   onBudgetRequests: () => setState(() => _selectedIndex = 3),
                  // ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentPage() {
    // Return dashboard if user data not loaded yet
    if (_user == null) {
      return _buildDashboard();
    }

    final hasBudgetAccess = RolePermissions.canAccessBudgetRequests(_user?.role);
    final hasMbpAccess = RolePermissions.canAccessMbp(_user?.role);

    // Dynamic page mapping based on role
    // Engineer/Mitra: 0=Dashboard, 1=Tickets, 2=Sites, 3=Maintenance, 4=Budget, 5=MBP
    // Others with MBP: 0=Dashboard, 1=Tickets, 2=Sites, 3=Maintenance, 4=MBP
    // Profile removed - now accessible via app bar icon

    List<Widget> pages = [
      _buildDashboard(),
      TicketsPage(key: _ticketsPageKey),
      const SitesPage(),
    ];

    // Add Maintenance Orders for engineers
    if (_user?.role == 'engineer') {
      pages.add(const MaintenanceOrdersPage());
    }

    if (hasBudgetAccess) {
      pages.add(const BudgetRequestsPage());
    }

    if (hasMbpAccess) {
      pages.add(const MbpPage());
    }

    // Profile removed from bottom nav

    if (_selectedIndex >= 0 && _selectedIndex < pages.length) {
      return pages[_selectedIndex];
    }

    return _buildDashboard();
  }

  List<String> _getTitles() {
    final hasBudgetAccess = RolePermissions.canAccessBudgetRequests(_user?.role);
    final hasMbpAccess = RolePermissions.canAccessMbp(_user?.role);

    List<String> titles = [
      AppStrings.dashboard,
      AppStrings.tickets,
      AppStrings.sites,
    ];

    // Add Maintenance Orders for engineers
    if (_user?.role == 'engineer') {
      titles.add('Maintenance');
    }

    if (hasBudgetAccess) {
      titles.add(AppStrings.budget);
    }

    if (hasMbpAccess) {
      titles.add('MBP');
    }

    // Profile removed from bottom nav - now in app bar

    return titles;
  }

  @override
  Widget build(BuildContext context) {
    final titles = _getTitles();

    // Safety check for index bounds
    final safeIndex = _selectedIndex >= 0 && _selectedIndex < titles.length
        ? _selectedIndex
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(titles[safeIndex]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Show refresh button only on Tickets page (index 1)
          if (safeIndex == 1)
            IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: () {
                _ticketsPageKey.currentState?.refreshTickets();
              },
              tooltip: 'Refresh',
            ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Iconsax.notification),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  ).then((_) {
                    // Reload unread count when back from notifications page
                    _loadData();
                  });
                },
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        _unreadNotificationsCount > 99 ? '99+' : '$_unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          // Profile Icon
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              radius: 16,
              child: Text(
                _user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              ).then((_) {
                // Reload data when back from profile page
                _loadData();
              });
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _getCurrentPage(),
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        userRole: _user?.role,
      ),
    );
  }
}
