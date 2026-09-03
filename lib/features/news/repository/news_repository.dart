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

    try {
      final queryParams = ODataQueryBuilder()
          .orderBy('PublicationDate', ascending: false)
          .build();

      final response = await _apiService.getGetApiResponse(
        ApiEndpoints.contents,
        queryParameters: queryParams,
      );

      if (response != null && (response['value'] is List || response['data'] is List)) {
        final list = (response['value'] ?? response['data']) as List;
        items = list.map((e) => NewsModel.fromJson(e as Map<String, dynamic>)).toList();
        await _cacheData(items);
      } else {
        items = _getCachedData();
        if (items.isEmpty) {
          items = _getInitialPocNews();
          await _cacheData(items);
        }
      }
    } catch (_) {
      items = _getCachedData();
      if (items.isEmpty) {
        items = _getInitialPocNews();
        await _cacheData(items);
      }
    }

    // Client-side search & category filtering
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      items = items.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.summary.toLowerCase().contains(query) ||
            item.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter.toLowerCase() != 'all') {
      items = items.where((item) => item.category.toLowerCase() == categoryFilter.toLowerCase()).toList();
    }

    if (tagFilter != null && tagFilter.isNotEmpty && tagFilter.toLowerCase() != 'all') {
      items = items.where((item) => item.tags.any((t) => t.toLowerCase() == tagFilter.toLowerCase())).toList();
    }

    items.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
    return items;
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
    return [
      NewsModel(
        id: 'news-001',
        title: 'Idealake Launches Next-Gen Omnichannel Platform for LTFS',
        summary:
            'A unified digital platform built with Flutter and Progress Sitefinity CMS delivers lightning-fast mobile services and seamless content governance.',
        contentHtml: '''
<h3>Digital Transformation at Scale</h3>
<p>Idealake Information Technologies has successfully architected and deployed the next-generation omnichannel digital backbone for LTFS. By integrating Progress Sitefinity's headless CMS engine with high-performance Flutter mobile applications, financial services and corporate updates are synchronized across channels with zero latency.</p>

<h3>Key Architectural Pillars</h3>
<ul>
  <li><strong>Headless CMS:</strong> Content decoupled from presentation for maximum flexibility.</li>
  <li><strong>OData API standard:</strong> Standardized query parameters (\$filter, \$orderby, \$skip) reducing payload sizes.</li>
  <li><strong>Offline Availability:</strong> Intelligent caching layers ensure content accessibility in low connectivity zones.</li>
</ul>

<p>This integration marks a critical milestone in modernizing enterprise content delivery without requiring continuous app store rollouts.</p>
''',
        heroImageUrl: 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?auto=format&fit=crop&w=800&q=80',
        publishedDate: DateTime.now().subtract(const Duration(hours: 5)),
        author: 'Idealake Editorial',
        tags: const ['Fintech', 'Flutter', 'Sitefinity', 'Innovation'],
        category: 'Technology',
      ),
      NewsModel(
        id: 'news-002',
        title: 'Progress Sitefinity 15.1 Headless Services Benchmark Report',
        summary:
            'Performance tests demonstrate sub-120ms JSON response times and 99.99% availability for enterprise mobile content consumers.',
        contentHtml: '''
<h3>High-Velocity API Delivery</h3>
<p>Recent load testing on Sitefinity's REST and OData web services demonstrated outstanding throughput, maintaining sub-120ms response times across 10,000 concurrent mobile requests.</p>
<p>With native support for JWT authentication and granular role-based permissions, enterprise media libraries and structured content types can be securely consumed by iOS and Android clients.</p>
''',
        heroImageUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=800&q=80',
        publishedDate: DateTime.now().subtract(const Duration(days: 1)),
        author: 'Cloud Architecture Team',
        tags: const ['Sitefinity', 'OData', 'Performance'],
        category: 'Product',
      ),
      NewsModel(
        id: 'news-003',
        title: 'LTFS Financial Results: Strong Digital Adoption Drives Q2 Growth',
        summary:
            'Over 75% of customer servicing and corporate engagements are now handled through digital channels and automated self-service apps.',
        contentHtml: '''
<h3>Q2 Financial Highlights</h3>
<p>LTFS announced impressive growth across all retail finance portfolios, driven heavily by accelerated digital adoption and modern customer self-service capabilities designed by Idealake.</p>
<p>The transition to agile headless platforms has lowered operational overhead while elevating customer satisfaction scores across touchpoints.</p>
''',
        heroImageUrl: 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?auto=format&fit=crop&w=800&q=80',
        publishedDate: DateTime.now().subtract(const Duration(days: 3)),
        author: 'Corporate Relations',
        tags: const ['Finance', 'Growth', 'Strategy'],
        category: 'Corporate',
      ),
    ];
  }
}
