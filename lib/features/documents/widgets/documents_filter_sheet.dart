import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../models/document_model.dart';
import '../view_model/documents_bloc.dart';
import '../view_model/documents_event.dart';

/// Filter & Sort Panel for Documents matching Sitefinity CMS Web UI (Screenshot 3)
class DocumentsFilterSheet extends StatefulWidget {
  final List<DocumentModel> documents;
  final ValueChanged<String>? onSortChanged;
  final ValueChanged<String>? onStatusFilterChanged;

  const DocumentsFilterSheet({
    super.key,
    required this.documents,
    this.onSortChanged,
    this.onStatusFilterChanged,
  });

  static void show(
    BuildContext context, {
    required List<DocumentModel> documents,
    ValueChanged<String>? onSortChanged,
    ValueChanged<String>? onStatusFilterChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<DocumentsBloc>(),
        child: DocumentsFilterSheet(
          documents: documents,
          onSortChanged: onSortChanged,
          onStatusFilterChanged: onStatusFilterChanged,
        ),
      ),
    );
  }

  @override
  State<DocumentsFilterSheet> createState() => _DocumentsFilterSheetState();
}

class _DocumentsFilterSheetState extends State<DocumentsFilterSheet> {
  String _selectedSort = 'Manually';
  String _selectedStatus = 'All documents';

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      'Manually',
      'Last modified on top',
      'Newest first',
      'Oldest first',
      'Alphabetical (A-Z)',
      'Alphabetical (Z-A)',
    ];

    final totalCount = widget.documents.length;
    final myDocsCount = widget.documents.where((d) => d.uploadedBy.toLowerCase().contains('rakesh') || d.uploadedBy.toLowerCase().contains('pooja')).length;
    final publishedCount = widget.documents.length; // all live documents are published
    const draftCount = 0;
    const unpublishedCount = 0;
    const scheduledCount = 0;

    final filterItems = [
      {'name': 'All documents', 'count': totalCount},
      {'name': 'My documents', 'count': myDocsCount},
      {'name': 'Draft', 'count': draftCount},
      {'name': 'Published', 'count': publishedCount},
      {'name': 'Unpublished', 'count': unpublishedCount},
      {'name': 'Scheduled', 'count': scheduledCount},
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
                'Filter documents',
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
          const SizedBox(height: 16),

          // 1. Sort documents Dropdown (Screenshot 3)
          Text(
            'Sort documents',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSort,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                items: sortOptions.map((opt) {
                  return DropdownMenuItem(
                    value: opt,
                    child: Text(opt, style: AppTextStyles.bodyMedium),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSort = val);
                    widget.onSortChanged?.call(val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Filter documents list with counters (Screenshot 3)
          Text(
            'Filter documents',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          ...filterItems.map((item) {
            final name = item['name'] as String;
            final count = item['count'] as int;
            final isSelected = _selectedStatus.toLowerCase() == name.toLowerCase();

            return InkWell(
              onTap: () {
                setState(() => _selectedStatus = name);
                widget.onStatusFilterChanged?.call(name);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEBF3FB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$name ($count)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? const Color(0xFF003D99) : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check, color: Color(0xFF003D99), size: 16),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // + Custom filter button matching Screenshot 3
          InkWell(
            onTap: () {
              Navigator.pop(context);
              _showCustomFilterDialog(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF003D99)),
                  const SizedBox(width: 8),
                  Text(
                    'Custom filter',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF003D99),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showCustomFilterDialog(BuildContext context) {
    final queryController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Custom Filter'),
        content: TextField(
          controller: queryController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Filter by keyword, extension, author...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Clear')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00965E)),
            onPressed: () {
              final q = queryController.text.trim();
              context.read<DocumentsBloc>().add(DocumentsSearchLibrariesEvent(q));
              Navigator.pop(dialogCtx);
            },
            child: const Text('Apply Filter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
