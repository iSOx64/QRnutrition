import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    required this.role,
    required this.authProviders,
    required this.emailVerified,
    required this.dailyCalorieGoal,
    required this.isProfileComplete,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final String role; // 'user', 'admin', 'super_admin'
  final List<String> authProviders;
  final bool emailVerified;
  final int dailyCalorieGoal;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLoginAt;

  static const String defaultRoleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';

  bool get isAdmin => role == roleAdmin || role == roleSuperAdmin;
  bool get isSuperAdmin => role == roleSuperAdmin;

  bool hasRole(String roleToCheck) => role == roleToCheck;

  factory AppUser.initial(String uid, String email,
      {String? fullName, String? photoUrl, String provider = 'password'}) {
    final now = DateTime.now();
    return AppUser(
      uid: uid,
      fullName: fullName ?? '',
      email: email,
      photoUrl: photoUrl,
      role: defaultRoleUser,
      authProviders: [provider],
      emailVerified: false,
      dailyCalorieGoal: 2000,
      isProfileComplete: true,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: now,
    );
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    String? photoUrl,
    String? role,
    List<String>? authProviders,
    bool? emailVerified,
    int? dailyCalorieGoal,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return AppUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      authProviders: authProviders ?? this.authProviders,
      emailVerified: emailVerified ?? this.emailVerified,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'authProviders': authProviders,
      'emailVerified': emailVerified,
      'dailyCalorieGoal': dailyCalorieGoal,
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final createdAtTs = map['createdAt'] as Timestamp?;
    final updatedAtTs = map['updatedAt'] as Timestamp?;
    final lastLoginAtTs = map['lastLoginAt'] as Timestamp?;

    return AppUser(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      role: map['role'] as String? ?? defaultRoleUser,
      authProviders: List<String>.from(map['authProviders'] ?? const <String>[]),
      emailVerified: map['emailVerified'] as bool? ?? false,
      dailyCalorieGoal: (map['dailyCalorieGoal'] as num?)?.toInt() ?? 2000,
      isProfileComplete: map['isProfileComplete'] as bool? ?? true,
      createdAt: createdAtTs?.toDate() ?? DateTime.now(),
      updatedAt: updatedAtTs?.toDate() ?? DateTime.now(),
      lastLoginAt: lastLoginAtTs?.toDate() ?? DateTime.now(),
    );
  }
}


