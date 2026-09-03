import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../announcements/models/announcement_model.dart';
import '../../announcements/repository/announcement_repository.dart';
import '../../announcements/view_model/announcements_bloc.dart';
import '../../announcements/view_model/announcements_event.dart';

/// Interactive Demo Helper to demonstrate Sitefinity Authoring -> Mobile Instant Sync
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
              'Simulate Live CMS Authoring',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Publish a live announcement into the Sitefinity headless feed to test real-time mobile sync on pull-to-refresh.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            CustomButton(
              text: 'Simulate CMS Publish Item',
              prefixIcon: const Icon(Icons.cloud_upload_rounded, color: AppColors.textWhite, size: 18),
              onPressed: () async {
                final timestamp = DateTime.now();
                final demoAnnouncement = AnnouncementModel(
                  id: 'demo-${timestamp.millisecondsSinceEpoch}',
                  title: '✨ [Sitefinity Live] Digital Lending 2.0 Feature Release',
                  body:
                      'Authored in Sitefinity Admin at ${timestamp.hour}:${timestamp.minute}:${timestamp.second}. Published via Headless OData API without needing an app store release!',
                  effectiveDate: timestamp,
                  audience: 'All Employees',
                  priority: 'Urgent',
                  attachmentName: 'Sitefinity_Live_Payload.json',
                );

                await locator<AnnouncementRepository>().simulatePublishNewAnnouncement(demoAnnouncement);
                if (!context.mounted) return;
                Navigator.pop(context);
                context.read<AnnouncementsBloc>().add(const AnnouncementsFetchEvent(forceRefresh: true));
                UIHelpers.showSuccessSnackBar(
                  context,
                  'Published to Sitefinity! Feed refreshed live.',
                );
              },
            ),
            const SizedBox(height: 12),
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
