import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/base_api_service.dart';
import '../../../core/network/odata_query_builder.dart';
import '../models/policy_model.dart';

/// Repository for Organization Policies managed in Sitefinity
class PolicyRepository {
  final BaseApiService _apiService;
  final SharedPreferences _prefs;

  static const String _cacheKey = 'cached_policies_v1';

  PolicyRepository(this._apiService, this._prefs);

  Future<List<PolicyModel>> fetchPolicies({
    bool forceRefresh = false,
    String? searchQuery,
    String? categoryFilter,
  }) async {
    List<PolicyModel> items = [];

    try {
      final queryParams = ODataQueryBuilder()
          .orderBy('EffectiveDate', ascending: false)
          .build();

      final response = await _apiService.getGetApiResponse(
        ApiEndpoints.policies,
        queryParameters: queryParams,
      );

      if (response != null && (response['value'] is List || response['data'] is List)) {
        final list = (response['value'] ?? response['data']) as List;
        items = list.map((e) => PolicyModel.fromJson(e as Map<String, dynamic>)).toList();
        await _cacheData(items);
      } else {
        items = _getCachedData();
        if (items.isEmpty) {
          items = _getInitialPocPolicies();
          await _cacheData(items);
        }
      }
    } catch (_) {
      items = _getCachedData();
      if (items.isEmpty) {
        items = _getInitialPocPolicies();
        await _cacheData(items);
      }
    }

    // Search and Category filtering
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      items = items.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.summary.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query) ||
            item.version.toLowerCase().contains(query);
      }).toList();
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter.toLowerCase() != 'all') {
      items = items.where((item) => item.category.toLowerCase() == categoryFilter.toLowerCase()).toList();
    }

    return items;
  }

  Future<void> _cacheData(List<PolicyModel> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _prefs.setString(_cacheKey, jsonEncode(jsonList));
  }

  List<PolicyModel> _getCachedData() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => PolicyModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  List<PolicyModel> _getInitialPocPolicies() {
    return [
      PolicyModel(
        id: 'pol-001',
        title: 'Information Security & Data Protection Policy',
        category: 'IT & Security',
        version: 'v3.2',
        effectiveDate: DateTime(2026, 1, 15),
        summary:
            'Comprehensive guidelines covering encryption standards, mobile device management, access control, and ISO 27001 data compliance.',
        documentUrl: 'https://cms.idealake.com/docs/infosec-policy-v3.2.pdf',
        fileSize: '2.4 MB',
        previousVersions: const ['v3.1 (2025)', 'v3.0 (2024)', 'v2.5 (2023)'],
        isMandatory: true,
      ),
      PolicyModel(
        id: 'pol-002',
        title: 'Digital Lending & Risk Governance Framework',
        category: 'Compliance',
        version: 'v4.0',
        effectiveDate: DateTime(2026, 2, 1),
        summary:
            'Regulatory policies governing digital credit underwriting, automated KYC verification, customer consent, and RBI statutory reporting.',
        documentUrl: 'https://cms.idealake.com/docs/risk-governance-v4.0.pdf',
        fileSize: '3.1 MB',
        previousVersions: const ['v3.9 (2025)', 'v3.5 (2024)'],
        isMandatory: true,
      ),
      PolicyModel(
        id: 'pol-003',
        title: 'Hybrid Workplace & Remote Access Policy',
        category: 'Human Resources',
        version: 'v2.1',
        effectiveDate: DateTime(2026, 1, 1),
        summary:
            'Guidelines for employees operating in hybrid working environments, including VPN access, secure remote tooling, and working hours.',
        documentUrl: 'https://cms.idealake.com/docs/hybrid-workplace-v2.1.pdf',
        fileSize: '1.1 MB',
        previousVersions: const ['v2.0 (2025)', 'v1.0 (2023)'],
        isMandatory: false,
      ),
      PolicyModel(
        id: 'pol-004',
        title: 'Cloud Infrastructure & API Gateway Security Standards',
        category: 'IT & Security',
        version: 'v1.8',
        effectiveDate: DateTime(2026, 2, 15),
        summary:
            'Architecture standards for microservices deployment, JWT secret rotation, Rate limiting, and Sitefinity OData endpoint security.',
        documentUrl: 'https://cms.idealake.com/docs/cloud-api-standards-v1.8.pdf',
        fileSize: '1.8 MB',
        previousVersions: const ['v1.7 (2025)'],
        isMandatory: true,
      ),
    ];
  }
}
