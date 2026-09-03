import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/base_api_service.dart';
import '../models/idealake_content_model.dart';
import '../models/idealake_image_model.dart';
import '../models/service_item_model.dart';
import '../models/sitefinity_module_model.dart';

/// Repository for Home screen data fetching directly from Sitefinity CMS APIs
class HomeRepository {
  final BaseApiService _apiService;
  final SharedPreferences _prefs;
  BaseApiService get apiService => _apiService;

  static const String _bannersCacheKey = 'cached_home_banners_v3';
  static const String _clientsCacheKey = 'cached_client_logos_v3';
  static const String _awardsCacheKey = 'cached_award_badges_v3';
  static const String _servicesCacheKey = 'cached_home_services_v3';
  static const String _contentsCacheKey = 'cached_idealake_contents_v1';

  HomeRepository(this._apiService, this._prefs);

  /// 1. Fetch Dynamic Banners (API removed - dummy data mode)
  Future<List<IdealakeImageModel>> fetchHomeBanners() async {
    return _loadSavedBanners();
  }

  /// 2. Fetch Enterprise Client Logos (API removed - dummy data mode)
  Future<List<IdealakeImageModel>> fetchClientLogos() async {
    return _getCachedClients();
  }

  /// 3. Fetch Award & Accreditation Images (API removed - dummy data mode)
  Future<List<IdealakeImageModel>> fetchAwards() async {
    return _loadSavedAwards();
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

  /// 4. Fetch Dynamic Contents (API removed - dummy data mode)
  Future<List<IdealakeContentModel>> fetchContents() async {
    return _loadSavedContents();
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

  /// 5. Fetch Dynamic Services (API removed - dummy data mode)
  Future<List<ServiceItemModel>> fetchServices() async {
    return _getCachedServices();
  }

  /// 6. Fetch Dynamic Layout Modules (API removed - dummy data mode)
  Future<List<SitefinityModuleModel>> fetchModules() async {
    return _getFallbackModules();
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
