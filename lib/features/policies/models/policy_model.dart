import 'package:equatable/equatable.dart';

/// Sitefinity Organizational Policy Model
class PolicyModel extends Equatable {
  final String id;
  final String title;
  final String category;
  final String version;
  final DateTime effectiveDate;
  final String summary;
  final String? documentUrl;
  final String fileSize;
  final List<String> previousVersions;
  final bool isMandatory;

  const PolicyModel({
    required this.id,
    required this.title,
    required this.category,
    required this.version,
    required this.effectiveDate,
    required this.summary,
    this.documentUrl,
    this.fileSize = '1.2 MB',
    this.previousVersions = const [],
    this.isMandatory = true,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    List<String> prevVersions = [];
    if (json['PreviousVersions'] is List) {
      prevVersions = (json['PreviousVersions'] as List).map((e) => e.toString()).toList();
    } else if (json['previousVersions'] is List) {
      prevVersions = (json['previousVersions'] as List).map((e) => e.toString()).toList();
    }

    return PolicyModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['Title'] ?? json['title'] ?? '',
      category: json['Category'] ?? json['category'] ?? 'General',
      version: json['Version'] ?? json['version'] ?? 'v1.0',
      effectiveDate: json['EffectiveDate'] != null
          ? DateTime.tryParse(json['EffectiveDate'].toString()) ?? DateTime.now()
          : (json['effectiveDate'] != null
              ? DateTime.tryParse(json['effectiveDate'].toString()) ?? DateTime.now()
              : DateTime.now()),
      summary: json['Summary'] ?? json['summary'] ?? '',
      documentUrl: json['DocumentUrl'] ?? json['documentUrl'] ?? json['fileUrl'],
      fileSize: json['FileSize'] ?? json['fileSize'] ?? '1.2 MB',
      previousVersions: prevVersions,
      isMandatory: json['IsMandatory'] ?? json['isMandatory'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'version': version,
      'effectiveDate': effectiveDate.toIso8601String(),
      'summary': summary,
      'documentUrl': documentUrl,
      'fileSize': fileSize,
      'previousVersions': previousVersions,
      'isMandatory': isMandatory,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        version,
        effectiveDate,
        summary,
        documentUrl,
        fileSize,
        previousVersions,
        isMandatory,
      ];
}
