import 'package:flutter_test/flutter_test.dart';
import 'package:idealake_poc_ltfs/core/constants/api_endpoints.dart';
import 'package:idealake_poc_ltfs/core/network/base_api_service.dart';
import 'package:idealake_poc_ltfs/features/documents/repository/documents_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService implements BaseApiService {
  String? lastCalledUrl;
  Map<String, String>? lastHeaders;
  dynamic mockResponse;

  @override
  Future<dynamic> getGetApiResponse(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    lastCalledUrl = url;
    lastHeaders = headers;
    return mockResponse;
  }

  @override
  Future<dynamic> getPostApiResponse(String url, dynamic data,
      {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    return null;
  }

  @override
  Future<dynamic> getPutApiResponse(String url, dynamic data,
      {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    return null;
  }

  @override
  Future<dynamic> getPatchApiResponse(String url, dynamic data,
      {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    return null;
  }

  @override
  Future<dynamic> getDeleteApiResponse(String url,
      {dynamic data, Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    return null;
  }
}

void main() {
  late MockApiService mockApiService;
  late SharedPreferences prefs;
  late DocumentsRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'test_login_access_token_xyz',
      'sf_token_id': '0f98ea2d-ca27-4041-8a6c-1e80214c50eb',
    });
    prefs = await SharedPreferences.getInstance();
    mockApiService = MockApiService();
    repository = DocumentsRepository(mockApiService, prefs);
  });

  test('ResumeDocument calls document API with login token and cookie, reflecting latest data', () async {
    mockApiService.mockResponse = {
      'value': [
        {
          'Id': 'doc-live-101',
          'Title': 'Candidate-Resume-Live.pdf',
          'Extension': '.pdf',
          'TotalSize': 2048576,
          'Url': '/docs/default-source/resumes/candidate.pdf',
          'Author': 'HR Admin',
          'LastModified': '2026-09-04T08:00:00Z',
        },
      ],
    };

    final docs = await repository.fetchDocumentsInLibrary(
      'lib-001',
      libraryTitle: 'ResumeDocument',
      forceRefresh: true,
    );

    // Verify correct API endpoint was called
    expect(mockApiService.lastCalledUrl, ApiEndpoints.documents);

    // Verify latest token from login API was passed in Authorization header
    expect(mockApiService.lastHeaders?['Authorization'], 'Bearer test_login_access_token_xyz');
    expect(mockApiService.lastHeaders?['Cookie'], 'SF-TokenId=0f98ea2d-ca27-4041-8a6c-1e80214c50eb');

    // Verify document was reflected in ResumeDocument
    expect(docs.length, 1);
    expect(docs.first.id, 'doc-live-101');
    expect(docs.first.title, 'Candidate-Resume-Live.pdf');
    expect(docs.first.libraryTitle, 'ResumeDocument');
  });

  test('Default Library keeps its original state (empty) and does not reflect ResumeDocument API data', () async {
    final docs = await repository.fetchDocumentsInLibrary(
      'lib-002',
      libraryTitle: 'Default Library',
      forceRefresh: true,
    );

    // Default Library should remain empty as per requirement
    expect(docs.isEmpty, true);
  });
}
