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
      id: json['Id']?.toString() ?? json['id']?.toString() ?? 'usr-101',
      fullName: json['FullName'] ?? json['fullName'] ?? json['name'] ?? json['UserName'] ?? 'Rakesh Sunar',
      email: json['Email'] ?? json['email'] ?? 'rakesh.sunar@idealake.com',
      phone: json['Phone'] ?? json['phone'] ?? '+91 98765 43210',
      role: json['Role'] ?? json['role'] ?? 'Technical Lead / CMS Admin',
      department: json['Department'] ?? json['department'] ?? 'Digital Solutions - LTFS',
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
