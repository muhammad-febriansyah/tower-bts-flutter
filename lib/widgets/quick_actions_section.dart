import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../config/app_colors.dart';
import '../config/app_strings.dart';
import 'quick_action_card.dart';

class QuickActionsSection extends StatelessWidget {
  final VoidCallback onViewTickets;
  final VoidCallback onBrowseSites;
  final VoidCallback onBudgetRequests;

  const QuickActionsSection({
    super.key,
    required this.onViewTickets,
    required this.onBrowseSites,
    required this.onBudgetRequests,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.quickActions,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 12),
        QuickActionCard(
          title: AppStrings.viewAllTickets,
          subtitle: AppStrings.manageTickets,
          icon: Iconsax.document_text,
          color: AppColors.primary,
          onTap: onViewTickets,
        ),
        const SizedBox(height: 10),
        QuickActionCard(
          title: AppStrings.browseSites,
          subtitle: AppStrings.viewAllSites,
          icon: Iconsax.location,
          color: AppColors.primaryLight,
          onTap: onBrowseSites,
        ),
        const SizedBox(height: 10),
        QuickActionCard(
          title: AppStrings.budgetRequests,
          subtitle: AppStrings.viewBudgetRequests,
          icon: Iconsax.wallet_3,
          color: const Color(0xFF2196F3),
          onTap: onBudgetRequests,
        ),
      ],
    );
  }
}
