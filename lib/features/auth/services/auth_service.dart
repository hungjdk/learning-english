import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/user_repository.dart';

/// Comprehensive Auth Service
/// Combines Authentication and User Data Management
/// Use this service in your UI layer with Provider
class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthService({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  // ==================== STATE MANAGEMENT ====================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserEntity? _currentUserData;
  UserEntity? get currentUserData => _currentUserData;

  // ==================== GETTERS ====================

  firebase_auth.User? get currentUser => _authRepository.currentUser;

  Stream<firebase_auth.User?> get authStateChanges =>
      _authRepository.authStateChanges;

  // ==================== PRIVATE HELPERS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== SIGN UP ====================

  /// Sign up with email and password
  /// Also creates user data in Firestore
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Sign up with Firebase Auth
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user == null) {
        _setError('Failed to create account');
        _setLoading(false);
        return null;
      }

      // Save user data to Firestore
      try {
        await _userRepository.saveUserData(user);
        _currentUserData = user;
      } catch (e) {
        debugPrint('Warning: Could not save user data to Firestore: $e');
        // Continue anyway, data can be synced later
      }

      _setLoading(false);
      return user;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  // ==================== SIGN IN ====================

  /// Sign in with email and password
  /// Also loads user data from Firestore
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Sign in with Firebase Auth
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (user == null) {
        _setError('Failed to sign in');
        _setLoading(false);
        return null;
      }

      // Load user data from Firestore
      try {
        final userData = await _userRepository.getUserData(user.id);
        _currentUserData = userData ?? user;
      } catch (e) {
        debugPrint('Warning: Could not load user data from Firestore: $e');
        _currentUserData = user;
      }

      _setLoading(false);
      return _currentUserData;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  // ==================== SIGN IN WITH GOOGLE ====================

  /// Sign in with Google
  /// Also creates/loads user data from Firestore
  Future<UserEntity?> signInWithGoogle() async {
    try {
      debugPrint('📱 AuthService: Starting Google Sign-In');
      _setLoading(true);
      _setError(null);

      // Sign in with Google
      final user = await _authRepository.signInWithGoogle();
      debugPrint('📱 AuthService: Repository returned user: ${user?.id}');

      if (user == null) {
        debugPrint('📱 AuthService: User is null, sign in canceled');
        _setError('Google sign in canceled');
        _setLoading(false);
        return null;
      }

      // Check if user data exists in Firestore
      try {
        debugPrint('📱 AuthService: Loading user data from Firestore');
        var userData = await _userRepository.getUserData(user.id);

        // If user data doesn't exist, create it
        if (userData == null) {
          debugPrint('📱 AuthService: User data not found, creating new');
          await _userRepository.saveUserData(user);
          userData = user;
        } else {
          debugPrint('📱 AuthService: User data loaded from Firestore');
        }

        _currentUserData = userData;
      } catch (e) {
        debugPrint('📱 AuthService: Warning - Could not load/save user data from Firestore: $e');
        _currentUserData = user;
      }

      _setLoading(false);
      debugPrint('📱 AuthService: Sign-In complete, returning user: ${_currentUserData?.id}');
      return _currentUserData;
    } catch (e) {
      debugPrint('📱 AuthService: Exception during sign in: $e');
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authRepository.signOut();
      _currentUserData = null;

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to sign out: ${e.toString()}');
    }
  }

  // ==================== RESET PASSWORD ====================

  /// Reset password via email
  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authRepository.resetPassword(email: email);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // ==================== EMAIL VERIFICATION ====================

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setError(null);
      await _authRepository.sendEmailVerification();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Reload user to get updated info
  Future<void> reloadUser() async {
    try {
      await _authRepository.reloadUser();
      notifyListeners();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  // ==================== UPDATE PASSWORD ====================

  /// Update password (requires recent login)
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authRepository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // ==================== DELETE ACCOUNT ====================

  /// Delete account (requires recent login)
  Future<bool> deleteAccount({required String password}) async {
    try {
      _setLoading(true);
      _setError(null);

      final userId = currentUser?.uid;
      if (userId == null) {
        _setError('No user logged in');
        _setLoading(false);
        return false;
      }

      // Delete user data from Firestore first
      try {
        await _userRepository.deleteUserData(userId);
      } catch (e) {
        debugPrint('Warning: Could not delete user data from Firestore: $e');
      }

      // Delete Firebase Auth account
      await _authRepository.deleteAccount(password: password);

      _currentUserData = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // ==================== LOAD USER DATA ====================

  /// Load user data from Firestore
  Future<void> loadUserData() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) return;

      final userData = await _userRepository.getUserData(userId);
      if (userData != null) {
        _currentUserData = userData;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // ==================== WATCH USER DATA ====================

  /// Stream user data changes from Firestore
  Stream<UserEntity?> watchUserData() {
    final userId = currentUser?.uid;
    if (userId == null) {
      return Stream.value(null);
    }

    return _userRepository.watchUserData(userId);
  }
}
