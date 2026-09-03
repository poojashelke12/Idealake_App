import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/document_library_model.dart';

/// Card/Row representing a Document Library matching Sitefinity Web Table Row (Screenshot 1)
class LibraryCard extends StatefulWidget {
  final DocumentLibraryModel library;
  final bool isGrid;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;
  final VoidCallback onTap;
  final VoidCallback? onActionsTap;
  final VoidCallback? onDelete;

  const LibraryCard({
    super.key,
    required this.library,
    this.isGrid = false,
    this.isSelected = false,
    this.onSelectChanged,
    required this.onTap,
    this.onActionsTap,
    this.onDelete,
  });

  @override
  State<LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<LibraryCard> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant LibraryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _checked = widget.isSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGrid) {
      return _buildGridCard();
    }
    return _buildListRow(context);
  }

  Widget _buildListRow(BuildContext context) {
    final hasDocs = widget.library.documentCount > 0;

    return CustomCard(
      onTap: widget.onTap,
      backgroundColor: widget.isSelected ? const Color(0xFFEBF3FB) : AppColors.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      borderRadius: AppConstants.radiusMedium,
      border: Border.all(
        color: widget.isSelected ? const Color(0xFF003D99).withValues(alpha: 0.3) : AppColors.divider.withValues(alpha: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Select Checkbox (Screenshot 1)
          SizedBox(
            width: 26,
            height: 26,
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

          // Folder Icon in clean container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.folder_outlined,
              color: Color(0xFF4A5568),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // Title & Details Column (Responsive)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.library.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.library.documentCount == 0 ? 'No documents' : '${widget.library.documentCount} documents',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: hasDocs ? AppColors.textSecondary : AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: hasDocs ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      widget.library.storedIn,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    if (widget.library.lastUploadedDate != null) ...[
                      const Text(' • ', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                      Expanded(
                        child: Text(
                          '${AppFormatter.formatDate(widget.library.lastUploadedDate)}${widget.library.lastUploadedBy != null ? ' by ${widget.library.lastUploadedBy}' : ''}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // 3-dots actions menu matching Screenshot 1
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textTertiary, size: 20),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
            onSelected: (action) {
              if (action == 'open') {
                widget.onTap();
              } else if (action == 'permissions') {
                UIHelpers.showSnackBar(context, 'Permissions for "${widget.library.title}"');
              } else if (action == 'delete') {
                widget.onDelete?.call();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.folder_open_outlined, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 10),
                    Text('Open Library', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'permissions',
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 10),
                    Text('Set permissions', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 10),
                    Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard() {
    return CustomCard(
      onTap: widget.onTap,
      backgroundColor: widget.isSelected ? const Color(0xFFEBF3FB) : AppColors.surface,
      padding: const EdgeInsets.all(14.0),
      borderRadius: AppConstants.radiusMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder_outlined, color: Color(0xFF4A5568), size: 24),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
                onPressed: widget.onActionsTap ?? widget.onTap,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.library.title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            widget.library.documentCount == 0 ? 'No documents' : '${widget.library.documentCount} documents',
            style: AppTextStyles.labelSmall.copyWith(
              color: widget.library.documentCount > 0 ? AppColors.textSecondary : AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stored in ${widget.library.storedIn}',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
