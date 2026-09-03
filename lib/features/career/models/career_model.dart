import 'package:equatable/equatable.dart';

/// Response wrapper for Sitefinity OData careers endpoint
class CareerResponseModel {
  final String? odataContext;
  final List<CareerModel> value;

  const CareerResponseModel({
    this.odataContext,
    required this.value,
  });

  factory CareerResponseModel.fromJson(Map<String, dynamic> json) {
    List<CareerModel> careerItems = [];
    if (json['value'] is List) {
      careerItems = (json['value'] as List)
          .map((item) => CareerModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (json['data'] is List) {
      careerItems = (json['data'] as List)
          .map((item) => CareerModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return CareerResponseModel(
      odataContext: json['@odata.context']?.toString(),
      value: careerItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '@odata.context': odataContext,
      'value': value.map((e) => e.toJson()).toList(),
    };
  }
}

/// Sitefinity Career Item Model
class CareerModel extends Equatable {
  final String id;
  final String lastModified;
  final String publicationDate;
  final String dateCreated;
  final bool includeInSitemap;
  final String urlName;
  final String itemDefaultUrl;
  final String jobTitle;
  final String department;
  final String jobLinkedinLink;
  final String jobFacebookLink;
  final String jobInstagramLink;
  final String jobExperience;
  final String jobResponsibilities;
  final String jobLocation;
  final String jobRequirements;
  final String jobPostedDate;
  final String urlTitle;
  final String workTypes;
  final String provider;

  const CareerModel({
    required this.id,
    this.lastModified = '',
    this.publicationDate = '',
    this.dateCreated = '',
    this.includeInSitemap = true,
    this.urlName = '',
    this.itemDefaultUrl = '',
    required this.jobTitle,
    required this.department,
    this.jobLinkedinLink = '',
    this.jobFacebookLink = '',
    this.jobInstagramLink = '',
    this.jobExperience = '',
    this.jobResponsibilities = '',
    this.jobLocation = 'Mumbai',
    this.jobRequirements = '',
    this.jobPostedDate = '',
    this.urlTitle = '',
    this.workTypes = 'Full Time',
    this.provider = 'OpenAccessProvider',
  });

  factory CareerModel.fromJson(Map<String, dynamic> json) {
    return CareerModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      lastModified: json['LastModified']?.toString() ?? '',
      publicationDate: json['PublicationDate']?.toString() ?? '',
      dateCreated: json['DateCreated']?.toString() ?? '',
      includeInSitemap: json['IncludeInSitemap'] is bool ? json['IncludeInSitemap'] as bool : true,
      urlName: json['UrlName']?.toString() ?? '',
      itemDefaultUrl: json['ItemDefaultUrl']?.toString() ?? '',
      jobTitle: json['JobTitle']?.toString() ?? json['jobTitle']?.toString() ?? '',
      department: json['Department']?.toString() ?? json['department']?.toString() ?? 'TECHNOLOGY',
      jobLinkedinLink: json['JoblinkedinLink']?.toString() ?? json['jobLinkedinLink']?.toString() ?? '',
      jobFacebookLink: json['JobFacebooklink']?.toString() ?? json['jobFacebookLink']?.toString() ?? '',
      jobInstagramLink: json['JobInstagramlink']?.toString() ?? json['jobInstagramLink']?.toString() ?? '',
      jobExperience: json['JobExperience']?.toString() ?? json['jobExperience']?.toString() ?? '',
      jobResponsibilities: json['JobResponsibilities']?.toString() ?? json['jobResponsibilities']?.toString() ?? '',
      jobLocation: json['JobLocation']?.toString() ?? json['jobLocation']?.toString() ?? 'Mumbai',
      jobRequirements: json['JobRequirements']?.toString() ?? json['jobRequirements']?.toString() ?? '',
      jobPostedDate: json['JobPostedDate']?.toString() ?? json['jobPostedDate']?.toString() ?? '',
      urlTitle: json['UrlTitle']?.toString() ?? '',
      workTypes: json['WorkTypes']?.toString() ?? json['workTypes']?.toString() ?? 'Full Time',
      provider: json['Provider']?.toString() ?? 'OpenAccessProvider',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'LastModified': lastModified,
      'PublicationDate': publicationDate,
      'DateCreated': dateCreated,
      'IncludeInSitemap': includeInSitemap,
      'UrlName': urlName,
      'ItemDefaultUrl': itemDefaultUrl,
      'JobTitle': jobTitle,
      'Department': department,
      'JoblinkedinLink': jobLinkedinLink,
      'JobFacebooklink': jobFacebookLink,
      'JobInstagramlink': jobInstagramLink,
      'JobExperience': jobExperience,
      'JobResponsibilities': jobResponsibilities,
      'JobLocation': jobLocation,
      'JobRequirements': jobRequirements,
      'JobPostedDate': jobPostedDate,
      'UrlTitle': urlTitle,
      'WorkTypes': workTypes,
      'Provider': provider,
    };
  }

  /// Parses HTML into clean bullet list items
  List<String> get responsibilitiesList => _parseHtmlToList(jobResponsibilities);

  /// Parses requirements HTML into clean bullet list items
  List<String> get requirementsList => _parseHtmlToList(jobRequirements);

  /// Formats department display (e.g., 'TECHNOLOGY' -> 'Technology')
  String get formattedDepartment {
    if (department.isEmpty) return 'Technology';
    return department[0].toUpperCase() + department.substring(1).toLowerCase();
  }

  /// Extracts short summary description for cards
  String get shortDescription {
    final reqs = requirementsList;
    if (reqs.isNotEmpty) {
      // Often the last item in Sitefinity HTML has the role overview paragraph
      for (final r in reqs.reversed) {
        if (r.length > 50) return r;
      }
      return reqs.first;
    }
    final resps = responsibilitiesList;
    if (resps.isNotEmpty) return resps.first;
    return 'Exciting opportunity at Idealake for $jobTitle in $department.';
  }

  static List<String> _parseHtmlToList(String? html) {
    if (html == null || html.trim().isEmpty) return [];
    final exp = RegExp(r'<p[^>]*>(.*?)</p>|<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true);
    final matches = exp.allMatches(html);
    List<String> items = [];
    for (final match in matches) {
      final content = match.group(1) ?? match.group(2);
      if (content != null) {
        final clean = _stripTags(content).trim();
        if (clean.isNotEmpty) items.add(clean);
      }
    }
    if (items.isEmpty) {
      final clean = _stripTags(html).trim();
      if (clean.isNotEmpty) items.add(clean);
    }
    return items;
  }

  static String _stripTags(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  List<Object?> get props => [
        id,
        jobTitle,
        department,
        jobLocation,
        jobExperience,
        jobPostedDate,
        workTypes,
        jobResponsibilities,
        jobRequirements,
      ];
}
