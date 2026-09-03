import 'package:equatable/equatable.dart';

/// Banner Model representing promotional/informative slides on Home
class BannerModel extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? actionUrl;
  final String? buttonText;
  final String? urlName;

  const BannerModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.imageUrl,
    this.actionUrl,
    this.buttonText,
    this.urlName,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['Title'] ?? json['title'] ?? '',
      subtitle: json['Description'] ?? json['subtitle'] ?? '',
      imageUrl: json['Url'] ?? json['imageUrl'] ?? json['image_url'] ?? json['MediaUrl'],
      actionUrl: json['ItemDefaultUrl'] ?? json['actionUrl'] ?? json['action_url'],
      buttonText: json['buttonText'] ?? json['button_text'],
      urlName: json['UrlName'] ?? json['urlName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'buttonText': buttonText,
      'urlName': urlName,
    };
  }

  @override
  List<Object?> get props => [id, title, subtitle, imageUrl, actionUrl, buttonText, urlName];
}
