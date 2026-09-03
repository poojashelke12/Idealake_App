import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/base_api_service.dart';
import '../../../core/network/odata_query_builder.dart';
import '../models/announcement_model.dart';

/// Repository for fetching, caching, and managing Sitefinity Announcements
class AnnouncementRepository {
  final BaseApiService _apiService;
  final SharedPreferences _prefs;

  static const String _cacheKey = 'cached_announcements_v1';
  static const String _readIdsKey = 'read_announcement_ids_v1';

  AnnouncementRepository(this._apiService, this._prefs);

  Future<List<AnnouncementModel>> fetchAnnouncements({
    bool forceRefresh = false,
    String? searchQuery,
    String? audienceFilter,
  }) async {
    List<AnnouncementModel> items = [];

    try {
      final queryParams = ODataQueryBuilder()
          .orderBy('EffectiveDate', ascending: false)
          .filterActiveOnly()
          .build();

      final response = await _apiService.getGetApiResponse(
        ApiEndpoints.contents,
        queryParameters: queryParams,
      );

      if (response != null && (response['value'] is List || response['data'] is List)) {
        final list = (response['value'] ?? response['data']) as List;
        items = list.map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>)).toList();
        await _cacheData(items);
      } else {
        items = _getCachedData();
        if (items.isEmpty) {
          items = _getInitialPocAnnouncements();
          await _cacheData(items);
        }
      }
    } catch (_) {
      // Fallback to local cache for offline-first behaviour
      items = _getCachedData();
      if (items.isEmpty) {
        items = _getInitialPocAnnouncements();
        await _cacheData(items);
      }
    }

    // Apply Read state from local storage
    final readIds = _getReadIds();
    items = items.map((item) => item.copyWith(isRead: readIds.contains(item.id))).toList();

    // Client-side search & filtering
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      items = items.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.body.toLowerCase().contains(query) ||
            item.audience.toLowerCase().contains(query);
      }).toList();
    }

    if (audienceFilter != null && audienceFilter.isNotEmpty && audienceFilter.toLowerCase() != 'all') {
      items = items.where((item) => item.audience.toLowerCase() == audienceFilter.toLowerCase()).toList();
    }

    // Order newest first
    items.sort((a, b) => b.effectiveDate.compareTo(a.effectiveDate));
    return items;
  }

  Future<void> markAsRead(String id) async {
    final readIds = _getReadIds();
    if (!readIds.contains(id)) {
      readIds.add(id);
      await _prefs.setStringList(_readIdsKey, readIds.toList());
    }
  }

  Set<String> _getReadIds() {
    return _prefs.getStringList(_readIdsKey)?.toSet() ?? <String>{};
  }

  Future<void> _cacheData(List<AnnouncementModel> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _prefs.setString(_cacheKey, jsonEncode(jsonList));
  }

  List<AnnouncementModel> _getCachedData() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => AnnouncementModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Live Demo Helper: Allows adding/editing an announcement in local CMS cache to test pull-to-refresh
  Future<void> simulatePublishNewAnnouncement(AnnouncementModel newAnnouncement) async {
    final current = _getCachedData();
    final updated = [newAnnouncement, ...current.where((e) => e.id != newAnnouncement.id)];
    await _cacheData(updated);
  }

  List<AnnouncementModel> _getInitialPocAnnouncements() {
    return [
      AnnouncementModel(
        id: 'ann-001',
        title: 'LTFS Annual Digital Summit & Q3 Townhall',
        body:
            'Join us this Friday at 3:00 PM IST for our comprehensive quarterly townhall discussing Sitefinity Headless CMS integration, Q3 milestones, and the enterprise roadmap.',
        effectiveDate: DateTime.now().subtract(const Duration(hours: 2)),
        expiryDate: DateTime.now().add(const Duration(days: 14)),
        audience: 'All Employees',
        priority: 'Urgent',
        attachmentName: 'Townhall_Agenda_Q3.pdf',
      ),
      AnnouncementModel(
        id: 'ann-002',
        title: 'New Information Security & Mobile Compliance Guidelines',
        body:
            'Idealake and LTFS have updated standard authentication and device compliance protocols. All teams are requested to review the revised guidelines.',
        effectiveDate: DateTime.now().subtract(const Duration(hours: 14)),
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        audience: 'IT & Engineering',
        priority: 'High',
        attachmentName: 'InfoSec_Guidelines_2026.pdf',
      ),
      AnnouncementModel(
        id: 'ann-003',
        title: 'Scheduled Cloud Infrastructure Maintenance Window',
        body:
            'Routine server maintenance and database indexing will occur this Sunday between 01:00 AM - 04:00 AM IST. API endpoints will maintain 99.9% uptime with failover clusters.',
        effectiveDate: DateTime.now().subtract(const Duration(days: 1)),
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        audience: 'Operations',
        priority: 'Normal',
      ),
      AnnouncementModel(
        id: 'ann-004',
        title: 'Sitefinity Headless Content Engine Live Demonstration',
        body:
            'Our Progress Sitefinity CMS Headless Content Engine POC is officially operational. Content changes authored in CMS will reflect instantly on mobile upon refresh.',
        effectiveDate: DateTime.now().subtract(const Duration(days: 2)),
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        audience: 'All Employees',
        priority: 'High',
      ),
    ];
  }
}
