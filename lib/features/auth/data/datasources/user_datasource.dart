import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// User Datasource - Direct interaction with Firestore
class UserDatasource {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  UserDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== GET USER DATA ====================

  /// Get user data from Firestore
  Future<UserEntity?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) {
        return null;
      }

      return UserModel.fromJson(data).toEntity();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // ==================== SAVE USER DATA ====================

  /// Create or update user data in Firestore
  Future<void> saveUserData(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(userModel.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  // ==================== UPDATE USER PROFILE ====================

  /// Update user profile fields
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? bio,
    String? photoUrl,
    String? learningAim,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (displayName != null) {
        updates['displayName'] = displayName;
      }
      if (phoneNumber != null) {
        updates['profile.phoneNumber'] = phoneNumber;
      }
      if (bio != null) {
        updates['profile.bio'] = bio;
      }
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }
      if (learningAim != null) {
        updates['profile.learningAim'] = learningAim;
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        // Use set with merge to create document if it doesn't exist
        await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .set(updates, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // ==================== UPDATE USER SETTINGS ====================

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
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (notificationsEnabled != null) {
        updates['settings.notificationsEnabled'] = notificationsEnabled;
      }
      if (soundEnabled != null) {
        updates['settings.soundEnabled'] = soundEnabled;
      }
      if (darkModeEnabled != null) {
        updates['settings.darkModeEnabled'] = darkModeEnabled;
      }
      if (languagePreference != null) {
        updates['settings.languagePreference'] = languagePreference;
      }
      if (dailyGoal != null) {
        updates['settings.dailyGoal'] = dailyGoal;
      }
      if (reminderEnabled != null) {
        updates['settings.reminderEnabled'] = reminderEnabled;
      }
      if (reminderTime != null) {
        updates['settings.reminderTime'] = reminderTime.toIso8601String();
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        // Use set with merge to create document if it doesn't exist
        await _firestore
            .collection(_usersCollection)
            .doc(userId)
            .set(updates, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to update user settings: $e');
    }
  }

  // ==================== DELETE USER DATA ====================

  /// Delete user data from Firestore
  Future<void> deleteUserData(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  // ==================== WATCH USER DATA ====================

  /// Stream user data changes
  Stream<UserEntity?> watchUserData(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();
      if (data == null) {
        return null;
      }

      return UserModel.fromJson(data).toEntity();
    });
  }
}
