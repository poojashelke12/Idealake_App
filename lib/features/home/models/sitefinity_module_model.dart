import 'package:equatable/equatable.dart';

/// Model representing a dynamic layout module from Sitefinity /modules API
class SitefinityModuleModel extends Equatable {
  final String id;
  final String title;
  final String moduleType; // HeroBanner, ClientLogos, ServiceGrid, Awards, Stats
  final bool isEnabled;
  final int sortOrder;
  final Map<String, dynamic>? configuration;

  const SitefinityModuleModel({
    required this.id,
    required this.title,
    required this.moduleType,
    this.isEnabled = true,
    this.sortOrder = 0,
    this.configuration,
  });

  factory SitefinityModuleModel.fromJson(Map<String, dynamic> json) {
    return SitefinityModuleModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['Title'] ?? json['title'] ?? '',
      moduleType: json['ModuleType'] ?? json['moduleType'] ?? json['Type'] ?? 'General',
      isEnabled: json['IsEnabled'] ?? json['isEnabled'] ?? true,
      sortOrder: json['SortOrder'] ?? json['sortOrder'] ?? 0,
      configuration: json['Configuration'] ?? json['configuration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'moduleType': moduleType,
      'isEnabled': isEnabled,
      'sortOrder': sortOrder,
      'configuration': configuration,
    };
  }

  @override
  List<Object?> get props => [id, title, moduleType, isEnabled, sortOrder, configuration];
}
