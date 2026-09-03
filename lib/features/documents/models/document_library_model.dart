import 'package:equatable/equatable.dart';

/// Sitefinity Document Library (Folder/Collection) Model
class DocumentLibraryModel extends Equatable {
  final String id;
  final String title;
  final int documentCount;
  final String storedIn; // Database, Azure Blob, FileSystem
  final DateTime? lastUploadedDate;
  final String? lastUploadedBy;
  final String? description;

  const DocumentLibraryModel({
    required this.id,
    required this.title,
    this.documentCount = 0,
    this.storedIn = 'Database',
    this.lastUploadedDate,
    this.lastUploadedBy,
    this.description,
  });

  DocumentLibraryModel copyWith({
    String? id,
    String? title,
    int? documentCount,
    String? storedIn,
    DateTime? lastUploadedDate,
    String? lastUploadedBy,
    String? description,
  }) {
    return DocumentLibraryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      documentCount: documentCount ?? this.documentCount,
      storedIn: storedIn ?? this.storedIn,
      lastUploadedDate: lastUploadedDate ?? this.lastUploadedDate,
      lastUploadedBy: lastUploadedBy ?? this.lastUploadedBy,
      description: description ?? this.description,
    );
  }

  factory DocumentLibraryModel.fromJson(Map<String, dynamic> json) {
    return DocumentLibraryModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['Title'] ?? json['title'] ?? '',
      documentCount: json['DocumentCount'] ?? json['documentCount'] ?? json['ItemsCount'] ?? 0,
      storedIn: json['StoredIn'] ?? json['storedIn'] ?? 'Database',
      lastUploadedDate: json['LastUploadedDate'] != null
          ? DateTime.tryParse(json['LastUploadedDate'].toString())
          : (json['lastUploadedDate'] != null ? DateTime.tryParse(json['lastUploadedDate'].toString()) : null),
      lastUploadedBy: json['LastUploadedBy'] ?? json['lastUploadedBy'],
      description: json['Description'] ?? json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'documentCount': documentCount,
      'storedIn': storedIn,
      'lastUploadedDate': lastUploadedDate?.toIso8601String(),
      'lastUploadedBy': lastUploadedBy,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        documentCount,
        storedIn,
        lastUploadedDate,
        lastUploadedBy,
        description,
      ];
}
