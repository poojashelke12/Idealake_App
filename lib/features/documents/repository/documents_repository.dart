import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/base_api_service.dart';
import '../../../core/network/odata_query_builder.dart';
import '../models/document_library_model.dart';
import '../models/document_model.dart';

/// Repository for Sitefinity Document Libraries and Media Files
class DocumentsRepository {
  final BaseApiService _apiService;
  final SharedPreferences _prefs;

  static const String _librariesCacheKey = 'cached_document_libraries_v2';
  static const String _documentsCacheKey = 'cached_documents_v2';
  static const String _downloadedIdsKey = 'downloaded_document_ids_v2';

  DocumentsRepository(this._apiService, this._prefs);

  /// Fetch all Document Libraries (Level 1)
  Future<List<DocumentLibraryModel>> fetchLibraries({
    bool forceRefresh = false,
    String? searchQuery,
  }) async {
    List<DocumentLibraryModel> libraries = [];

    try {
      final queryParams = ODataQueryBuilder().orderBy('Title', ascending: true).build();
      final response = await _apiService.getGetApiResponse(
        ApiEndpoints.documentLibraries,
        queryParameters: queryParams,
      );

      if (response != null && (response['value'] is List || response['data'] is List)) {
        final list = (response['value'] ?? response['data']) as List;
        libraries = list.map((e) => DocumentLibraryModel.fromJson(e as Map<String, dynamic>)).toList();
        await _cacheLibraries(libraries);
      } else {
        libraries = _getCachedLibraries();
        if (libraries.isEmpty) {
          libraries = _getInitialPocLibraries();
          await _cacheLibraries(libraries);
        }
      }
    } catch (_) {
      libraries = _getCachedLibraries();
      if (libraries.isEmpty) {
        libraries = _getInitialPocLibraries();
        await _cacheLibraries(libraries);
      }
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      libraries = libraries.where((lib) {
        return lib.title.toLowerCase().contains(query) ||
            lib.storedIn.toLowerCase().contains(query) ||
            (lib.lastUploadedBy?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return libraries;
  }

  /// Fetch all Documents inside a specific Library (Level 2) directly from Sitefinity CMS OData API
  Future<List<DocumentModel>> fetchDocumentsInLibrary(
    String libraryId, {
    bool forceRefresh = false,
    String? searchQuery,
    bool offlineOnly = false,
  }) async {
    List<DocumentModel> allDocs = [];

    // 1. If not forcing refresh, check local cache first
    if (!forceRefresh) {
      allDocs = _getCachedDocuments();
    }

    // 2. Fetch from live Sitefinity Document API (/api/default/documents)
    if (allDocs.isEmpty || forceRefresh) {
      try {
        final queryParams = ODataQueryBuilder()
            .orderBy('LastModified', ascending: false)
            .build();

        final response = await _apiService.getGetApiResponse(
          ApiEndpoints.documents,
          queryParameters: queryParams,
        );

        if (response != null && (response['value'] is List || response['data'] is List)) {
          final list = (response['value'] ?? response['data']) as List;
          final apiDocs = list
              .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
              .toList();

          if (apiDocs.isNotEmpty) {
            allDocs = apiDocs;
            await _cacheDocuments(allDocs);
          }
        }
      } catch (_) {
        // Fallback to cached documents or initial POC documents on network/auth error
        if (allDocs.isEmpty) {
          allDocs = _getCachedDocuments();
          if (allDocs.isEmpty) {
            allDocs = _getInitialPocDocuments();
            await _cacheDocuments(allDocs);
          }
        }
      }
    }

    if (allDocs.isEmpty) {
      allDocs = _getCachedDocuments();
      if (allDocs.isEmpty) {
        allDocs = _getInitialPocDocuments();
        await _cacheDocuments(allDocs);
      }
    }

    // 3. Filter by libraryId if specified and matches any document
    var items = allDocs.where((doc) {
      if (libraryId.isEmpty || libraryId == 'all' || libraryId == 'lib-001' || libraryId == 'lib-002') {
        return doc.libraryId == libraryId || doc.libraryId.isEmpty || doc.libraryId == 'lib-001';
      }
      return doc.libraryId == libraryId;
    }).toList();

    // If no items matched the specific local ID, present all dynamic documents from API
    if (items.isEmpty && allDocs.isNotEmpty) {
      items = List.from(allDocs);
    }

    // 4. Attach offline downloaded state
    final downloadedIds = _getDownloadedIds();
    items = items.map((doc) => doc.copyWith(isDownloaded: downloadedIds.contains(doc.id))).toList();

    // 5. Offline only filter
    if (offlineOnly) {
      items = items.where((doc) => doc.isDownloaded).toList();
    }

    // 6. Search query filter
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      items = items.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.fileExtension.toLowerCase().contains(query) ||
            item.uploadedBy.toLowerCase().contains(query);
      }).toList();
    }

    return items;
  }

  /// Create a new Document Library (matches "Create a library" button)
  Future<void> createLibrary(DocumentLibraryModel library) async {
    final current = _getCachedLibraries();
    final updated = [library, ...current];
    await _cacheLibraries(updated);
  }

  /// Upload a document into a Library (matches "Upload documents" button)
  Future<void> uploadDocument(DocumentModel document) async {
    final currentDocs = _getCachedDocuments();
    final updatedDocs = [document, ...currentDocs];
    await _cacheDocuments(updatedDocs);

    // Update document count in the library
    final currentLibs = _getCachedLibraries();
    final updatedLibs = currentLibs.map((lib) {
      if (lib.id == document.libraryId) {
        return lib.copyWith(
          documentCount: lib.documentCount + 1,
          lastUploadedDate: DateTime.now(),
          lastUploadedBy: document.uploadedBy,
        );
      }
      return lib;
    }).toList();
    await _cacheLibraries(updatedLibs);
  }

  Future<void> toggleDownload(String id) async {
    final downloadedIds = _getDownloadedIds();
    if (downloadedIds.contains(id)) {
      downloadedIds.remove(id);
    } else {
      downloadedIds.add(id);
    }
    await _prefs.setStringList(_downloadedIdsKey, downloadedIds.toList());
  }

  Set<String> _getDownloadedIds() {
    return _prefs.getStringList(_downloadedIdsKey)?.toSet() ?? <String>{};
  }

  Future<void> _cacheLibraries(List<DocumentLibraryModel> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _prefs.setString(_librariesCacheKey, jsonEncode(jsonList));
  }

  List<DocumentLibraryModel> _getCachedLibraries() {
    final raw = _prefs.getString(_librariesCacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => DocumentLibraryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _cacheDocuments(List<DocumentModel> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _prefs.setString(_documentsCacheKey, jsonEncode(jsonList));
  }

  List<DocumentModel> _getCachedDocuments() {
    final raw = _prefs.getString(_documentsCacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Initial Seed Libraries strictly matching user's Sitefinity Web Screenshot
  List<DocumentLibraryModel> _getInitialPocLibraries() {
    return [
      DocumentLibraryModel(
        id: 'lib-001',
        title: 'ResumeDocument',
        documentCount: 45,
        storedIn: 'Database',
        lastUploadedDate: DateTime(2023, 9, 18, 14, 30),
        lastUploadedBy: 'Rakesh Sunar',
        description: 'Candidate resumes, profile portfolios, and screening evaluations.',
      ),
      const DocumentLibraryModel(
        id: 'lib-002',
        title: 'Default Library',
        documentCount: 0,
        storedIn: 'Database',
        description: 'Default Sitefinity media storage container for uncategorized assets.',
      ),
      DocumentLibraryModel(
        id: 'lib-003',
        title: 'Financial & Annual Reports',
        documentCount: 12,
        storedIn: 'Database',
        lastUploadedDate: DateTime(2026, 2, 20, 10, 15),
        lastUploadedBy: 'Finance Team',
        description: 'Audited statutory balance sheets, investor decks, and compliance filings.',
      ),
      DocumentLibraryModel(
        id: 'lib-004',
        title: 'Corporate & HR Policies',
        documentCount: 8,
        storedIn: 'Azure Blob',
        lastUploadedDate: DateTime(2026, 1, 15, 11, 0),
        lastUploadedBy: 'HR Operations',
        description: 'Employee manuals, benefits handbooks, and code of conduct documentation.',
      ),
    ];
  }

  List<DocumentModel> _getInitialPocDocuments() {
    return [
      // In ResumeDocument (lib-001)
      DocumentModel(
        id: 'doc-101',
        libraryId: 'lib-001',
        libraryTitle: 'ResumeDocument',
        title: 'Senior_Flutter_Engineer_Rakesh_Sunar.pdf',
        description: 'Senior Mobile Application Architect specializing in Flutter, BLoC, and Headless CMS.',
        fileExtension: 'pdf',
        category: 'Engineering',
        fileSize: '1.8 MB',
        downloadUrl: 'https://cms.idealake.com/docs/resume-flutter-rakesh.pdf',
        updatedDate: DateTime(2023, 9, 18, 14, 30),
        uploadedBy: 'Rakesh Sunar',
        isDownloaded: true,
      ),
      DocumentModel(
        id: 'doc-102',
        libraryId: 'lib-001',
        libraryTitle: 'ResumeDocument',
        title: 'Enterprise_Technical_Lead_Profile.docx',
        description: 'Technical Lead profile with 10+ years experience in Sitefinity & ASP.NET backend integration.',
        fileExtension: 'docx',
        category: 'Architecture',
        fileSize: '950 KB',
        downloadUrl: 'https://cms.idealake.com/docs/tech-lead-profile.docx',
        updatedDate: DateTime(2023, 9, 18, 12, 10),
        uploadedBy: 'Rakesh Sunar',
        isDownloaded: true,
      ),
      DocumentModel(
        id: 'doc-103',
        libraryId: 'lib-001',
        libraryTitle: 'ResumeDocument',
        title: 'UI_UX_Product_Designer_Portfolio.pdf',
        description: 'Fintech and enterprise design system lead showcase portfolio.',
        fileExtension: 'pdf',
        category: 'Design',
        fileSize: '4.2 MB',
        downloadUrl: 'https://cms.idealake.com/docs/ui-ux-designer.pdf',
        updatedDate: DateTime(2023, 9, 17, 16, 45),
        uploadedBy: 'Rakesh Sunar',
      ),
      DocumentModel(
        id: 'doc-104',
        libraryId: 'lib-001',
        libraryTitle: 'ResumeDocument',
        title: 'Cloud_DevOps_Specialist_Evaluation.xlsx',
        description: 'Technical evaluation scorecard for Kubernetes, Azure App Service, and CI/CD pipelines.',
        fileExtension: 'xlsx',
        category: 'DevOps',
        fileSize: '420 KB',
        downloadUrl: 'https://cms.idealake.com/docs/devops-scorecard.xlsx',
        updatedDate: DateTime(2023, 9, 16, 11, 20),
        uploadedBy: 'Rakesh Sunar',
      ),

      // In Financial & Annual Reports (lib-003)
      DocumentModel(
        id: 'doc-301',
        libraryId: 'lib-003',
        libraryTitle: 'Financial & Annual Reports',
        title: 'LTFS_Annual_Report_2025_2026.pdf',
        description: 'Full audited statutory balance sheet, auditor declarations, and shareholder presentation.',
        fileExtension: 'pdf',
        category: 'Financial',
        fileSize: '5.2 MB',
        downloadUrl: 'https://cms.idealake.com/docs/ltfs-annual-report-2026.pdf',
        updatedDate: DateTime(2026, 2, 20, 10, 15),
        uploadedBy: 'Finance Team',
        isDownloaded: true,
      ),
      DocumentModel(
        id: 'doc-302',
        libraryId: 'lib-003',
        libraryTitle: 'Financial & Annual Reports',
        title: 'Q3_Digital_Originations_Revenue_Breakdown.xlsx',
        description: 'Quarterly breakdown of digital loan disbursements across mobile and web channels.',
        fileExtension: 'xlsx',
        category: 'Financial',
        fileSize: '1.1 MB',
        downloadUrl: 'https://cms.idealake.com/docs/q3-originations.xlsx',
        updatedDate: DateTime(2026, 2, 14, 09, 30),
        uploadedBy: 'Finance Team',
      ),

      // In Corporate & HR Policies (lib-004)
      DocumentModel(
        id: 'doc-401',
        libraryId: 'lib-004',
        libraryTitle: 'Corporate & HR Policies',
        title: 'Employee_Medical_Benefits_and_Insurance_Manual.docx',
        description: 'Health insurance policies, family coverage terms, and cashless hospitalization procedure.',
        fileExtension: 'docx',
        category: 'Human Resources',
        fileSize: '1.4 MB',
        downloadUrl: 'https://cms.idealake.com/docs/medical-benefits.docx',
        updatedDate: DateTime(2026, 1, 15, 11, 0),
        uploadedBy: 'HR Operations',
      ),
    ];
  }
}
