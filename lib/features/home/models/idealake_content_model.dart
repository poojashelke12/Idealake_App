import 'package:equatable/equatable.dart';

/// Response wrapper for Sitefinity /api/idealake/contents
class IdealakeContentsResponse extends Equatable {
  final String? odataContext;
  final List<IdealakeContentModel> value;

  const IdealakeContentsResponse({
    this.odataContext,
    required this.value,
  });

  factory IdealakeContentsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['value'] ?? json['data'] ?? []) as List;
    return IdealakeContentsResponse(
      odataContext: json['@odata.context']?.toString(),
      value: list
          .map((e) => IdealakeContentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (odataContext != null) '@odata.context': odataContext,
        'value': value.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [odataContext, value];
}

/// Model representing a Sitefinity CMS Content item matching /api/idealake/contents
class IdealakeContentModel extends Equatable {
  final String id;
  final DateTime? lastModified;
  final DateTime? publicationDate;
  final DateTime? dateCreated;
  final bool? includeInSitemap;
  final String urlName;
  final String? itemDefaultUrl;
  final String title;
  final String? parentId;
  final String? provider;
  final String? description;
  final String? summary;
  final String? author;
  final String? category;
  final String? contentHtml;
  final List<String> tags;

  const IdealakeContentModel({
    required this.id,
    this.lastModified,
    this.publicationDate,
    this.dateCreated,
    this.includeInSitemap,
    required this.urlName,
    this.itemDefaultUrl,
    required this.title,
    this.parentId,
    this.provider,
    this.description,
    this.summary,
    this.author,
    this.category,
    this.contentHtml,
    this.tags = const [],
  });

  factory IdealakeContentModel.fromJson(Map<String, dynamic> json) {
    return IdealakeContentModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      lastModified: json['LastModified'] != null
          ? DateTime.tryParse(json['LastModified'].toString())
          : (json['lastModified'] != null
              ? DateTime.tryParse(json['lastModified'].toString())
              : null),
      publicationDate: json['PublicationDate'] != null
          ? DateTime.tryParse(json['PublicationDate'].toString())
          : (json['publicationDate'] != null
              ? DateTime.tryParse(json['publicationDate'].toString())
              : null),
      dateCreated: json['DateCreated'] != null
          ? DateTime.tryParse(json['DateCreated'].toString())
          : (json['dateCreated'] != null
              ? DateTime.tryParse(json['dateCreated'].toString())
              : null),
      includeInSitemap: json['IncludeInSitemap'] ?? json['includeInSitemap'],
      urlName: json['UrlName'] ?? json['urlName'] ?? '',
      itemDefaultUrl: json['ItemDefaultUrl'] ?? json['itemDefaultUrl'],
      title: json['Title'] ?? json['title'] ?? '',
      parentId: json['ParentId']?.toString() ?? json['parentId']?.toString(),
      provider: json['Provider'] ?? json['provider'],
      description: json['Description'] ?? json['description'],
      summary: json['Summary'] ?? json['summary'] ?? json['Description'] ?? json['description'],
      author: json['Author'] ?? json['author'],
      category: json['Category'] ?? json['category'],
      contentHtml: json['Content'] ?? json['content'] ?? json['Body'] ?? json['body'],
      tags: (json['Tags'] is List
          ? (json['Tags'] as List).map((e) => e.toString()).toList()
          : (json['tags'] is List
              ? (json['tags'] as List).map((e) => e.toString()).toList()
              : const <String>[])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'LastModified': lastModified?.toIso8601String(),
      'PublicationDate': publicationDate?.toIso8601String(),
      'DateCreated': dateCreated?.toIso8601String(),
      'IncludeInSitemap': includeInSitemap,
      'UrlName': urlName,
      'ItemDefaultUrl': itemDefaultUrl,
      'Title': title,
      'ParentId': parentId,
      'Provider': provider,
      if (description != null) 'Description': description,
      if (summary != null) 'Summary': summary,
      if (author != null) 'Author': author,
    };
  }

  /// Formatted publication date helper (e.g. 21 Aug 2023)
  String get formattedDate {
    final date = publicationDate ?? dateCreated ?? lastModified;
    if (date == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  List<Object?> get props => [
        id,
        lastModified,
        publicationDate,
        dateCreated,
        includeInSitemap,
        urlName,
        itemDefaultUrl,
        title,
        parentId,
        provider,
        description,
        summary,
        author,
      ];
}
