import 'package:equatable/equatable.dart';
import '../../../core/network/api_response.dart';
import '../models/news_model.dart';

class NewsState extends Equatable {
  final ApiResponse<List<NewsModel>> response;
  final List<NewsModel> allItems;
  final String searchQuery;
  final String selectedCategory;
  final String selectedTag;
  final String statusFilter;
  final String sortOption;
  final bool isOffline;

  const NewsState({
    this.response = const ApiResponse.initial(),
    this.allItems = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.selectedTag = 'All',
    this.statusFilter = 'All news',
    this.sortOption = 'Last modified on top',
    this.isOffline = false,
  });

  // Dynamic filter counters matching Screenshot 3
  int get allNewsCount => allItems.length;
  int get myNewsCount => allItems.where((i) => i.author.toLowerCase().contains('pooja') || i.author.toLowerCase().contains('rakesh')).length;
  int get draftCount => allItems.where((i) => i.status.toLowerCase() == 'draft').length;
  int get publishedCount => allItems.where((i) => i.status.toLowerCase() == 'published').length;
  int get unpublishedCount => allItems.where((i) => i.status.toLowerCase() == 'unpublished').length;
  int get scheduledCount => allItems.where((i) => i.status.toLowerCase() == 'scheduled').length;

  NewsState copyWith({
    ApiResponse<List<NewsModel>>? response,
    List<NewsModel>? allItems,
    String? searchQuery,
    String? selectedCategory,
    String? selectedTag,
    String? statusFilter,
    String? sortOption,
    bool? isOffline,
  }) {
    return NewsState(
      response: response ?? this.response,
      allItems: allItems ?? this.allItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedTag: selectedTag ?? this.selectedTag,
      statusFilter: statusFilter ?? this.statusFilter,
      sortOption: sortOption ?? this.sortOption,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
        response,
        allItems,
        searchQuery,
        selectedCategory,
        selectedTag,
        statusFilter,
        sortOption,
        isOffline,
      ];
}

