import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';

/// Settings Panel for News matching Sitefinity CMS Web UI (Screenshot 2)
class NewsSettingsSheet extends StatelessWidget {
  const NewsSettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewsSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsItems = [
      {'title': 'Set permissions', 'icon': Icons.lock_outline_rounded},
      {'title': 'Settings', 'icon': Icons.tune_rounded},
      {'title': 'Custom fields', 'icon': Icons.view_column_outlined},
      {'title': 'Comments', 'icon': Icons.chat_bubble_outline_rounded},
      {'title': 'Pages where News items are published', 'icon': Icons.web_rounded},
      {'title': 'Recycle bin', 'icon': Icons.delete_outline_rounded},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title & Close (✕)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settings for news',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Manage settings title (Screenshot 2)
          Text(
            'Manage settings',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ...settingsItems.map((item) {
            final title = item['title'] as String;
            final icon = item['icon'] as IconData;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              leading: Icon(icon, size: 20, color: AppColors.textSecondary),
              title: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
              onTap: () {
                Navigator.pop(context);
                UIHelpers.showSnackBar(context, '$title configuration opened');
              },
            );
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
