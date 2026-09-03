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

  static const String _librariesCacheKey = 'cached_document_libraries_v4';
  static const String _documentsCacheKey = 'cached_documents_v4';
  static const String _downloadedIdsKey = 'downloaded_document_ids_v4';

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

    // 3. Filter strictly by libraryId / title
    var items = allDocs.where((doc) {
      if (libraryId == 'lib-002' || libraryId.toLowerCase().contains('default')) {
        return doc.libraryId == 'lib-002' || doc.libraryTitle.toLowerCase() == 'default library';
      }
      if (libraryId == 'lib-001' || libraryId.toLowerCase().contains('resume')) {
        return doc.libraryId == 'lib-001' || doc.libraryTitle.toLowerCase().contains('resume') || doc.libraryId.isEmpty;
      }
      return doc.libraryId == libraryId;
    }).toList();

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

  /// Initial Seed Libraries strictly matching website screenshot: exactly 2 libraries
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
    ];
  }

  /// Seed Documents strictly matching screenshots 2 & 3 (45 documents in ResumeDocument, 0 in Default Library)
  List<DocumentModel> _getInitialPocDocuments() {
    final List<DocumentModel> docs = [];

    final dates = [
      DateTime(2023, 8, 11),
      DateTime(2023, 8, 17),
      DateTime(2023, 8, 17),
      DateTime(2023, 8, 17),
      DateTime(2023, 8, 17),
      DateTime(2023, 8, 17),
      DateTime(2023, 8, 18),
      DateTime(2023, 8, 18),
      DateTime(2023, 8, 20),
      DateTime(2023, 8, 22),
      DateTime(2023, 8, 25),
      DateTime(2023, 9, 1),
      DateTime(2023, 9, 5),
      DateTime(2023, 9, 10),
      DateTime(2023, 9, 18),
    ];

    // Generate 45 items for ResumeDocument matching Screenshot 2 (ts-Support Engineer)
    for (int i = 1; i <= 45; i++) {
      final date = dates[(i - 1) % dates.length];
      docs.add(
        DocumentModel(
          id: 'doc-$i',
          libraryId: 'lib-001',
          libraryTitle: 'ResumeDocument',
          title: 'ts-Support Engineer',
          description: 'Technical Support Engineer candidate profile and evaluation resume document.',
          fileExtension: 'doc',
          category: 'Engineering',
          fileSize: '45 KB',
          downloadUrl: 'https://sitefinityheadlesscmsapi.idealake.com/docs/ts-support-engineer.doc',
          updatedDate: date,
          uploadedBy: 'Rakesh Sunar',
          isDownloaded: i <= 2,
        ),
      );
    }

    return docs;
  }
}
