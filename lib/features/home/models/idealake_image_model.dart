import 'package:equatable/equatable.dart';

/// Response wrapper for Sitefinity /api/idealake/images
class IdealakeImagesResponse extends Equatable {
  final List<IdealakeImageModel> value;

  const IdealakeImagesResponse({required this.value});

  factory IdealakeImagesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['value'] ?? json['data'] ?? []) as List;
    return IdealakeImagesResponse(
      value: list
          .map((e) => IdealakeImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [value];
}

/// Model representing a Sitefinity CMS Image asset matching /api/idealake/images
class IdealakeImageModel extends Equatable {
  final String id;
  final DateTime? lastModified;
  final DateTime? publicationDate;
  final String title;
  final String? description;
  final DateTime? dateCreated;
  final bool? includeInSitemap;
  final num? ordinal;
  final String urlName;
  final String? itemDefaultUrl;
  final String? author;
  final String? extension;
  final String? mimeType;
  final int? totalSize;
  final String? seoTitle;
  final String? seoDescription;
  final String? pageName;
  final String? seoKeywords;
  final double? width;
  final double? height;
  final String? alternativeText;
  final String? folderId;
  final String? parentId;
  final String? provider;
  final String url;
  final String? thumbnailUrl;

  const IdealakeImageModel({
    required this.id,
    this.lastModified,
    this.publicationDate,
    required this.title,
    this.description,
    this.dateCreated,
    this.includeInSitemap,
    this.ordinal,
    this.urlName = '',
    this.itemDefaultUrl,
    this.author,
    this.extension,
    this.mimeType,
    this.totalSize,
    this.seoTitle,
    this.seoDescription,
    this.pageName,
    this.seoKeywords,
    this.width,
    this.height,
    this.alternativeText,
    this.folderId,
    this.parentId,
    this.provider,
    required this.url,
    this.thumbnailUrl,
  });

  factory IdealakeImageModel.fromJson(Map<String, dynamic> json) {
    return IdealakeImageModel(
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
      title: json['Title'] ?? json['title'] ?? '',
      description: json['Description'] ?? json['description'] ?? '',
      dateCreated: json['DateCreated'] != null
          ? DateTime.tryParse(json['DateCreated'].toString())
          : (json['dateCreated'] != null
              ? DateTime.tryParse(json['dateCreated'].toString())
              : null),
      includeInSitemap: json['IncludeInSitemap'] ?? json['includeInSitemap'],
      ordinal: json['Ordinal'] ?? json['ordinal'],
      urlName: json['UrlName'] ?? json['urlName'] ?? '',
      itemDefaultUrl: json['ItemDefaultUrl'] ?? json['itemDefaultUrl'],
      author: json['Author'] ?? json['author'],
      extension: json['Extension'] ?? json['extension'],
      mimeType: json['MimeType'] ?? json['mimeType'],
      totalSize: json['TotalSize'] != null
          ? int.tryParse(json['TotalSize'].toString())
          : (json['totalSize'] != null
              ? int.tryParse(json['totalSize'].toString())
              : null),
      seoTitle: json['SEOTitle'] ?? json['seoTitle'],
      seoDescription: json['SEODescription'] ?? json['seoDescription'],
      pageName: json['PageName'] ?? json['pageName'],
      seoKeywords: json['SEOKeywords'] ?? json['seoKeywords'],
      width: json['Width'] != null
          ? double.tryParse(json['Width'].toString())
          : (json['width'] != null
              ? double.tryParse(json['width'].toString())
              : null),
      height: json['Height'] != null
          ? double.tryParse(json['Height'].toString())
          : (json['height'] != null
              ? double.tryParse(json['height'].toString())
              : null),
      alternativeText: json['AlternativeText'] ?? json['alternativeText'],
      folderId: json['FolderId']?.toString() ?? json['folderId']?.toString(),
      parentId: json['ParentId']?.toString() ?? json['parentId']?.toString(),
      provider: json['Provider'] ?? json['provider'],
      url: json['Url'] ?? json['url'] ?? json['MediaUrl'] ?? '',
      thumbnailUrl: json['ThumbnailUrl'] ?? json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'LastModified': lastModified?.toIso8601String(),
      'PublicationDate': publicationDate?.toIso8601String(),
      'Title': title,
      'Description': description,
      'DateCreated': dateCreated?.toIso8601String(),
      'IncludeInSitemap': includeInSitemap,
      'Ordinal': ordinal,
      'UrlName': urlName,
      'ItemDefaultUrl': itemDefaultUrl,
      'Author': author,
      'Extension': extension,
      'MimeType': mimeType,
      'TotalSize': totalSize,
      'SEOTitle': seoTitle,
      'SEODescription': seoDescription,
      'PageName': pageName,
      'SEOKeywords': seoKeywords,
      'Width': width,
      'Height': height,
      'AlternativeText': alternativeText,
      'FolderId': folderId,
      'ParentId': parentId,
      'Provider': provider,
      'Url': url,
      'ThumbnailUrl': thumbnailUrl,
    };
  }

  /// Calculates aspect ratio safely with fallback to 1920/726
  double get calculatedAspectRatio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    return 1920 / 726;
  }

  /// Checks if this image is the banner_1920 item
  bool get isBanner1920 {
    final lowerUrlName = urlName.toLowerCase();
    final lowerTitle = title.toLowerCase();
    return lowerUrlName == 'banner_1920' || lowerTitle == 'banner_1920';
  }

  @override
  List<Object?> get props => [
        id,
        lastModified,
        publicationDate,
        title,
        description,
        dateCreated,
        includeInSitemap,
        ordinal,
        urlName,
        itemDefaultUrl,
        author,
        extension,
        mimeType,
        totalSize,
        seoTitle,
        seoDescription,
        pageName,
        seoKeywords,
        width,
        height,
        alternativeText,
        folderId,
        parentId,
        provider,
        url,
        thumbnailUrl,
      ];
}
