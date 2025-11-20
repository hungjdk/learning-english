// Business Logic Layer (Domain Layer)
// Chứa core business rules và không phụ thuộc vào external frameworks

class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserProfile? profile;
  final UserSettings settings;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.emailVerified,
    required this.createdAt,
    this.lastLoginAt,
    this.profile,
    required this.settings,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserProfile? profile,
    UserSettings? settings,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ==================== USER PROFILE ENTITY ====================

class UserProfile {
  final String? phoneNumber;
  final String? bio;
  final String? language;
  final String? learningAim; // pronunciation, communication, toeic, ielts, business, travel
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final List<String> completedLessons;
  final Map<String, int> achievements;

  const UserProfile({
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

  UserProfile copyWith({
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
    return UserProfile(
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

// ==================== USER SETTINGS ENTITY ====================

class UserSettings {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool darkModeEnabled;
  final String languagePreference;
  final int dailyGoal;
  final bool reminderEnabled;
  final DateTime? reminderTime;

  const UserSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.darkModeEnabled = false,
    this.languagePreference = 'en',
    this.dailyGoal = 20,
    this.reminderEnabled = false,
    this.reminderTime,
  });

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? darkModeEnabled,
    String? languagePreference,
    int? dailyGoal,
    bool? reminderEnabled,
    DateTime? reminderTime,
  }) {
    return UserSettings(
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
