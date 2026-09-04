import 'package:equatable/equatable.dart';

/// User Profile Model for authenticated Sitefinity sessions
class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final String? department;
  final String? token;
  final DateTime? lastLoginTime;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.role = 'Employee',
    this.department = 'IT & Digital',
    this.token,
    this.lastLoginTime,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['FullName'] ?? json['fullName'] ?? json['name'] ?? json['UserName'] ?? 'User',
      email: json['Email'] ?? json['email'] ?? '',
      phone: json['Phone'] ?? json['phone'] ?? '',
      role: json['Role'] ?? json['role'] ?? 'User',
      department: json['Department'] ?? json['department'] ?? 'Digital Solutions',
      token: json['access_token'] ?? json['token'] ?? json['accessToken'],
      lastLoginTime: json['lastLoginTime'] != null
          ? DateTime.tryParse(json['lastLoginTime'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'department': department,
      'token': token,
      'lastLoginTime': lastLoginTime?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        role,
        department,
        token,
        lastLoginTime,
      ];
}
