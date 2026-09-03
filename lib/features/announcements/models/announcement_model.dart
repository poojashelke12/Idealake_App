import 'package:equatable/equatable.dart';

/// Sitefinity Announcement Content Model
class AnnouncementModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime effectiveDate;
  final DateTime? expiryDate;
  final String audience;
  final String? attachmentUrl;
  final String? attachmentName;
  final String priority; // Normal, High, Urgent
  final bool isRead;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.effectiveDate,
    this.expiryDate,
    this.audience = 'All Employees',
    this.attachmentUrl,
    this.attachmentName,
    this.priority = 'Normal',
    this.isRead = false,
  });

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? effectiveDate,
    DateTime? expiryDate,
    String? audience,
    String? attachmentUrl,
    String? attachmentName,
    String? priority,
    bool? isRead,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      expiryDate: expiryDate ?? this.expiryDate,
      audience: audience ?? this.audience,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
    );
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['Title'] ?? json['title'] ?? '',
      body: json['Body'] ?? json['body'] ?? '',
      effectiveDate: json['EffectiveDate'] != null
          ? DateTime.tryParse(json['EffectiveDate'].toString()) ?? DateTime.now()
          : (json['effectiveDate'] != null
              ? DateTime.tryParse(json['effectiveDate'].toString()) ?? DateTime.now()
              : DateTime.now()),
      expiryDate: json['ExpiryDate'] != null
          ? DateTime.tryParse(json['ExpiryDate'].toString())
          : (json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'].toString()) : null),
      audience: json['Audience'] ?? json['audience'] ?? 'All Employees',
      attachmentUrl: json['AttachmentUrl'] ?? json['attachmentUrl'],
      attachmentName: json['AttachmentName'] ?? json['attachmentName'],
      priority: json['Priority'] ?? json['priority'] ?? 'Normal',
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'effectiveDate': effectiveDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'audience': audience,
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
      'priority': priority,
      'isRead': isRead,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        effectiveDate,
        expiryDate,
        audience,
        attachmentUrl,
        attachmentName,
        priority,
        isRead,
      ];
}
