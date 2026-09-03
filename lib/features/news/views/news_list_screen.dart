import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_chip_filter.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../view_model/news_bloc.dart';
import '../view_model/news_event.dart';
import '../view_model/news_state.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';

/// Screen displaying the list of published news articles from Sitefinity
class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Technology', 'Product', 'Corporate', 'Fintech'];

  @override
  void initState() {
    super.initState();
    context.read<NewsBloc>().add(const NewsFetchEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          return Column(
            children: [
              OfflineBanner(
                isOffline: state.isOffline,
                onRefresh: () {
                  context.read<NewsBloc>().add(const NewsFetchEvent(forceRefresh: true));
                },
              ),
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Search news articles, topics...',
                onChanged: (q) {
                  context.read<NewsBloc>().add(NewsSearchEvent(q));
                },
              ),
              CustomChipFilter(
                categories: _categories,
                selectedCategory: state.selectedCategory,
                onSelected: (cat) {
                  context.read<NewsBloc>().add(NewsCategoryFilterEvent(cat));
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<NewsBloc>().add(const NewsFetchEvent(forceRefresh: true));
                  },
                  child: _buildContent(state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(NewsState state) {
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

    final newsList = state.response.data ?? [];

    if (newsList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 60),
          EmptyStateView(
            title: 'No News Found',
            message: 'No published articles match your filter selection.',
            icon: Icons.newspaper_outlined,
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final item = newsList[index];
        return NewsCard(
          news: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewsDetailScreen(news: item),
              ),
            );
          },
        );
      },
    );
  }
}
