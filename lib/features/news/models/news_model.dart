import 'package:equatable/equatable.dart';
import '../../../core/utils/date_formatter.dart';

/// Sitefinity News Item Model matching Sitefinity Headless CMS newsitems API
class NewsModel extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String contentHtml;
  final String? heroImageUrl;
  final DateTime publishedDate;
  final DateTime? lastModified;
  final DateTime? dateCreated;
  final String author;
  final String? sourceName;
  final String? sourceUrl;
  final String? urlName;
  final String? itemDefaultUrl;
  final bool allowComments;
  final bool includeInSitemap;
  final String? provider;
  final String status; // 'Published' or 'Draft'
  final List<String> tags;
  final String category;

  const NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.contentHtml,
    this.heroImageUrl,
    required this.publishedDate,
    this.lastModified,
    this.dateCreated,
    this.author = 'Pooja Shelke',
    this.sourceName,
    this.sourceUrl,
    this.urlName,
    this.itemDefaultUrl,
    this.allowComments = true,
    this.includeInSitemap = true,
    this.provider = 'OpenAccessDataProvider',
    this.status = 'Published',
    this.tags = const [],
    this.category = 'General',
  });

  /// Formatted date string matching screenshot (e.g. "Today by Pooja Shelke", "Yesterday by Pooja Shelke")
  String get formattedAuthorAndDate {
    final authorName = author.trim().isNotEmpty ? author.trim() : 'Pooja Shelke';
    final now = DateTime.now();
    final date = lastModified ?? publishedDate;
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;

    if (isToday) {
      return 'Today by $authorName';
    } else if (isYesterday) {
      return 'Yesterday by $authorName';
    } else {
      return '${AppFormatter.formatDate(date)} by $authorName';
    }
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? summary,
    String? contentHtml,
    String? heroImageUrl,
    DateTime? publishedDate,
    DateTime? lastModified,
    DateTime? dateCreated,
    String? author,
    String? sourceName,
    String? sourceUrl,
    String? urlName,
    String? itemDefaultUrl,
    bool? allowComments,
    bool? includeInSitemap,
    String? provider,
    String? status,
    List<String>? tags,
    String? category,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      contentHtml: contentHtml ?? this.contentHtml,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      lastModified: lastModified ?? this.lastModified,
      dateCreated: dateCreated ?? this.dateCreated,
      author: author ?? this.author,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      urlName: urlName ?? this.urlName,
      itemDefaultUrl: itemDefaultUrl ?? this.itemDefaultUrl,
      allowComments: allowComments ?? this.allowComments,
      includeInSitemap: includeInSitemap ?? this.includeInSitemap,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      category: category ?? this.category,
    );
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['Tags'] is List) {
      parsedTags = (json['Tags'] as List).map((e) => e.toString()).toList();
    } else if (json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((e) => e.toString()).toList();
    }

    final rawAuthor = json['Author']?.toString().trim() ?? json['author']?.toString().trim() ?? '';
    final authorName = rawAuthor.isNotEmpty ? rawAuthor : 'Pooja Shelke';

    return NewsModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['Title'] ?? json['title'] ?? '',
      summary: json['Summary'] ?? json['summary'] ?? json['Description'] ?? '',
      contentHtml: json['Content'] ?? json['content'] ?? json['body'] ?? '',
      heroImageUrl: json['HeroImageUrl'] ?? json['heroImageUrl'] ?? json['imageUrl'],
      publishedDate: json['PublicationDate'] != null
          ? DateTime.tryParse(json['PublicationDate'].toString()) ?? DateTime.now()
          : (json['publishedDate'] != null
              ? DateTime.tryParse(json['publishedDate'].toString()) ?? DateTime.now()
              : DateTime.now()),
      lastModified: json['LastModified'] != null
          ? DateTime.tryParse(json['LastModified'].toString())
          : (json['lastModified'] != null ? DateTime.tryParse(json['lastModified'].toString()) : null),
      dateCreated: json['DateCreated'] != null
          ? DateTime.tryParse(json['DateCreated'].toString())
          : (json['dateCreated'] != null ? DateTime.tryParse(json['dateCreated'].toString()) : null),
      author: authorName,
      sourceName: json['SourceName']?.toString() ?? json['sourceName']?.toString(),
      sourceUrl: json['SourceSite']?.toString() ?? json['sourceUrl']?.toString() ?? json['SourceUrl']?.toString(),
      urlName: json['UrlName']?.toString() ?? json['urlName']?.toString(),
      itemDefaultUrl: json['ItemDefaultUrl']?.toString() ?? json['itemDefaultUrl']?.toString(),
      allowComments: json['AllowComments'] == true || json['allowComments'] == true,
      includeInSitemap: json['IncludeInSitemap'] != false,
      provider: json['Provider']?.toString() ?? json['provider']?.toString() ?? 'OpenAccessDataProvider',
      status: json['Status']?.toString() ?? json['status']?.toString() ?? 'Published',
      tags: parsedTags,
      category: json['Category'] ?? json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Title': title,
      'Summary': summary,
      'Content': contentHtml,
      'HeroImageUrl': heroImageUrl,
      'PublicationDate': publishedDate.toIso8601String(),
      'LastModified': lastModified?.toIso8601String() ?? publishedDate.toIso8601String(),
      'DateCreated': dateCreated?.toIso8601String() ?? publishedDate.toIso8601String(),
      'Author': author,
      'SourceName': sourceName,
      'SourceSite': sourceUrl,
      'UrlName': urlName ?? title.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
      'ItemDefaultUrl': itemDefaultUrl,
      'AllowComments': allowComments,
      'IncludeInSitemap': includeInSitemap,
      'Provider': provider,
      'Status': status,
      'Tags': tags,
      'Category': category,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        summary,
        contentHtml,
        heroImageUrl,
        publishedDate,
        lastModified,
        dateCreated,
        author,
        sourceName,
        sourceUrl,
        urlName,
        itemDefaultUrl,
        allowComments,
        includeInSitemap,
        provider,
        status,
        tags,
        category,
      ];
}
