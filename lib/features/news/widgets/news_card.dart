import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/news_model.dart';

/// Card widget displaying a News item matching Sitefinity Admin App UI (Screenshots 1 & 4)
class NewsCard extends StatefulWidget {
  final NewsModel news;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final ValueChanged<bool>? onTogglePublish;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;

  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    this.onDuplicate,
    this.onTogglePublish,
    this.isSelected = false,
    this.onSelectChanged,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant NewsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _checked = widget.isSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPublished = widget.news.status.toLowerCase() == 'published';

    return CustomCard(
      onTap: widget.onTap,
      backgroundColor: widget.isSelected ? const Color(0xFFEBF3FB) : AppColors.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      borderRadius: AppConstants.radiusMedium,
      border: Border.all(
        color: widget.isSelected ? const Color(0xFF003D99).withValues(alpha: 0.3) : AppColors.divider.withValues(alpha: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Select Checkbox
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: _checked,
              activeColor: const Color(0xFF00965E), // Sitefinity green
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: AppColors.border, width: 1.5),
              onChanged: (val) {
                setState(() => _checked = val ?? false);
                widget.onSelectChanged?.call(val);
              },
            ),
          ),
          const SizedBox(width: 8),

          // Green check circle badge for "Published"
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isPublished ? const Color(0xFF00965E) : AppColors.textTertiary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPublished ? Icons.check : Icons.edit_outlined,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Published status column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.news.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.news.status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Last Modified & Author Column (e.g. "Today / by Pooja Shelke")
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDateLabel(widget.news),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'by ${widget.news.author.trim().isNotEmpty ? widget.news.author.trim() : "Pooja Shelke"}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // 3-dots actions menu matching Screenshot 1 (media_1788434414804.png)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textTertiary, size: 20),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
            onSelected: (action) {
              if (action == 'content') {
                widget.onEdit?.call();
              } else if (action == 'unpublish') {
                widget.onTogglePublish?.call(!isPublished);
              } else if (action == 'schedule') {
                UIHelpers.showSnackBar(context, 'Schedule publish/unpublish opened for "${widget.news.title}"');
              } else if (action == 'duplicate') {
                widget.onDuplicate?.call();
              } else if (action == 'permissions') {
                UIHelpers.showSnackBar(context, 'Permissions for "${widget.news.title}"');
              } else if (action == 'history') {
                UIHelpers.showSnackBar(context, 'Revision history loaded (v1.0)');
              } else if (action == 'delete') {
                widget.onDelete?.call();
              }
            },
            itemBuilder: (ctx) => [
              // EDIT header & Content
              PopupMenuItem(
                enabled: false,
                height: 24,
                child: Text(
                  'EDIT',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
              const PopupMenuItem(
                value: 'content',
                height: 36,
                child: Text('Content', style: TextStyle(fontSize: 13, color: Color(0xFF111827))),
              ),
              const PopupMenuDivider(height: 1),

              // Unpublish & Schedule
              PopupMenuItem(
                value: 'unpublish',
                height: 36,
                child: Text(
                  isPublished ? 'Unpublish' : 'Publish',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                ),
              ),
              const PopupMenuItem(
                value: 'schedule',
                height: 36,
                child: Text('Schedule publish/unpublish', style: TextStyle(fontSize: 13, color: Color(0xFF111827))),
              ),
              const PopupMenuDivider(height: 1),

              // Duplicate & Permissions
              const PopupMenuItem(
                value: 'duplicate',
                height: 36,
                child: Text('Duplicate', style: TextStyle(fontSize: 13, color: Color(0xFF111827))),
              ),
              const PopupMenuItem(
                value: 'permissions',
                height: 36,
                child: Text('Set permissions', style: TextStyle(fontSize: 13, color: Color(0xFF111827))),
              ),
              const PopupMenuDivider(height: 1),

              // Revision history, Pages, Items
              const PopupMenuItem(
                value: 'history',
                height: 36,
                child: Text('Revision history', style: TextStyle(fontSize: 13, color: Color(0xFF111827))),
              ),
              const PopupMenuItem(
                enabled: false,
                height: 36,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pages displaying this item', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('0', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                enabled: false,
                height: 36,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Items linking to this item', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('0', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),

              // Delete
              const PopupMenuItem(
                value: 'delete',
                height: 36,
                child: Text('Delete', style: TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDateLabel(NewsModel news) {
    final date = news.lastModified ?? news.publishedDate;
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

