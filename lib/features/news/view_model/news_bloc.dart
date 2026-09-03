import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../models/news_model.dart';
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
    on<NewsCreateEvent>(_onCreate);
    on<NewsDeleteEvent>(_onDelete);
    on<NewsBulkDeleteEvent>(_onBulkDelete);
    on<NewsDuplicateEvent>(_onDuplicate);
    on<NewsTogglePublishEvent>(_onTogglePublish);
    on<NewsStatusFilterEvent>(_onStatusFilter);
    on<NewsSortChangeEvent>(_onSortChange);
  }

  List<NewsModel> _applyFiltersAndSort({
    required List<NewsModel> all,
    required String searchQuery,
    required String category,
    required String tag,
    required String statusFilter,
    required String sortOption,
  }) {
    List<NewsModel> filtered = List.from(all);

    // 1. Search Query
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(q) ||
            item.summary.toLowerCase().contains(q) ||
            item.contentHtml.toLowerCase().contains(q) ||
            item.author.toLowerCase().contains(q) ||
            item.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    // 2. Category
    if (category.isNotEmpty && category.toLowerCase() != 'all') {
      filtered = filtered.where((item) => item.category.toLowerCase() == category.toLowerCase()).toList();
    }

    // 3. Tag
    if (tag.isNotEmpty && tag.toLowerCase() != 'all') {
      filtered = filtered.where((item) => item.tags.any((t) => t.toLowerCase() == tag.toLowerCase())).toList();
    }

    // 4. Status Filter (matching Screenshot 3)
    final sf = statusFilter.toLowerCase();
    if (sf == 'my news') {
      filtered = filtered.where((item) =>
          item.author.toLowerCase().contains('pooja') ||
          item.author.toLowerCase().contains('rakesh')).toList();
    } else if (sf == 'draft') {
      filtered = filtered.where((item) => item.status.toLowerCase() == 'draft').toList();
    } else if (sf == 'published') {
      filtered = filtered.where((item) => item.status.toLowerCase() == 'published').toList();
    } else if (sf == 'unpublished') {
      filtered = filtered.where((item) => item.status.toLowerCase() == 'unpublished').toList();
    } else if (sf == 'scheduled') {
      filtered = filtered.where((item) => item.status.toLowerCase() == 'scheduled').toList();
    }

    // 5. Sort Option
    if (sortOption == 'Newest first') {
      filtered.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    } else if (sortOption == 'Oldest first') {
      filtered.sort((a, b) => a.publishedDate.compareTo(b.publishedDate));
    } else if (sortOption == 'Alphabetical (A-Z)') {
      filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (sortOption == 'Alphabetical (Z-A)') {
      filtered.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    } else {
      // Default: Last modified on top
      filtered.sort((a, b) =>
          (b.lastModified ?? b.publishedDate).compareTo(a.lastModified ?? a.publishedDate));
    }

    return filtered;
  }

  Future<void> _onFetch(NewsFetchEvent event, Emitter<NewsState> emit) async {
    if (!event.forceRefresh && state.response.data != null && state.response.data!.isNotEmpty) {
      // Keep cached data displayed
    } else {
      emit(state.copyWith(response: const ApiResponse.loading()));
    }

    try {
      final items = await _repository.fetchNews(forceRefresh: event.forceRefresh);
      final display = _applyFiltersAndSort(
        all: items,
        searchQuery: state.searchQuery,
        category: state.selectedCategory,
        tag: state.selectedTag,
        statusFilter: state.statusFilter,
        sortOption: state.sortOption,
      );
      emit(state.copyWith(
        allItems: items,
        response: ApiResponse.completed(display),
        isOffline: false,
      ));
    } catch (e) {
      final cached = await _repository.fetchNews();
      final display = _applyFiltersAndSort(
        all: cached,
        searchQuery: state.searchQuery,
        category: state.selectedCategory,
        tag: state.selectedTag,
        statusFilter: state.statusFilter,
        sortOption: state.sortOption,
      );
      emit(state.copyWith(
        allItems: cached,
        response: ApiResponse.completed(display),
        isOffline: true,
      ));
    }
  }

  Future<void> _onSearch(NewsSearchEvent event, Emitter<NewsState> emit) async {
    emit(state.copyWith(searchQuery: event.query));
    final display = _applyFiltersAndSort(
      all: state.allItems,
      searchQuery: event.query,
      category: state.selectedCategory,
      tag: state.selectedTag,
      statusFilter: state.statusFilter,
      sortOption: state.sortOption,
    );
    emit(state.copyWith(response: ApiResponse.completed(display)));
  }

  Future<void> _onCategoryFilter(NewsCategoryFilterEvent event, Emitter<NewsState> emit) async {
    emit(state.copyWith(selectedCategory: event.category));
    final display = _applyFiltersAndSort(
      all: state.allItems,
      searchQuery: state.searchQuery,
      category: event.category,
      tag: state.selectedTag,
      statusFilter: state.statusFilter,
      sortOption: state.sortOption,
    );
    emit(state.copyWith(response: ApiResponse.completed(display)));
  }

  Future<void> _onTagFilter(NewsTagFilterEvent event, Emitter<NewsState> emit) async {
    emit(state.copyWith(selectedTag: event.tag));
    final display = _applyFiltersAndSort(
      all: state.allItems,
      searchQuery: state.searchQuery,
      category: state.selectedCategory,
      tag: event.tag,
      statusFilter: state.statusFilter,
      sortOption: state.sortOption,
    );
    emit(state.copyWith(response: ApiResponse.completed(display)));
  }

  Future<void> _onStatusFilter(NewsStatusFilterEvent event, Emitter<NewsState> emit) async {
    emit(state.copyWith(statusFilter: event.status));
    final display = _applyFiltersAndSort(
      all: state.allItems,
      searchQuery: state.searchQuery,
      category: state.selectedCategory,
      tag: state.selectedTag,
      statusFilter: event.status,
      sortOption: state.sortOption,
    );
    emit(state.copyWith(response: ApiResponse.completed(display)));
  }

  Future<void> _onSortChange(NewsSortChangeEvent event, Emitter<NewsState> emit) async {
    emit(state.copyWith(sortOption: event.sortOption));
    final display = _applyFiltersAndSort(
      all: state.allItems,
      searchQuery: state.searchQuery,
      category: state.selectedCategory,
      tag: state.selectedTag,
      statusFilter: state.statusFilter,
      sortOption: event.sortOption,
    );
    emit(state.copyWith(response: ApiResponse.completed(display)));
  }

  Future<void> _onCreate(NewsCreateEvent event, Emitter<NewsState> emit) async {
    if (event.newsItem is NewsModel) {
      await _repository.createNewsItem(event.newsItem as NewsModel);
      final items = await _repository.fetchNews();
      final display = _applyFiltersAndSort(
        all: items,
        searchQuery: state.searchQuery,
        category: state.selectedCategory,
        tag: state.selectedTag,
        statusFilter: state.statusFilter,
        sortOption: state.sortOption,
      );
      emit(state.copyWith(allItems: items, response: ApiResponse.completed(display)));
    }
  }

  Future<void> _onDelete(NewsDeleteEvent event, Emitter<NewsState> emit) async {
    await _repository.deleteNewsItem(event.id);
    final items = await _repository.fetchNews();
    final display = _applyFiltersAndSort(
      all: items,
      searchQuery: state.searchQuery,
      category: state.selectedCategory,
      tag: state.selectedTag,
      statusFilter: state.statusFilter,
      sortOption: state.sortOption,
    );
    emit(state.copyWith(allItems: items, response: ApiResponse.completed(display)));
  }

  Future<void> _onBulkDelete(NewsBulkDeleteEvent event, Emitter<NewsState> emit) async {
    await _repository.bulkDeleteNewsItems(event.ids);
    final items = await _repository.fetchNews();
    final display = _applyFiltersAndSort(
      all: items,
      searchQuery: state.searchQuery,
      category: state.selectedCategory,
      tag: state.selectedTag,
      statusFilter: state.statusFilter,
      sortOption: state.sortOption,
    );
    emit(state.copyWith(allItems: items, response: ApiResponse.completed(display)));
  }

  Future<void> _onDuplicate(NewsDuplicateEvent event, Emitter<NewsState> emit) async {
    if (event.item is NewsModel) {
      await _repository.duplicateNewsItem(event.item as NewsModel);
      final items = await _repository.fetchNews();
      final display = _applyFiltersAndSort(
        all: items,
        searchQuery: state.searchQuery,
        category: state.selectedCategory,
        tag: state.selectedTag,
        statusFilter: state.statusFilter,
        sortOption: state.sortOption,
      );
      emit(state.copyWith(allItems: items, response: ApiResponse.completed(display)));
    }
  }

  Future<void> _onTogglePublish(NewsTogglePublishEvent event, Emitter<NewsState> emit) async {
    await _repository.togglePublishStatus(event.id, event.publish);
    final items = await _repository.fetchNews();
    final display = _applyFiltersAndSort(
      all: items,
      searchQuery: state.searchQuery,
      category: state.selectedCategory,
      tag: state.selectedTag,
      statusFilter: state.statusFilter,
      sortOption: state.sortOption,
    );
    emit(state.copyWith(allItems: items, response: ApiResponse.completed(display)));
  }
}

