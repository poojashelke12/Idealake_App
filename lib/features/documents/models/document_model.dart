import 'package:equatable/equatable.dart';

/// Sitefinity Media Library Document Model
class DocumentModel extends Equatable {
  final String id;
  final String libraryId;
  final String libraryTitle;
  final String title;
  final String description;
  final String fileExtension; // pdf, docx, xlsx, pptx
  final String category;
  final String fileSize;
  final String? downloadUrl;
  final DateTime updatedDate;
  final String uploadedBy;
  final bool isDownloaded;

  const DocumentModel({
    required this.id,
    required this.libraryId,
    required this.libraryTitle,
    required this.title,
    required this.description,
    required this.fileExtension,
    required this.category,
    required this.fileSize,
    this.downloadUrl,
    required this.updatedDate,
    this.uploadedBy = 'Sitefinity Admin',
    this.isDownloaded = false,
  });

  DocumentModel copyWith({
    String? id,
    String? libraryId,
    String? libraryTitle,
    String? title,
    String? description,
    String? fileExtension,
    String? category,
    String? fileSize,
    String? downloadUrl,
    DateTime? updatedDate,
    String? uploadedBy,
    bool? isDownloaded,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      libraryId: libraryId ?? this.libraryId,
      libraryTitle: libraryTitle ?? this.libraryTitle,
      title: title ?? this.title,
      description: description ?? this.description,
      fileExtension: fileExtension ?? this.fileExtension,
      category: category ?? this.category,
      fileSize: fileSize ?? this.fileSize,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      updatedDate: updatedDate ?? this.updatedDate,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      libraryId: json['LibraryId']?.toString() ?? json['libraryId']?.toString() ?? 'lib-001',
      libraryTitle: json['LibraryTitle'] ?? json['libraryTitle'] ?? 'Documents',
      title: json['Title'] ?? json['title'] ?? '',
      description: json['Description'] ?? json['description'] ?? '',
      fileExtension: json['Extension'] ?? json['fileExtension'] ?? json['file_extension'] ?? 'pdf',
      category: json['Category'] ?? json['category'] ?? 'General',
      fileSize: json['TotalSize'] ?? json['fileSize'] ?? json['file_size'] ?? '1.5 MB',
      downloadUrl: json['Url'] ?? json['downloadUrl'] ?? json['download_url'],
      updatedDate: json['LastModified'] != null
          ? DateTime.tryParse(json['LastModified'].toString()) ?? DateTime.now()
          : (json['updatedDate'] != null
              ? DateTime.tryParse(json['updatedDate'].toString()) ?? DateTime.now()
              : DateTime.now()),
      uploadedBy: json['UploadedBy'] ?? json['uploadedBy'] ?? 'Sitefinity Admin',
      isDownloaded: json['isDownloaded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libraryId': libraryId,
      'libraryTitle': libraryTitle,
      'title': title,
      'description': description,
      'fileExtension': fileExtension,
      'category': category,
      'fileSize': fileSize,
      'downloadUrl': downloadUrl,
      'updatedDate': updatedDate.toIso8601String(),
      'uploadedBy': uploadedBy,
      'isDownloaded': isDownloaded,
    };
  }

  @override
  List<Object?> get props => [
        id,
        libraryId,
        libraryTitle,
        title,
        description,
        fileExtension,
        category,
        fileSize,
        downloadUrl,
        updatedDate,
        uploadedBy,
        isDownloaded,
      ];
}
