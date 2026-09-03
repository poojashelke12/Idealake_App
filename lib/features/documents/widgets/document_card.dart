import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/document_model.dart';

/// Card displaying Document item in the Media Library
class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback onToggleDownload;

  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onToggleDownload,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      borderRadius: AppConstants.radiusMedium,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File Type Icon container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getFileTypeColor(document.fileExtension).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(
              _getFileTypeIcon(document.fileExtension),
              color: _getFileTypeColor(document.fileExtension),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // Document info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        document.category,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${document.fileSize}',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  document.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  document.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Updated: ${AppFormatter.formatDate(document.updatedDate)}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),

          // Download / Saved status action button
          IconButton(
            icon: Icon(
              document.isDownloaded ? Icons.offline_pin_rounded : Icons.download_for_offline_outlined,
              color: document.isDownloaded ? AppColors.success : AppColors.primary,
              size: 26,
            ),
            onPressed: onToggleDownload,
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileTypeColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return AppColors.error;
      case 'doc':
      case 'docx':
        return AppColors.primaryLight;
      case 'xls':
      case 'xlsx':
        return AppColors.success;
      case 'ppt':
      case 'pptx':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }
}
