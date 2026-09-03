import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/document_library_model.dart';

/// Card/Row representing a Document Library (matches Sitefinity Web Table Row)
class LibraryCard extends StatelessWidget {
  final DocumentLibraryModel library;
  final bool isGrid;
  final VoidCallback onTap;
  final VoidCallback? onActionsTap;

  const LibraryCard({
    super.key,
    required this.library,
    this.isGrid = false,
    required this.onTap,
    this.onActionsTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return _buildGridCard();
    }
    return _buildListRow(context);
  }

  Widget _buildListRow(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      padding: const EdgeInsets.all(16.0),
      borderRadius: AppConstants.radiusMedium,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Folder Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.folder_rounded,
              color: AppColors.secondary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Library Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        library.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        library.documentCount == 0 ? 'No documents' : '${library.documentCount} documents',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Stored In & Last Upload Metadata (matches web screen columns)
                Row(
                  children: [
                    Text(
                      'Stored in: ',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                    ),
                    Text(
                      library.storedIn.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (library.lastUploadedDate != null || library.lastUploadedBy != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last uploaded: ${AppFormatter.formatDate(library.lastUploadedDate)}${library.lastUploadedBy != null ? ' by ${library.lastUploadedBy}' : ''}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 3-dots actions icon (matches web ACTIONS column)
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary),
            onPressed: onActionsTap ?? onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard() {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      borderRadius: AppConstants.radiusMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.folder_rounded, color: AppColors.secondary, size: 28),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
                onPressed: onActionsTap ?? onTap,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            library.title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            library.documentCount == 0 ? 'No documents' : '${library.documentCount} documents',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stored in ${library.storedIn}',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
