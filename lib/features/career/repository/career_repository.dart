import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/base_api_service.dart';
import '../models/career_model.dart';

/// Repository for Sitefinity Headless Careers & Job Openings
class CareerRepository {
  final BaseApiService _apiService;
  final SharedPreferences _prefs;

  static const String _cacheKey = 'cached_careers_v1';

  CareerRepository(this._apiService, this._prefs);

  /// Fetches career opportunities from Sitefinity API with caching & offline fallback
  Future<List<CareerModel>> fetchCareers({
    bool forceRefresh = false,
    String? searchQuery,
    String? departmentFilter,
  }) async {
    List<CareerModel> items = [];

    try {
      final response = await _apiService.getGetApiResponse(ApiEndpoints.careers);

      if (response != null && (response['value'] is List || response['data'] is List)) {
        final careerResponse = CareerResponseModel.fromJson(response as Map<String, dynamic>);
        items = careerResponse.value;
        if (items.isNotEmpty) {
          await _cacheData(items);
        }
      } else {
        items = _getCachedData();
        if (items.isEmpty) {
          items = _getInitialPocCareers();
          await _cacheData(items);
        }
      }
    } catch (_) {
      items = _getCachedData();
      if (items.isEmpty) {
        items = _getInitialPocCareers();
        await _cacheData(items);
      }
    }

    // Client-side search and department filtering
    if (departmentFilter != null &&
        departmentFilter.isNotEmpty &&
        departmentFilter.toLowerCase() != 'all') {
      items = items.where((item) {
        return item.department.toLowerCase() == departmentFilter.toLowerCase();
      }).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      items = items.where((item) {
        return item.jobTitle.toLowerCase().contains(query) ||
            item.department.toLowerCase().contains(query) ||
            item.jobLocation.toLowerCase().contains(query) ||
            item.jobExperience.toLowerCase().contains(query) ||
            item.jobResponsibilities.toLowerCase().contains(query) ||
            item.jobRequirements.toLowerCase().contains(query);
      }).toList();
    }

    return items;
  }

  Future<void> _cacheData(List<CareerModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_cacheKey, encoded);
  }

  List<CareerModel> _getCachedData() {
    final raw = _prefs.getString(_cacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        return list.map((e) => CareerModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  /// Initial fallback data matching the official Sitefinity headless payload
  List<CareerModel> _getInitialPocCareers() {
    return const [
      CareerModel(
        id: 'b4d3c402-37e4-4f16-8ad1-410fff0b46a1',
        lastModified: '2023-08-25T09:10:21Z',
        publicationDate: '2023-06-15T11:17:01Z',
        dateCreated: '2023-06-15T11:17:01Z',
        includeInSitemap: true,
        urlName: 'technical-architect-aem',
        itemDefaultUrl: '/technical-architect-aem',
        jobTitle: 'Technical Architect-AEM',
        department: 'TECHNOLOGY',
        jobLinkedinLink: 'https://www.linkedin.com/company/idealake/mycompany/',
        jobExperience: 'Exp 6+ Years',
        jobResponsibilities:
            '<p>Defining whether the current system can be upgraded or if a new system needs to be installed.</p><p>Meeting with the software developers to discuss the system software needs.</p><p>Training staff on system procedures.</p><p>Measuring the performance of the upgraded or newly installed system.</p><p>Providing the company with design ideas and schematics.</p>',
        jobLocation: 'Mumbai',
        jobFacebookLink: 'https://www.facebook.com/idealake?mibextid=ZbWKwL',
        jobRequirements:
            "<p>6+ Years experienced Adobe AEM Developer with strong Java/J2EE background in both frontend web design and AEM integration.</p><p>7+ Years of strong web content management experience with Adobe AEM/CQ5 experience with minimum 5-year experience in full cycle AEM website projects.</p><p>Experience with integrating AEM/CQ5 and CQ6.5 with other products and vendors. Solid experience with CQ5 building blocks including templates, components, dialogs widgets and bundles.</p><p>Experience with Java Content Repository (API) suite, Sling web framework and Apache Felix OSGi framework, and DAM. Hands-on experience for all AEM version upgrades including 6.5. Profile</p><p>Expert knowledge of HTML5, CSS3, JavaScript and JavaScript frameworks/libraries (jQuery, Grunt, Bootstrap etc.), and CSS pre-processing platforms (SASS).</p><p>We are searching for an experienced Technical Architect to oversee the design and implementation of our clients' IT systems.</p>",
        jobPostedDate: '09 Aug 2023',
        urlTitle: 'Technical-Architect-AEM',
        jobInstagramLink: 'https://instagram.com/weareidealake?igshid=YmMyMTA2M2Y=',
        workTypes: 'Full Time',
        provider: 'OpenAccessProvider',
      ),
      CareerModel(
        id: '0557209e-26f4-4c4d-934e-8aeaaa2366b1',
        lastModified: '2023-09-18T09:20:18Z',
        publicationDate: '2023-06-15T11:23:11Z',
        dateCreated: '2023-06-15T11:23:11Z',
        includeInSitemap: true,
        urlName: 'senior-copywriter-group-head',
        itemDefaultUrl: '/senior-copywriter-group-head',
        jobTitle: 'Senior Copywriter / Group Head',
        department: 'CONTENT',
        jobLinkedinLink: 'https://www.linkedin.com/company/idealake/mycompany/',
        jobExperience: 'Exp 5+ Years',
        jobResponsibilities:
            '<p>Collaborating with Designers to develop visuals.</p><p>Creating engaging and original content.</p><p>Editing and guiding Junior Copywriters while content created.</p><p>Demonstrate exceptional writing skills.</p><p>Have excellent attention to detail.</p>',
        jobLocation: 'Mumbai',
        jobFacebookLink: 'https://www.facebook.com/idealake?mibextid=ZbWKwL',
        jobRequirements:
            "<p>5+ Years of experience</p><p>Craft persuasive and crisp copy</p><p>Recognise and formulate a distinct brand voice</p><p>Ideate and conceptualise</p><p>We are seeking for a creative Senior Copywriter to write and edit original content for marketing activities.</p>",
        jobPostedDate: '09 Aug 2023',
        urlTitle: 'Senior-Copywriter-Group-Head',
        jobInstagramLink: 'https://instagram.com/weareidealake?igshid=YmMyMTA2M2Y=',
        workTypes: 'Full Time',
        provider: 'OpenAccessProvider',
      ),
      CareerModel(
        id: 'c7f1a305-1b2c-4e3f-9123-5e9bb2f12345',
        lastModified: '2023-10-01T10:00:00Z',
        publicationDate: '2023-08-10T11:00:00Z',
        dateCreated: '2023-08-10T11:00:00Z',
        includeInSitemap: true,
        urlName: 'senior-flutter-developer',
        itemDefaultUrl: '/senior-flutter-developer',
        jobTitle: 'Senior Flutter Developer',
        department: 'TECHNOLOGY',
        jobLinkedinLink: 'https://www.linkedin.com/company/idealake/mycompany/',
        jobExperience: 'Exp 4+ Years',
        jobResponsibilities:
            '<p>Build high-performance cross-platform Flutter applications with BLoC architecture.</p><p>Integrate headless Sitefinity CMS REST and OData APIs with offline caching.</p><p>Collaborate with designers to deliver smooth animations and responsive Material 3 UI.</p>',
        jobLocation: 'Mumbai (Hybrid)',
        jobFacebookLink: 'https://www.facebook.com/idealake?mibextid=ZbWKwL',
        jobRequirements:
            '<p>4+ Years of mobile software engineering experience.</p><p>Strong Dart, Flutter, BLoC, Dio networking, and local storage proficiency.</p><p>Experience releasing apps on Google Play and Apple App Store.</p>',
        jobPostedDate: '15 Aug 2023',
        urlTitle: 'Senior-Flutter-Developer',
        jobInstagramLink: 'https://instagram.com/weareidealake?igshid=YmMyMTA2M2Y=',
        workTypes: 'Full Time',
        provider: 'OpenAccessProvider',
      ),
    ];
  }
}
