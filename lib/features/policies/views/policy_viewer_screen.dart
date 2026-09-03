import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/policy_model.dart';

/// Screen displaying the Policy details, Version history, and Document Viewer
class PolicyViewerScreen extends StatelessWidget {
  final PolicyModel policy;

  const PolicyViewerScreen({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Policy Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.textPrimary),
            onPressed: () {
              UIHelpers.showSuccessSnackBar(
                context,
                'Downloading "${policy.title} (${policy.version})" [${policy.fileSize}]...',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version and Category Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    policy.version,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    policy.category,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Size: ${policy.fileSize}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Policy Title
            Text(
              policy.title,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Effective Date Tag
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Effective Date: ${AppFormatter.formatDate(policy.effectiveDate)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 18),

            // Policy Summary
            Text(
              'Executive Summary',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              policy.summary,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // In-App Document Viewer Preview Card
            Text(
              'Document Preview (Sitefinity Media Engine)',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 220,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppColors.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${policy.title}.pdf',
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sitefinity Protected Document • ${policy.fileSize}',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    text: 'Open Full PDF Document',
                    width: 220,
                    height: 40,
                    prefixIcon: const Icon(Icons.visibility_rounded, color: AppColors.textWhite, size: 16),
                    onPressed: () {
                      UIHelpers.showSuccessSnackBar(context, 'Opening secure PDF document viewer...');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Version Audit Trail & History
            if (policy.previousVersions.isNotEmpty) ...[
              Text(
                'Version Audit Trail & History',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: policy.previousVersions.map((ver) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history_rounded, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Text(
                          ver,
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          'Archived',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
