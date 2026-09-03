import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_card.dart';
import '../models/document_model.dart';

/// Card/Row representing an individual Document inside a Library matching Sitefinity Web Admin UI (Screenshots 2 & 3)
class DocumentFileCard extends StatefulWidget {
  final DocumentModel document;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;
  final VoidCallback onTap;
  final VoidCallback onToggleDownload;
  final VoidCallback? onDelete;

  const DocumentFileCard({
    super.key,
    required this.document,
    this.isSelected = false,
    this.onSelectChanged,
    required this.onTap,
    required this.onToggleDownload,
    this.onDelete,
  });

  @override
  State<DocumentFileCard> createState() => _DocumentFileCardState();
}

class _DocumentFileCardState extends State<DocumentFileCard> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant DocumentFileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _checked = widget.isSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = widget.document.fileExtension.toUpperCase();

    return CustomCard(
      onTap: widget.onTap,
      backgroundColor: widget.isSelected ? const Color(0xFFEBF3FB) : AppColors.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      borderRadius: AppConstants.radiusMedium,
      border: Border.all(
        color: widget.isSelected ? const Color(0xFF003D99).withValues(alpha: 0.3) : AppColors.divider.withValues(alpha: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Select Checkbox
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
          const SizedBox(width: 6),

          // Green circle checkmark badge for "Published" (Screenshot 2)
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF00965E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 8),

          // Document File Icon Container (Word DOC icon / PDF icon)
          Container(
            width: 32,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getFileTypeIcon(widget.document.fileExtension),
                  size: 15,
                  color: _getFileTypeColor(widget.document.fileExtension),
                ),
                Text(
                  ext.length > 4 ? ext.substring(0, 4) : ext,
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.bold,
                    color: _getFileTypeColor(widget.document.fileExtension),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Title & Details Column (Responsive)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.document.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text(
                      'Published',
                      style: TextStyle(
                        color: Color(0xFF00965E),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(' • ', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    Text(
                      '$ext, ${widget.document.fileSize}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const Text(' • ', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    Expanded(
                      child: Text(
                        AppFormatter.formatDate(widget.document.updatedDate),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // 3-dots actions popup menu (Screenshot 2)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textTertiary, size: 20),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
            onSelected: (action) {
              if (action == 'preview') {
                widget.onTap();
              } else if (action == 'download') {
                widget.onToggleDownload();
              } else if (action == 'permissions') {
                UIHelpers.showSnackBar(context, 'Permissions for "${widget.document.title}"');
              } else if (action == 'delete') {
                widget.onDelete?.call();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'preview',
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 10),
                    Text('View Details', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(
                      widget.document.isDownloaded ? Icons.delete_outline_rounded : Icons.download_rounded,
                      size: 18,
                      color: widget.document.isDownloaded ? AppColors.error : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.document.isDownloaded ? 'Remove Offline' : 'Save Offline',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'permissions',
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 10),
                    Text('Permissions', style: TextStyle(fontSize: 13)),
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
        return const Color(0xFFDC2626);
      case 'doc':
      case 'docx':
        return const Color(0xFF2563EB);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF16A34A);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF4B5563);
    }
  }
}
