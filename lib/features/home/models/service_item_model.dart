import 'package:equatable/equatable.dart';

/// Service/Solution Item Model representing offerings in the app
class ServiceItemModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? iconName;
  final String? category;
  final String? route;

  const ServiceItemModel({
    required this.id,
    required this.title,
    required this.description,
    this.iconName,
    this.category,
    this.route,
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconName: json['iconName'] ?? json['icon_name'],
      category: json['category'],
      route: json['route'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'category': category,
      'route': route,
    };
  }

  @override
  List<Object?> get props => [id, title, description, iconName, category, route];
}
