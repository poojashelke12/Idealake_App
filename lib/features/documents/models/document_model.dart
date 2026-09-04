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
  final String? url;
  final DateTime updatedDate;
  final String uploadedBy;
  final bool isDownloaded;

  String get previewUrl {
    String target = (downloadUrl != null && downloadUrl!.trim().isNotEmpty)
        ? downloadUrl!.trim()
        : (url != null && url!.trim().isNotEmpty ? url!.trim() : '');

    if (target.isEmpty) return '';

    // If query string exists in downloadUrl but not in target, append it
    if (!target.contains('?')) {
      final querySource = (downloadUrl?.contains('?') ?? false)
          ? downloadUrl!
          : ((url?.contains('?') ?? false) ? url! : '');
      if (querySource.isNotEmpty && querySource.contains('?')) {
        target = '$target${querySource.substring(querySource.indexOf('?'))}';
      }
    }

    // Ensure full scheme and host
    if (!target.startsWith('http://') && !target.startsWith('https://')) {
      if (!target.startsWith('/')) {
        target = '/$target';
      }
      target = '${ApiEndpoints.baseUrl}$target';
    }

    return target;
  }

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
    this.url,
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
    String? url,
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
      url: url ?? this.url,
      updatedDate: updatedDate ?? this.updatedDate,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  factory DocumentModel.fromJson(
    Map<String, dynamic> json, {
    String defaultLibraryTitle = 'ResumeDocument',
    String defaultLibraryId = 'lib-001',
  }) {
    // 1. Id
    final id = json['Id']?.toString() ?? json['id']?.toString() ?? '';

    // 2. Library/Folder ID
    final libraryId = json['ParentId']?.toString() ??
        json['FolderId']?.toString() ??
        json['LibraryId']?.toString() ??
        json['libraryId']?.toString() ??
        defaultLibraryId;

    // 3. Library Title
    final libraryTitle = json['LibraryTitle']?.toString() ??
        json['libraryTitle']?.toString() ??
        (json['Folder'] is Map ? json['Folder']['Title']?.toString() : null) ??
        defaultLibraryTitle;

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

    // 9. Download / Media URL (resolving full absolute URL with query parameters)
    final mediaUrl = json['MediaUrl']?.toString() ?? json['mediaUrl']?.toString();
    final apiUrl = json['Url']?.toString() ?? json['url']?.toString();
    final sfvrsn = json['sfvrsn']?.toString() ?? json['Sfvrsn']?.toString();

    String candidateUrl = '';
    // Prefer MediaUrl if it contains query parameters (e.g. ?sfvrsn=...&download=true)
    if (mediaUrl != null && mediaUrl.contains('?')) {
      candidateUrl = mediaUrl;
    } else if (apiUrl != null && apiUrl.contains('?')) {
      candidateUrl = apiUrl;
    } else if (mediaUrl != null && mediaUrl.isNotEmpty) {
      candidateUrl = mediaUrl;
    } else if (apiUrl != null && apiUrl.isNotEmpty) {
      candidateUrl = apiUrl;
    } else {
      candidateUrl = json['downloadUrl']?.toString() ?? json['download_url']?.toString() ?? '';
    }

    // If query string is missing from candidateUrl but available in mediaUrl or sfvrsn, append it
    if (candidateUrl.isNotEmpty && !candidateUrl.contains('?')) {
      if (mediaUrl != null && mediaUrl.contains('?')) {
        candidateUrl = '$candidateUrl${mediaUrl.substring(mediaUrl.indexOf('?'))}';
      } else if (sfvrsn != null && sfvrsn.isNotEmpty) {
        candidateUrl = '$candidateUrl?sfvrsn=$sfvrsn&download=true';
      }
    }

    // Ensure candidateUrl is an absolute URL with baseUrl
    if (candidateUrl.isNotEmpty &&
        !candidateUrl.startsWith('http://') &&
        !candidateUrl.startsWith('https://')) {
      if (!candidateUrl.startsWith('/')) {
        candidateUrl = '/$candidateUrl';
      }
      candidateUrl = '${ApiEndpoints.baseUrl}$candidateUrl';
    }

    final downloadUrl = candidateUrl.isNotEmpty ? candidateUrl : null;

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

    // 13. API URL (from keyword "Url", formatted with full scheme, host, and query params)
    String? rawUrl = apiUrl;
    if (rawUrl != null && rawUrl.isNotEmpty) {
      if (!rawUrl.contains('?') && candidateUrl.contains('?')) {
        rawUrl = '$rawUrl${candidateUrl.substring(candidateUrl.indexOf('?'))}';
      }
      if (!rawUrl.startsWith('http://') && !rawUrl.startsWith('https://')) {
        if (!rawUrl.startsWith('/')) {
          rawUrl = '/$rawUrl';
        }
        rawUrl = '${ApiEndpoints.baseUrl}$rawUrl';
      }
    } else {
      rawUrl = downloadUrl;
    }

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
      url: rawUrl,
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
      'url': url,
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
        url,
        updatedDate,
        uploadedBy,
        isDownloaded,
      ];
}
