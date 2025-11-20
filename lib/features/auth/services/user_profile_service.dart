import 'package:flutter/foundation.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/user_repository.dart';

/// User Profile Service
/// Handles user profile and settings updates
/// Use this service in your UI layer with Provider
class UserProfileService extends ChangeNotifier {
  final UserRepository _userRepository;

  UserProfileService({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  // ==================== STATE MANAGEMENT ====================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // ==================== PRIVATE HELPERS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ==================== UPDATE PROFILE ====================

  /// Update user profile
  Future<bool> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? bio,
    String? photoUrl,
    String? learningAim,
  }) async {
    try {
      _setLoading(true);
      clearMessages();

      await _userRepository.updateUserProfile(
        userId: userId,
        displayName: displayName,
        phoneNumber: phoneNumber,
        bio: bio,
        photoUrl: photoUrl,
        learningAim: learningAim,
      );

      _setLoading(false);
      _setSuccess('Cập nhật profile thành công');
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Cập nhật profile thất bại: ${e.toString()}');
      return false;
    }
  }

  // ==================== UPDATE SETTINGS ====================

  /// Update user settings
  Future<bool> updateSettings({
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
      _setLoading(true);
      clearMessages();

      await _userRepository.updateUserSettings(
        userId: userId,
        notificationsEnabled: notificationsEnabled,
        soundEnabled: soundEnabled,
        darkModeEnabled: darkModeEnabled,
        languagePreference: languagePreference,
        dailyGoal: dailyGoal,
        reminderEnabled: reminderEnabled,
        reminderTime: reminderTime,
      );

      _setLoading(false);
      _setSuccess('Cập nhật cài đặt thành công');
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Cập nhật cài đặt thất bại: ${e.toString()}');
      return false;
    }
  }

  // ==================== GET USER DATA ====================

  /// Get user data
  Future<UserEntity?> getUserData(String userId) async {
    try {
      _setLoading(true);
      clearMessages();

      final userData = await _userRepository.getUserData(userId);

      _setLoading(false);
      return userData;
    } catch (e) {
      _setLoading(false);
      _setError('Lấy dữ liệu user thất bại: ${e.toString()}');
      return null;
    }
  }

  // ==================== SAVE USER DATA ====================

  /// Save complete user data
  Future<bool> saveUserData(UserEntity user) async {
    try {
      _setLoading(true);
      clearMessages();

      await _userRepository.saveUserData(user);

      _setLoading(false);
      _setSuccess('Lưu dữ liệu thành công');
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Lưu dữ liệu thất bại: ${e.toString()}');
      return false;
    }
  }

  // ==================== WATCH USER DATA ====================

  /// Stream user data changes
  Stream<UserEntity?> watchUserData(String userId) {
    return _userRepository.watchUserData(userId);
  }
}
