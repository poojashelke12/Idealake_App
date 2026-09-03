import 'package:equatable/equatable.dart';

/// Sitefinity News Item Model
class NewsModel extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String contentHtml;
  final String? heroImageUrl;
  final DateTime publishedDate;
  final String author;
  final List<String> tags;
  final String category;

  const NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.contentHtml,
    this.heroImageUrl,
    required this.publishedDate,
    this.author = 'Idealake Editorial',
    this.tags = const [],
    this.category = 'General',
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['Tags'] is List) {
      parsedTags = (json['Tags'] as List).map((e) => e.toString()).toList();
    } else if (json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((e) => e.toString()).toList();
    }

    return NewsModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['Title'] ?? json['title'] ?? '',
      summary: json['Summary'] ?? json['summary'] ?? '',
      contentHtml: json['Content'] ?? json['content'] ?? json['body'] ?? '',
      heroImageUrl: json['HeroImageUrl'] ?? json['heroImageUrl'] ?? json['imageUrl'],
      publishedDate: json['PublicationDate'] != null
          ? DateTime.tryParse(json['PublicationDate'].toString()) ?? DateTime.now()
          : (json['publishedDate'] != null
              ? DateTime.tryParse(json['publishedDate'].toString()) ?? DateTime.now()
              : DateTime.now()),
      author: json['Author'] ?? json['author'] ?? 'Idealake Editorial',
      tags: parsedTags,
      category: json['Category'] ?? json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': contentHtml,
      'heroImageUrl': heroImageUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'author': author,
      'tags': tags,
      'category': category,
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
        author,
        tags,
        category,
      ];
}
