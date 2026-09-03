import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/custom_chip_filter.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../models/news_model.dart';
import '../view_model/news_bloc.dart';
import '../view_model/news_event.dart';
import '../view_model/news_state.dart';
import '../widgets/news_card.dart';
import '../widgets/news_filter_sheet.dart';
import '../widgets/news_settings_sheet.dart';
import 'create_news_screen.dart';
import 'news_detail_screen.dart';

/// Screen displaying the list of published news articles matching Sitefinity Web Admin UI (Screenshots 1-5)
class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Technology', 'Product', 'Corporate', 'Fintech'];
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    context.read<NewsBloc>().add(const NewsFetchEvent(forceRefresh: true));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreateNews({NewsModel? item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNewsScreen(initialNews: item),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NewsModel item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete News Item'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<NewsBloc>().add(NewsDeleteEvent(item.id));
              setState(() => _selectedItemIds.remove(item.id));
              UIHelpers.showSuccessSnackBar(context, 'Deleted "${item.title}"');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmBulkDelete(BuildContext context) {
    if (_selectedItemIds.isEmpty) return;

    final count = _selectedItemIds.length;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Selected News Items'),
        content: Text('Are you sure you want to delete $count selected news item(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<NewsBloc>().add(NewsBulkDeleteEvent(_selectedItemIds.toList()));
              setState(() => _selectedItemIds.clear());
              UIHelpers.showSuccessSnackBar(context, 'Deleted $count item(s)');
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          final newsList = state.response.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline banner
              OfflineBanner(
                isOffline: state.isOffline,
                onRefresh: () {
                  context.read<NewsBloc>().add(const NewsFetchEvent(forceRefresh: true));
                },
              ),

              // Title and Header Action Icons matching Screenshots 1-3
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      'News',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 26,
                      ),
                    ),
                    const Spacer(),
                    // Create a news item Button (Green CTA matching screenshot)
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToCreateNews(),
                        icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        label: const Text(
                          'Create a news item',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00965E), // Sitefinity CMS green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Filter News Icon Button (Screenshot 3)
                    IconButton(
                      icon: const Icon(Icons.filter_alt_outlined, color: AppColors.textSecondary, size: 22),
                      tooltip: 'Filter news',
                      onPressed: () => NewsFilterSheet.show(context),
                    ),

                    // Settings for News Icon Button (Screenshot 2)
                    IconButton(
                      icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 22),
                      tooltip: 'Settings for news',
                      onPressed: () => NewsSettingsSheet.show(context),
                    ),
                  ],
                ),
              ),

              // Search Bar matching Sitefinity Search... input
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Search...',
                onChanged: (q) {
                  context.read<NewsBloc>().add(NewsSearchEvent(q));
                },
              ),

              // Category Filters
              CustomChipFilter(
                categories: _categories,
                selectedCategory: state.selectedCategory,
                onSelected: (cat) {
                  context.read<NewsBloc>().add(NewsCategoryFilterEvent(cat));
                },
              ),

              // Multi-Selection Toolbar Banner (Screenshots 4 & 5)
              if (_selectedItemIds.isNotEmpty)
                _buildSelectionBanner(context, newsList)
              else
                // Standard Column Header row (TITLE / LAST MODIFIED / ACTIONS)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                  child: Row(
                    children: [
                      Text(
                        'TITLE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'LAST MODIFIED',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 28),
                      Text(
                        'ACTIONS',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

              // Dynamic List of News Items
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF00965E),
                  onRefresh: () async {
                    context.read<NewsBloc>().add(const NewsFetchEvent(forceRefresh: true));
                  },
                  child: _buildContent(state, newsList),
                ),
              ),

              // Sitefinity Bottom Footer matching all Screenshots
              _buildSitefinityFooter(newsList.length),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectionBanner(BuildContext context, List<NewsModel> newsList) {
    final allSelected = newsList.isNotEmpty && _selectedItemIds.length == newsList.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF3FB),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: const Color(0xFF003D99).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedItemIds.length} selected • ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF003D99),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                if (allSelected) {
                  _selectedItemIds.clear();
                } else {
                  _selectedItemIds.addAll(newsList.map((e) => e.id));
                }
              });
            },
            child: Text(
              allSelected ? 'Deselect all' : 'Select all',
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF003D99),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const Spacer(),

          // Actions dropdown button matching Screenshot 5 (media_1788434491525.png)
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
            onSelected: (action) {
              if (action == 'content') {
                if (_selectedItemIds.isNotEmpty) {
                  final item = newsList.firstWhere((e) => e.id == _selectedItemIds.first);
                  _navigateToCreateNews(item: item);
                }
              } else if (action == 'unpublish') {
                for (final id in _selectedItemIds) {
                  context.read<NewsBloc>().add(NewsTogglePublishEvent(id, false));
                }
                UIHelpers.showSuccessSnackBar(context, 'Unpublished ${_selectedItemIds.length} item(s)');
              } else if (action == 'schedule') {
                UIHelpers.showSnackBar(context, 'Schedule publish/unpublish opened');
              } else if (action == 'duplicate') {
                if (_selectedItemIds.isNotEmpty) {
                  final item = newsList.firstWhere((e) => e.id == _selectedItemIds.first);
                  context.read<NewsBloc>().add(NewsDuplicateEvent(item));
                  UIHelpers.showSuccessSnackBar(context, 'Duplicated "${item.title}"');
                }
              } else if (action == 'permissions') {
                UIHelpers.showSnackBar(context, 'Set permissions for selected items');
              } else if (action == 'delete') {
                _confirmBulkDelete(context);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                enabled: false,
                height: 24,
                child: Text('EDIT', style: TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
              const PopupMenuItem(
                value: 'content',
                height: 36,
                child: Text('Content', style: TextStyle(fontSize: 13)),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem(
                value: 'unpublish',
                height: 36,
                child: Text('Unpublish', style: TextStyle(fontSize: 13)),
              ),
              const PopupMenuItem(
                value: 'schedule',
                height: 36,
                child: Text('Schedule publish/unpublish', style: TextStyle(fontSize: 13)),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem(
                value: 'duplicate',
                height: 36,
                child: Text('Duplicate', style: TextStyle(fontSize: 13)),
              ),
              const PopupMenuItem(
                value: 'permissions',
                height: 36,
                child: Text('Set permissions', style: TextStyle(fontSize: 13)),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem(
                value: 'delete',
                height: 36,
                child: Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF003D99).withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Actions', style: TextStyle(color: Color(0xFF111827), fontSize: 13, fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: Color(0xFF111827), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(NewsState state, List<NewsModel> newsList) {
    if (state.response.isLoading && (state.response.data == null || state.response.data!.isEmpty)) {
      return const LoadingWidget(message: 'Loading Sitefinity News Articles...');
    }

    if (state.response.isError && (state.response.data == null || state.response.data!.isEmpty)) {
      return ErrorView(
        message: state.response.message,
        onRetry: () {
          context.read<NewsBloc>().add(const NewsFetchEvent(forceRefresh: true));
        },
      );
    }

    if (newsList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 60),
          EmptyStateView(
            title: 'No News Found',
            message: 'No published articles match your filter selection.',
            icon: Icons.newspaper_outlined,
            actionWidget: SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCreateNews(),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Create a news item', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00965E)),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 2, bottom: 16),
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final item = newsList[index];
        final isSelected = _selectedItemIds.contains(item.id);

        return NewsCard(
          news: item,
          isSelected: isSelected,
          onSelectChanged: (val) {
            setState(() {
              if (val == true) {
                _selectedItemIds.add(item.id);
              } else {
                _selectedItemIds.remove(item.id);
              }
            });
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewsDetailScreen(news: item),
              ),
            );
          },
          onEdit: () => _navigateToCreateNews(item: item),
          onDuplicate: () {
            context.read<NewsBloc>().add(NewsDuplicateEvent(item));
            UIHelpers.showSuccessSnackBar(context, 'Duplicated "${item.title}"');
          },
          onTogglePublish: (publish) {
            context.read<NewsBloc>().add(NewsTogglePublishEvent(item.id, publish));
            UIHelpers.showSuccessSnackBar(
              context,
              publish ? 'Published "${item.title}"' : 'Unpublished "${item.title}"',
            );
          },
          onDelete: () => _confirmDelete(context, item),
        );
      },
    );
  }

  Widget _buildSitefinityFooter(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sitefinity CMS 14.1 | Headless API',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 11),
              ),
              Text(
                '$count news',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildFooterLink('Documentation'),
                  const SizedBox(width: 8),
                  _buildFooterLink('Resources'),
                  const SizedBox(width: 8),
                  _buildFooterLink("What's new"),
                  const SizedBox(width: 8),
                  _buildFooterLink('Feedback'),
                ],
              ),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.divider,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('?', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label) {
    return InkWell(
      onTap: () {
        UIHelpers.showSnackBar(context, '$label link clicked');
      },
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: const Color(0xFF003D99),
          fontSize: 10,
        ),
      ),
    );
  }
}


