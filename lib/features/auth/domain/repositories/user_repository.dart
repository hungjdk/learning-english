import '../entities/user_entity.dart';

/// Repository Interface cho User Data (Firestore)
/// Define các method cần implement ở Data Layer
abstract class UserRepository {
  /// Get user data from Firestore
  Future<UserEntity?> getUserData(String userId);

  /// Create or update user data in Firestore
  Future<void> saveUserData(UserEntity user);

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? bio,
    String? photoUrl,
    String? learningAim,
  });

  /// Update user settings
  Future<void> updateUserSettings({
    required String userId,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? darkModeEnabled,
    String? languagePreference,
    int? dailyGoal,
    bool? reminderEnabled,
    DateTime? reminderTime,
  });

  /// Delete user data from Firestore
  Future<void> deleteUserData(String userId);

  /// Stream user data changes
  Stream<UserEntity?> watchUserData(String userId);
}
