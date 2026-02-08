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

    // Add maintenance menu only for engineer
    if (userRole == 'engineer') {
      items.add(
        BottomNavigationBarItem(
          icon: Icon(Iconsax.setting_2, size: 24.sp),
          activeIcon: Icon(Iconsax.setting_2, size: 24.sp),
          label: 'Maintenance',
        ),
      );
    }

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

    // Profile removed - now in app bar

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildNavItems();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon with animated container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.all(isSelected ? 10.r : 6.r),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            isSelected
                                ? (item.activeIcon as Icon).icon
                                : (item.icon as Icon).icon,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade400,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        // Label
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade400,
                            fontSize: isSelected ? 11.sp : 10.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          child: Text(
                            item.label ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
