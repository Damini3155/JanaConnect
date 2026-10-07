import 'package:geo_tag_camera/core/constants/app_constants.dart';

/// User model representing Citizen, Admin, or Worker.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String role; // 'citizen', 'admin', 'worker'
  final String? profileImage;
  final DateTime createdAt;
  final bool isActive;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.isActive = true,
  });

  /// Helper getters for role checks
  bool get isCitizen => role == UserRole.citizen;
  bool get isAdmin => role == UserRole.admin;
  bool get isWorker => role == UserRole.worker;

  /// Map representation for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Create UserModel from Firestore map
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      name: map['name'] as String? ?? 'Unknown',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? UserRole.citizen,
      profileImage: map['profileImage'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  /// Copy with pattern for updating user fields
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
