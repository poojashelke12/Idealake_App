import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../repository/news_repository.dart';
import 'news_event.dart';
import 'news_state.dart';

/// ViewModel (BLoC) for News Articles
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _repository;

  NewsBloc(this._repository) : super(const NewsState()) {
    on<NewsFetchEvent>(_onFetch);
    on<NewsSearchEvent>(_onSearch);
    on<NewsCategoryFilterEvent>(_onCategoryFilter);
    on<NewsTagFilterEvent>(_onTagFilter);
  }

  Future<void> _onFetch(NewsFetchEvent event, Emitter<NewsState> emit) async {
    if (!event.forceRefresh && state.response.data != null && state.response.data!.isNotEmpty) {
      // Keep cached data displayed during background refresh
    } else {
      emit(state.copyWith(response: const ApiResponse.loading()));
    }

    try {
      final items = await _repository.fetchNews(
        forceRefresh: event.forceRefresh,
        searchQuery: state.searchQuery,
        categoryFilter: state.selectedCategory,
        tagFilter: state.selectedTag,
      );
      emit(state.copyWith(
        response: ApiResponse.completed(items),
        isOffline: false,
      ));
    } catch (e) {
      final cached = await _repository.fetchNews(
        searchQuery: state.searchQuery,
        categoryFilter: state.selectedCategory,
        tagFilter: state.selectedTag,
      );
      emit(state.copyWith(
        response: ApiResponse.completed(cached),
        isOffline: true,
      ));
    }
  }

  Future<void> _onSearch(NewsSearchEvent event, Emitter<NewsState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    final items = await _repository.fetchNews(
      searchQuery: event.query,
      categoryFilter: state.selectedCategory,
      tagFilter: state.selectedTag,
    );
    emit(state.copyWith(response: ApiResponse.completed(items)));
  }

  Future<void> _onCategoryFilter(NewsCategoryFilterEvent event, Emitter<NewsState> emit) async {
    emit(state.copyWith(selectedCategory: event.category));
    final items = await _repository.fetchNews(
      searchQuery: state.searchQuery,
      categoryFilter: event.category,
      tagFilter: state.selectedTag,
    );
    emit(state.copyWith(response: ApiResponse.completed(items)));
  }

  Future<void> _onTagFilter(NewsTagFilterEvent event, Emitter<NewsState> emit) async {
    emit(state.copyWith(selectedTag: event.tag));
    final items = await _repository.fetchNews(
      searchQuery: state.searchQuery,
      categoryFilter: state.selectedCategory,
      tagFilter: event.tag,
    );
    emit(state.copyWith(response: ApiResponse.completed(items)));
  }
}
