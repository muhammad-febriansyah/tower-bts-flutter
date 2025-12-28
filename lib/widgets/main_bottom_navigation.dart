import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../config/app_colors.dart';
import '../config/app_strings.dart';
import '../utils/role_permissions.dart';

class MainBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? userRole;

  const MainBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.userRole,
  });

  List<BottomNavigationBarItem> _buildNavItems() {
    final List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: Icon(Iconsax.home_2, size: 24.sp),
        activeIcon: Icon(Iconsax.home_2, size: 24.sp),
        label: AppStrings.dashboard,
      ),
      BottomNavigationBarItem(
        icon: Icon(Iconsax.receipt, size: 24.sp),
        activeIcon: Icon(Iconsax.receipt, size: 24.sp),
        label: AppStrings.tickets,
      ),
      BottomNavigationBarItem(
        icon: Icon(Iconsax.location, size: 24.sp),
        activeIcon: Icon(Iconsax.location, size: 24.sp),
        label: AppStrings.sites,
      ),
    ];

    // Add budget menu only for engineer & mitra
    if (RolePermissions.canAccessBudgetRequests(userRole)) {
      items.add(
        BottomNavigationBarItem(
          icon: Icon(Iconsax.wallet_2, size: 24.sp),
          activeIcon: Icon(Iconsax.wallet_2, size: 24.sp),
          label: AppStrings.budget,
        ),
      );
    }

    // Add MBP menu for authorized roles
    if (RolePermissions.canAccessMbp(userRole)) {
      items.add(
        BottomNavigationBarItem(
          icon: Icon(Iconsax.flash, size: 24.sp),
          activeIcon: Icon(Iconsax.flash, size: 24.sp),
          label: 'MBP',
        ),
      );
    }

    // Profile always last
    items.add(
      BottomNavigationBarItem(
        icon: Icon(Iconsax.user, size: 24.sp),
        activeIcon: Icon(Iconsax.user, size: 24.sp),
        label: AppStrings.profile,
      ),
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: _buildNavItems(),
        ),
      ),
    );
  }
}
