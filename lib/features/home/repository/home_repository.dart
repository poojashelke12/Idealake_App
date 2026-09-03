import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/base_api_service.dart';
import '../../../core/network/odata_query_builder.dart';
import '../models/idealake_content_model.dart';
import '../models/idealake_image_model.dart';
import '../models/service_item_model.dart';
import '../models/sitefinity_module_model.dart';

/// Repository for Home screen data fetching directly from Sitefinity CMS APIs
class HomeRepository {
  final BaseApiService _apiService;
  final SharedPreferences _prefs;

  static const String _bannersCacheKey = 'cached_home_banners_v3';
  static const String _clientsCacheKey = 'cached_client_logos_v3';
  static const String _awardsCacheKey = 'cached_award_badges_v3';
  static const String _servicesCacheKey = 'cached_home_services_v3';
  static const String _contentsCacheKey = 'cached_idealake_contents_v1';

  HomeRepository(this._apiService, this._prefs);

  /// 1. Fetch Dynamic Banners from Sitefinity /api/idealake/images
  Future<List<IdealakeImageModel>> fetchHomeBanners() async {
    try {
      final response = await _apiService.getGetApiResponse(
        ApiEndpoints.idealakeImages,
      );

      dynamic data = response;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data != null && (data['value'] is List || data['data'] is List || data is List)) {
        final list = (data is List ? data : (data['value'] ?? data['data'])) as List;
        final banners = list
            .map((item) => IdealakeImageModel.fromJson(item as Map<String, dynamic>))
            .where((item) => item.isBanner1920)
            .toList();

        if (banners.isNotEmpty) {
          await _cacheData(_bannersCacheKey, banners.map((e) => e.toJson()).toList());
          return banners;
        }
      }
      return _loadSavedBanners();
    } catch (_) {
      return _loadSavedBanners();
    }
  }

  /// 2. Fetch Enterprise Client Logos from Sitefinity (ParentId eq 60bbc6c5-4757-4697-ab6b-003a78c54c0f)
  Future<List<IdealakeImageModel>> fetchClientLogos() async {
    try {
      final queryParams = ODataQueryBuilder()
          .filter("ParentId eq ${ApiEndpoints.clientImagesParentId}")
          .orderBy('PublicationDate', ascending: false)
          .build();

      final response = await _apiService.getGetApiResponse(
        ApiEndpoints.idealakeImages,
        queryParameters: queryParams,
      );

      if (response != null && (response['value'] is List || response['data'] is List)) {
        final list = (response['value'] ?? response['data']) as List;
        final images = list.map((e) => IdealakeImageModel.fromJson(e as Map<String, dynamic>)).toList();
        if (images.isNotEmpty) {
          await _cacheData(_clientsCacheKey, images.map((e) => e.toJson()).toList());
          return images;
        }
      }
      return _getCachedClients();
    } catch (_) {
      return _getCachedClients();
    }
  }

  /// 3. Fetch Award & Accreditation Images (ParentId eq d7e1016a-bcbb-4e04-bf78-4029b71d7d6a)
  Future<List<IdealakeImageModel>> fetchAwards() async {
    try {
      final queryParams = ODataQueryBuilder()
          .filter("ParentId eq ${ApiEndpoints.awardImagesParentId}")
          .orderBy('PublicationDate', ascending: true)
          .build();

      final response = await _apiService.getGetApiResponse(
        ApiEndpoints.idealakeImages,
        queryParameters: queryParams,
      );

      dynamic data = response;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data != null && (data['value'] is List || data['data'] is List || data is List)) {
        final list = (data is List ? data : (data['value'] ?? data['data'])) as List;
        final images = list
            .map((e) => IdealakeImageModel.fromJson(e as Map<String, dynamic>))
            .where((img) => img.url.isNotEmpty)
            .toList();
        if (images.isNotEmpty) {
          await _cacheData(_awardsCacheKey, images.map((e) => e.toJson()).toList());
          return images;
        }
      }
      return _loadSavedAwards();
    } catch (_) {
      return _loadSavedAwards();
    }
  }

  List<IdealakeImageModel> _loadSavedAwards() {
    final raw = _prefs.getString(_awardsCacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        return list
            .map((e) => IdealakeImageModel.fromJson(e as Map<String, dynamic>))
            .where((img) => img.url.isNotEmpty)
            .toList();
      } catch (_) {}
    }
    return [];
  }

  /// 4. Fetch Dynamic Contents / Articles from Sitefinity /api/idealake/contents
  Future<List<IdealakeContentModel>> fetchContents() async {
    try {
      final response = await _apiService.getGetApiResponse(
        ApiEndpoints.contents,
      );

      dynamic data = response;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data != null && (data['value'] is List || data['data'] is List || data is List)) {
        final list = (data is List ? data : (data['value'] ?? data['data'])) as List;
        final contents = list
            .map((item) => IdealakeContentModel.fromJson(item as Map<String, dynamic>))
            .toList();

        if (contents.isNotEmpty) {
          await _cacheData(_contentsCacheKey, contents.map((e) => e.toJson()).toList());
          return contents;
        }
      }
      return _loadSavedContents();
    } catch (_) {
      return _loadSavedContents();
    }
  }

  List<IdealakeContentModel> _loadSavedContents() {
    final raw = _prefs.getString(_contentsCacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        return list
            .map((e) => IdealakeContentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return [];
  }

  /// 5. Fetch Dynamic Services / Solutions from Sitefinity /contents
  Future<List<ServiceItemModel>> fetchServices() async {
    try {
      final queryParams = {'\$expand': '*'};
      final response = await _apiService.getGetApiResponse(
        ApiEndpoints.contents,
        queryParameters: queryParams,
      );

      if (response != null && (response['value'] is List || response['data'] is List)) {
        final list = (response['value'] ?? response['data']) as List;
        final services = list.map((item) {
          final content = IdealakeContentModel.fromJson(item as Map<String, dynamic>);
          return ServiceItemModel(
            id: content.id,
            title: content.title,
            description: content.summary ?? 'Enterprise technology solutions developed by Idealake.',
            category: content.category ?? 'Technology',
            iconName: _mapIconForTitle(content.title),
          );
        }).toList();

        if (services.isNotEmpty) {
          await _cacheData(_servicesCacheKey, services.map((e) => e.toJson()).toList());
          return services;
        }
      }
      return _getCachedServices();
    } catch (_) {
      return _getCachedServices();
    }
  }

  /// 5. Fetch Dynamic Layout Modules from Sitefinity /modules
  Future<List<SitefinityModuleModel>> fetchModules() async {
    try {
      final queryParams = {'\$expand': '*'};
      final response = await _apiService.getGetApiResponse(
        ApiEndpoints.modules,
        queryParameters: queryParams,
      );

      if (response != null && (response['value'] is List || response['data'] is List)) {
        final list = (response['value'] ?? response['data']) as List;
        return list.map((e) => SitefinityModuleModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return _getFallbackModules();
    } catch (_) {
      return _getFallbackModules();
    }
  }

  String _mapIconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('app') || lower.contains('mobile') || lower.contains('flutter')) {
      return 'devices_rounded';
    } else if (lower.contains('web') || lower.contains('portal') || lower.contains('sitefinity')) {
      return 'web_rounded';
    } else if (lower.contains('fintech') || lower.contains('lending') || lower.contains('loan')) {
      return 'account_balance_wallet_rounded';
    } else if (lower.contains('cloud') || lower.contains('devops') || lower.contains('azure')) {
      return 'cloud_done_rounded';
    } else if (lower.contains('design') || lower.contains('ui') || lower.contains('ux')) {
      return 'brush_rounded';
    }
    return 'api_rounded';
  }

  Future<void> _cacheData(String key, List<Map<String, dynamic>> items) async {
    await _prefs.setString(key, jsonEncode(items));
  }

  List<IdealakeImageModel> _loadSavedBanners() {
    final raw = _prefs.getString(_bannersCacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        return list
            .map((e) => IdealakeImageModel.fromJson(e as Map<String, dynamic>))
            .where((b) => b.isBanner1920)
            .toList();
      } catch (_) {}
    }
    return [];
  }

  List<IdealakeImageModel> _getCachedClients() {
    final raw = _prefs.getString(_clientsCacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        return list.map((e) => IdealakeImageModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return const [
      IdealakeImageModel(
        id: 'c-01',
        title: 'L&T Finance Holdings (LTFS)',
        url: 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?auto=format&fit=crop&w=200&q=80',
        description: 'Leading Non-Banking Financial Company (NBFC)',
      ),
      IdealakeImageModel(
        id: 'c-02',
        title: 'Tata Capital',
        url: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=200&q=80',
        description: 'Diversified Financial Services Group',
      ),
      IdealakeImageModel(
        id: 'c-03',
        title: 'Mahindra Finance',
        url: 'https://images.unsplash.com/photo-1554469384-e58fac16e23a?auto=format&fit=crop&w=200&q=80',
        description: 'Rural and Semi-Urban Lending Enterprise',
      ),
      IdealakeImageModel(
        id: 'c-04',
        title: 'Kotak Mahindra Bank',
        url: 'https://images.unsplash.com/photo-1577495508048-b635879837f1?auto=format&fit=crop&w=200&q=80',
        description: 'Premier Private Sector Banking Institution',
      ),
    ];
  }


  List<ServiceItemModel> _getCachedServices() {
    final raw = _prefs.getString(_servicesCacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        return list.map((e) => ServiceItemModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return const [
      ServiceItemModel(
        id: '1',
        title: 'Cross-Platform Mobile Apps',
        description: 'High-performance native iOS & Android applications built with Flutter.',
        iconName: 'devices_rounded',
        category: 'Development',
      ),
      ServiceItemModel(
        id: '2',
        title: 'Sitefinity Headless Portals',
        description: 'Decoupled web content management with automated OData endpoints.',
        iconName: 'web_rounded',
        category: 'Web',
      ),
      ServiceItemModel(
        id: '3',
        title: 'Fintech & Loan Origination',
        description: 'Automated digital underwriting, payment gateways & analytics.',
        iconName: 'account_balance_wallet_rounded',
        category: 'Fintech',
      ),
      ServiceItemModel(
        id: '4',
        title: 'Enterprise Cloud & DevOps',
        description: 'CI/CD pipeline automation, Docker containers, and Azure cloud hosting.',
        iconName: 'cloud_done_rounded',
        category: 'Cloud',
      ),
      ServiceItemModel(
        id: '5',
        title: 'UI/UX Design Systems',
        description: 'Human-centric user journeys, interaction design & Figma design tokens.',
        iconName: 'brush_rounded',
        category: 'Design',
      ),
      ServiceItemModel(
        id: '6',
        title: 'REST & GraphQL Microservices',
        description: 'Scalable backend API gateways secured with OAuth2 & JWT tokens.',
        iconName: 'api_rounded',
        category: 'Backend',
      ),
    ];
  }

  List<SitefinityModuleModel> _getFallbackModules() {
    return const [
      SitefinityModuleModel(id: 'm1', title: 'Hero Banners', moduleType: 'HeroBanner', sortOrder: 1),
      SitefinityModuleModel(id: 'm2', title: 'Enterprise Clients', moduleType: 'ClientLogos', sortOrder: 2),
      SitefinityModuleModel(id: 'm3', title: 'Our Services', moduleType: 'ServiceGrid', sortOrder: 3),
      SitefinityModuleModel(id: 'm4', title: 'Awards & Recognitions', moduleType: 'Awards', sortOrder: 4),
    ];
  }
}
