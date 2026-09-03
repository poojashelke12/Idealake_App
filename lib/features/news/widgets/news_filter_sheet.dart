import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../view_model/news_bloc.dart';
import '../view_model/news_event.dart';
import '../view_model/news_state.dart';

/// Filter & Sort Panel for News matching Sitefinity CMS Web UI (Screenshot 3)
class NewsFilterSheet extends StatelessWidget {
  const NewsFilterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<NewsBloc>(),
        child: const NewsFilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        final sortOptions = [
          'Last modified on top',
          'Newest first',
          'Oldest first',
          'Alphabetical (A-Z)',
          'Alphabetical (Z-A)',
        ];

        final filterItems = [
          {'name': 'All news', 'count': state.allNewsCount},
          {'name': 'My news', 'count': state.myNewsCount},
          {'name': 'Draft', 'count': state.draftCount},
          {'name': 'Published', 'count': state.publishedCount},
          {'name': 'Unpublished', 'count': state.unpublishedCount},
          {'name': 'Scheduled', 'count': state.scheduledCount},
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
                    'Filter news',
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

              // 1. Sort news Dropdown (Screenshot 3)
              Text(
                'Sort news',
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
                    value: sortOptions.contains(state.sortOption) ? state.sortOption : sortOptions.first,
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
                        context.read<NewsBloc>().add(NewsSortChangeEvent(val));
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Filter news list with counters (Screenshot 3)
              Text(
                'Filter news',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              ...filterItems.map((item) {
                final name = item['name'] as String;
                final count = item['count'] as int;
                final isSelected = state.statusFilter.toLowerCase() == name.toLowerCase();

                return InkWell(
                  onTap: () {
                    context.read<NewsBloc>().add(NewsStatusFilterEvent(name));
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
      },
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
            hintText: 'Filter by keyword, author, tag...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Clear')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00965E)),
            onPressed: () {
              final q = queryController.text.trim();
              context.read<NewsBloc>().add(NewsSearchEvent(q));
              Navigator.pop(dialogCtx);
            },
            child: const Text('Apply Filter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
