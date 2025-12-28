import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../config/app_colors.dart';
import '../config/app_strings.dart';
import 'stat_card.dart';

class TicketStatisticsSection extends StatelessWidget {
  final Map<String, dynamic>? ticketStats;
  final bool isLoading;

  const TicketStatisticsSection({
    super.key,
    required this.ticketStats,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik Tiket',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau status tiket Anda',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          )
        else if (ticketStats != null)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.05,
            children: [
              StatCard(
                title: AppStrings.totalAssigned,
                value: ticketStats!['total_assigned']?.toString() ?? '0',
                icon: Iconsax.task_square,
                color: AppColors.primary,
                bgColor: const Color(0xFFFFEBEE),
              ),
              StatCard(
                title: AppStrings.inProgress,
                value: ticketStats!['in_progress']?.toString() ?? '0',
                icon: Iconsax.timer_1,
                color: AppColors.primaryLight,
                bgColor: const Color(0xFFFFF3E0),
              ),
              StatCard(
                title: AppStrings.pending,
                value: ticketStats!['pending']?.toString() ?? '0',
                icon: Iconsax.clock,
                color: AppColors.warning,
                bgColor: const Color(0xFFFFF9C4),
              ),
              StatCard(
                title: AppStrings.completed,
                value: ticketStats!['completed']?.toString() ?? '0',
                icon: Iconsax.tick_circle,
                color: AppColors.success,
                bgColor: const Color(0xFFE8F5E9),
              ),
            ],
          ),
      ],
    );
  }
}
