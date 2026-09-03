import 'package:equatable/equatable.dart';
import '../../../core/network/api_response.dart';
import '../models/news_model.dart';

class NewsState extends Equatable {
  final ApiResponse<List<NewsModel>> response;
  final String searchQuery;
  final String selectedCategory;
  final String selectedTag;
  final bool isOffline;

  const NewsState({
    this.response = const ApiResponse.initial(),
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.selectedTag = 'All',
    this.isOffline = false,
  });

  NewsState copyWith({
    ApiResponse<List<NewsModel>>? response,
    String? searchQuery,
    String? selectedCategory,
    String? selectedTag,
    bool? isOffline,
  }) {
    return NewsState(
      response: response ?? this.response,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedTag: selectedTag ?? this.selectedTag,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [response, searchQuery, selectedCategory, selectedTag, isOffline];
}
