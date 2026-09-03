import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../news/view_model/news_bloc.dart';
import '../../news/view_model/news_event.dart';

/// Interactive Demo Helper to demonstrate Sitefinity CMS live mobile sync
class CmsDemoDialog extends StatelessWidget {
  const CmsDemoDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CmsDemoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLarge)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.hub_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sitefinity CMS Control',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'POC Demonstration Hub',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 14),
            Text(
              'Simulate Live CMS Sync',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Trigger a live synchronization with Sitefinity headless REST APIs to refresh content and media assets in real-time.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            CustomButton(
              text: 'Simulate Live CMS Sync',
              prefixIcon: const Icon(Icons.sync_rounded, color: AppColors.textWhite, size: 18),
              onPressed: () {
                context.read<NewsBloc>().add(const NewsFetchEvent(forceRefresh: true));
                Navigator.pop(context);
                UIHelpers.showSuccessSnackBar(
                  context,
                  'Triggered Sitefinity live sync! Latest data refreshed.',
                );
              },
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Close',
              buttonType: ButtonType.text,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
