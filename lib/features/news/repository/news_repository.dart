import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/base_api_service.dart';
import '../../../core/network/odata_query_builder.dart';
import '../models/news_model.dart';

/// Repository for Sitefinity News Articles
class NewsRepository {
  final BaseApiService _apiService;
  final SharedPreferences _prefs;

  static const String _cacheKey = 'cached_news_items_v1';

  NewsRepository(this._apiService, this._prefs);

  Future<List<NewsModel>> fetchNews({
    bool forceRefresh = false,
    String? searchQuery,
    String? categoryFilter,
    String? tagFilter,
  }) async {
    List<NewsModel> items = [];

    // 1. If not forcing refresh, check cache first
    if (!forceRefresh) {
      items = _getCachedData();
    }

    // 2. Fetch from live Sitefinity NewsItems API (/api/idealake/newsitems)
    if (items.isEmpty || forceRefresh) {
      try {
        final queryParams = ODataQueryBuilder()
            .orderBy('PublicationDate', ascending: false)
            .build();

        final response = await _apiService.getGetApiResponse(
          ApiEndpoints.newsItems,
          queryParameters: queryParams,
        );

        if (response != null && (response['value'] is List || response['data'] is List)) {
          final list = (response['value'] ?? response['data']) as List;
          final apiItems = list
              .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
              .toList();

          if (apiItems.isNotEmpty) {
            items = apiItems;
            await _cacheData(items);
          }
        }
      } catch (_) {
        if (items.isEmpty) {
          items = _getCachedData();
          if (items.isEmpty) {
            items = _getInitialPocNews();
            await _cacheData(items);
          }
        }
      }
    }

    if (items.isEmpty) {
      items = _getCachedData();
      if (items.isEmpty) {
        items = _getInitialPocNews();
        await _cacheData(items);
      }
    }

    // 3. Client-side search & category filtering
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      items = items.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.summary.toLowerCase().contains(query) ||
            item.contentHtml.toLowerCase().contains(query) ||
            item.author.toLowerCase().contains(query) ||
            item.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter.toLowerCase() != 'all') {
      items = items.where((item) => item.category.toLowerCase() == categoryFilter.toLowerCase()).toList();
    }

    if (tagFilter != null && tagFilter.isNotEmpty && tagFilter.toLowerCase() != 'all') {
      items = items.where((item) => item.tags.any((t) => t.toLowerCase() == tagFilter.toLowerCase())).toList();
    }

    items.sort((a, b) => (b.lastModified ?? b.publishedDate).compareTo(a.lastModified ?? a.publishedDate));
    return items;
  }

  /// Create and Publish or Save Draft a new News item
  Future<void> createNewsItem(NewsModel newsItem) async {
    final current = _getCachedData();
    final updated = [newsItem, ...current];
    await _cacheData(updated);

    // Attempt to post to live backend
    try {
      await _apiService.getPostApiResponse(
        ApiEndpoints.newsItems,
        newsItem.toJson(),
      );
    } catch (_) {
      // Retained in local cache
    }
  }

  /// Delete a news item by ID
  Future<void> deleteNewsItem(String id) async {
    final current = _getCachedData();
    final updated = current.where((item) => item.id != id).toList();
    await _cacheData(updated);
  }

  /// Bulk delete news items by list of IDs
  Future<void> bulkDeleteNewsItems(List<String> ids) async {
    final current = _getCachedData();
    final idSet = ids.toSet();
    final updated = current.where((item) => !idSet.contains(item.id)).toList();
    await _cacheData(updated);
  }

  /// Duplicate a news item
  Future<NewsModel> duplicateNewsItem(NewsModel original) async {
    final now = DateTime.now();
    final duplicated = original.copyWith(
      id: 'news-${now.millisecondsSinceEpoch}',
      title: '${original.title} (Copy)',
      urlName: '${original.urlName}-copy',
      dateCreated: now,
      lastModified: now,
      publishedDate: now,
      status: 'Draft',
    );
    await createNewsItem(duplicated);
    return duplicated;
  }

  /// Toggle publish / unpublish status of a news item
  Future<void> togglePublishStatus(String id, bool publish) async {
    final current = _getCachedData();
    final updated = current.map((item) {
      if (item.id == id) {
        return item.copyWith(
          status: publish ? 'Published' : 'Unpublished',
          lastModified: DateTime.now(),
        );
      }
      return item;
    }).toList();
    await _cacheData(updated);
  }

  Future<void> _cacheData(List<NewsModel> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _prefs.setString(_cacheKey, jsonEncode(jsonList));
  }

  List<NewsModel> _getCachedData() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => NewsModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  List<NewsModel> _getInitialPocNews() {
    final now = DateTime.now();
    return [
      NewsModel(
        id: 'news-001',
        title: 'test1',
        summary: 'Sitefinity Headless CMS news update and publication notice.',
        contentHtml: '<p>Real-time news item created and published from Sitefinity Headless CMS admin panel.</p>',
        publishedDate: now,
        lastModified: now,
        dateCreated: now,
        author: 'Pooja Shelke',
        urlName: 'test1',
        itemDefaultUrl: '/${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/test1',
        allowComments: true,
        includeInSitemap: true,
        status: 'Published',
        tags: const ['Sitefinity', 'CMS', 'Headless'],
        category: 'Technology',
      ),
      NewsModel(
        id: 'news-002',
        title: 'test',
        summary: 'General enterprise announcements and digital transformation initiatives.',
        contentHtml: '<p>Comprehensive enterprise updates published across omni-channel mobile apps.</p>',
        publishedDate: now.subtract(const Duration(days: 1)),
        lastModified: now.subtract(const Duration(days: 1)),
        dateCreated: now.subtract(const Duration(days: 1)),
        author: 'Pooja Shelke',
        urlName: 'test',
        itemDefaultUrl: '/${now.year}/${now.month.toString().padLeft(2, '0')}/${(now.day - 1).toString().padLeft(2, '0')}/test',
        allowComments: true,
        includeInSitemap: true,
        status: 'Published',
        tags: const ['Innovation', 'LTFS'],
        category: 'Corporate',
      ),
    ];
  }
}
