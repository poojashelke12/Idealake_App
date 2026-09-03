import 'package:equatable/equatable.dart';
import '../../../core/constants/api_endpoints.dart';

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
    // 1. Id
    final id = json['Id']?.toString() ?? json['id']?.toString() ?? '';

    // 2. Library/Folder ID
    final libraryId = json['ParentId']?.toString() ??
        json['FolderId']?.toString() ??
        json['LibraryId']?.toString() ??
        json['libraryId']?.toString() ??
        'lib-001';

    // 3. Library Title
    final libraryTitle = json['LibraryTitle']?.toString() ??
        json['libraryTitle']?.toString() ??
        (json['Folder'] is Map ? json['Folder']['Title']?.toString() : null) ??
        'Documents';

    // 4. Title
    final title = json['Title']?.toString() ??
        json['title']?.toString() ??
        json['Name']?.toString() ??
        'Untitled Document';

    // 5. Description
    final description = json['Description']?.toString() ??
        json['description']?.toString() ??
        '';

    // 6. File Extension
    String ext = json['Extension']?.toString() ??
        json['fileExtension']?.toString() ??
        json['file_extension']?.toString() ??
        json['MimeType']?.toString() ??
        '';
    if (ext.startsWith('.')) {
      ext = ext.substring(1);
    }
    if (ext.isEmpty && title.contains('.')) {
      ext = title.split('.').last;
    }
    if (ext.isEmpty) {
      ext = 'pdf';
    }

    // 7. Category
    final category = json['Category']?.toString() ??
        json['category']?.toString() ??
        'General';

    // 8. File Size
    final rawSize = json['TotalSize'] ?? json['fileSize'] ?? json['file_size'];
    final fileSize = _formatFileSize(rawSize);

    // 9. Download / Media URL
    String? downloadUrl = json['Url']?.toString() ??
        json['downloadUrl']?.toString() ??
        json['download_url']?.toString() ??
        json['MediaUrl']?.toString();
    if (downloadUrl != null &&
        downloadUrl.isNotEmpty &&
        !downloadUrl.startsWith('http')) {
      if (downloadUrl.startsWith('/')) {
        downloadUrl = '${ApiEndpoints.baseUrl}$downloadUrl';
      } else {
        downloadUrl = '${ApiEndpoints.baseUrl}/$downloadUrl';
      }
    }

    // 10. Updated Date
    DateTime updatedDate = DateTime.now();
    final rawDate = json['LastModified'] ??
        json['PublicationDate'] ??
        json['DateCreated'] ??
        json['updatedDate'];
    if (rawDate != null) {
      updatedDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    }

    // 11. Author / Uploaded By
    final uploadedBy = json['Author']?.toString() ??
        json['UploadedBy']?.toString() ??
        json['uploadedBy']?.toString() ??
        json['Owner']?.toString() ??
        'Sitefinity Admin';

    // 12. Is Downloaded
    final isDownloaded = json['isDownloaded'] == true;

    return DocumentModel(
      id: id,
      libraryId: libraryId,
      libraryTitle: libraryTitle,
      title: title,
      description: description,
      fileExtension: ext.toLowerCase(),
      category: category,
      fileSize: fileSize,
      downloadUrl: downloadUrl,
      updatedDate: updatedDate,
      uploadedBy: uploadedBy,
      isDownloaded: isDownloaded,
    );
  }

  static String _formatFileSize(dynamic rawSize) {
    if (rawSize == null) return '1.5 MB';
    if (rawSize is num) {
      if (rawSize < 1024) return '$rawSize B';
      if (rawSize < 1024 * 1024) return '${(rawSize / 1024).toStringAsFixed(1)} KB';
      if (rawSize < 1024 * 1024 * 1024) {
        return '${(rawSize / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
      return '${(rawSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    final str = rawSize.toString().trim();
    final parsedNum = num.tryParse(str);
    if (parsedNum != null) {
      return _formatFileSize(parsedNum);
    }
    return str.isNotEmpty ? str : '1.5 MB';
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
