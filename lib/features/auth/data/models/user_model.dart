import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user_entity.dart';

/// Data Transfer Object (DTO) - Data Layer
/// Chuyển đổi giữa Entity và External Data Sources (Firebase, API, Database)
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String role; // 'admin' or 'user'
  final UserProfileModel? profile;
  final UserSettingsModel settings;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.emailVerified,
    required this.createdAt,
    this.lastLoginAt,
    this.role = 'user',
    this.profile,
    required this.settings,
  });

  // ==================== FROM FIREBASE ====================

  /// Chuyển từ Firebase User sang UserModel
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'User',
      photoUrl: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
      profile: null, // Load từ Firestore
      settings: const UserSettingsModel(), // Default settings
    );
  }

  // ==================== FROM JSON (Firestore) ====================

  /// Chuyển từ Firestore Document sang UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'User',
      photoUrl: json['photoUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      lastLoginAt: _parseDateTime(json['lastLoginAt']),
      role: json['role'] as String? ?? 'user',
      profile: json['profile'] != null
          ? UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      settings: json['settings'] != null
          ? UserSettingsModel.fromJson(json['settings'] as Map<String, dynamic>)
          : const UserSettingsModel(),
    );
  }

  /// Chuyển UserModel sang JSON để lưu Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'role': role,
      'profile': profile?.toJson(),
      'settings': settings.toJson(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // ==================== TO/FROM ENTITY ====================

  /// Chuyển UserModel sang UserEntity (Domain Layer)
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      emailVerified: emailVerified,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      role: role,
      profile: profile?.toEntity(),
      settings: settings.toEntity(),
    );
  }

  /// Chuyển từ UserEntity sang UserModel
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      emailVerified: entity.emailVerified,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      role: entity.role,
      profile: entity.profile != null
          ? UserProfileModel.fromEntity(entity.profile!)
          : null,
      settings: UserSettingsModel.fromEntity(entity.settings),
    );
  }

  // ==================== HELPERS ====================

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    // Firestore Timestamp
    if (value is Map && value.containsKey('seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['seconds'] as int) * 1000,
      );
    }
    return DateTime.now();
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? role,
    UserProfileModel? profile,
    UserSettingsModel? settings,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      role: role ?? this.role,
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
    );
  }
}

// ==================== USER PROFILE MODEL ====================

class UserProfileModel {
  final String? phoneNumber;
  final String? bio;
  final String? language;
  final String? learningAim;
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final List<String> completedLessons;
  final Map<String, int> achievements;

  const UserProfileModel({
    this.phoneNumber,
    this.bio,
    this.language = 'en',
    this.learningAim,
    this.totalXP = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completedLessons = const [],
    this.achievements = const {},
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      language: json['language'] as String? ?? 'en',
      learningAim: json['learningAim'] as String?,
      totalXP: json['totalXP'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      completedLessons:
          (json['completedLessons'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      achievements:
          (json['achievements'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'bio': bio,
      'language': language,
      'learningAim': learningAim,
      'totalXP': totalXP,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completedLessons': completedLessons,
      'achievements': achievements,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      phoneNumber: phoneNumber,
      bio: bio,
      language: language,
      learningAim: learningAim,
      totalXP: totalXP,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      completedLessons: completedLessons,
      achievements: achievements,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      phoneNumber: entity.phoneNumber,
      bio: entity.bio,
      language: entity.language,
      learningAim: entity.learningAim,
      totalXP: entity.totalXP,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      completedLessons: entity.completedLessons,
      achievements: entity.achievements,
    );
  }

  UserProfileModel copyWith({
    String? phoneNumber,
    String? bio,
    String? language,
    String? learningAim,
    int? totalXP,
    int? currentStreak,
    int? longestStreak,
    List<String>? completedLessons,
    Map<String, int>? achievements,
  }) {
    return UserProfileModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      language: language ?? this.language,
      learningAim: learningAim ?? this.learningAim,
      totalXP: totalXP ?? this.totalXP,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedLessons: completedLessons ?? this.completedLessons,
      achievements: achievements ?? this.achievements,
    );
  }
}

// ==================== USER SETTINGS MODEL ====================

class UserSettingsModel {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool darkModeEnabled;
  final String languagePreference;
  final int dailyGoal;
  final bool reminderEnabled;
  final DateTime? reminderTime;

  const UserSettingsModel({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.darkModeEnabled = false,
    this.languagePreference = 'en',
    this.dailyGoal = 20,
    this.reminderEnabled = false,
    this.reminderTime,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      languagePreference: json['languagePreference'] as String? ?? 'en',
      dailyGoal: json['dailyGoal'] as int? ?? 20,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'darkModeEnabled': darkModeEnabled,
      'languagePreference': languagePreference,
      'dailyGoal': dailyGoal,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  UserSettings toEntity() {
    return UserSettings(
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      darkModeEnabled: darkModeEnabled,
      languagePreference: languagePreference,
      dailyGoal: dailyGoal,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
    );
  }

  factory UserSettingsModel.fromEntity(UserSettings entity) {
    return UserSettingsModel(
      notificationsEnabled: entity.notificationsEnabled,
      soundEnabled: entity.soundEnabled,
      darkModeEnabled: entity.darkModeEnabled,
      languagePreference: entity.languagePreference,
      dailyGoal: entity.dailyGoal,
      reminderEnabled: entity.reminderEnabled,
      reminderTime: entity.reminderTime,
    );
  }

  UserSettingsModel copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? darkModeEnabled,
    String? languagePreference,
    int? dailyGoal,
    bool? reminderEnabled,
    DateTime? reminderTime,
  }) {
    return UserSettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      languagePreference: languagePreference ?? this.languagePreference,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
