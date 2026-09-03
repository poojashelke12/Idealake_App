import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../theme/text_styles.dart';

/// Reusable Empty State View for lists, search, and placeholders
class EmptyStateView extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final Widget? actionWidget;

  const EmptyStateView({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title ?? 'No Data Available',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message ?? AppStrings.noDataFound,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionWidget != null) ...[
              const SizedBox(height: 20),
              actionWidget!,
            ],
          ],
        ),
      ),
    );
  }
}
