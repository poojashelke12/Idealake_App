import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/document_model.dart';

/// Card/Row representing an individual Document inside a Library
class DocumentFileCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback onToggleDownload;
  final VoidCallback? onMoreTap;

  const DocumentFileCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onToggleDownload,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      padding: const EdgeInsets.all(16.0),
      borderRadius: AppConstants.radiusMedium,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getFileTypeColor(document.fileExtension).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getFileTypeIcon(document.fileExtension),
              color: _getFileTypeColor(document.fileExtension),
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${document.fileExtension.toUpperCase()} • ${document.fileSize} • By ${document.uploadedBy}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uploaded: ${AppFormatter.formatDate(document.updatedDate)}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              document.isDownloaded ? Icons.offline_pin_rounded : Icons.download_for_offline_outlined,
              color: document.isDownloaded ? AppColors.success : AppColors.primary,
              size: 24,
            ),
            onPressed: onToggleDownload,
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
            onPressed: onMoreTap ?? onTap,
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
