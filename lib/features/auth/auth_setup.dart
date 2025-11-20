import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/datasources/auth_datasource.dart';
import 'data/datasources/user_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'services/auth_service.dart';
import 'services/user_profile_service.dart';

/// Dependency Injection Setup
/// Call this to create instances of services
class AuthSetup {
  // Singletons
  static AuthService? _authService;
  static UserProfileService? _userProfileService;

  // ==================== CREATE SERVICES ====================

  /// Create AuthService instance
  static AuthService createAuthService() {
    if (_authService != null) {
      return _authService!;
    }

    // Create datasources
    final authDatasource = AuthDatasource(
      firebaseAuth: FirebaseAuth.instance,
    );

    final userDatasource = UserDatasource(
      firestore: FirebaseFirestore.instance,
    );

    // Create repositories
    final authRepository = AuthRepositoryImpl(
      authDatasource: authDatasource,
    );

    final userRepository = UserRepositoryImpl(
      userDatasource: userDatasource,
    );

    // Create service
    _authService = AuthService(
      authRepository: authRepository,
      userRepository: userRepository,
    );

    return _authService!;
  }

  /// Create UserProfileService instance
  static UserProfileService createUserProfileService() {
    if (_userProfileService != null) {
      return _userProfileService!;
    }

    // Create datasource
    final userDatasource = UserDatasource(
      firestore: FirebaseFirestore.instance,
    );

    // Create repository
    final userRepository = UserRepositoryImpl(
      userDatasource: userDatasource,
    );

    // Create service
    _userProfileService = UserProfileService(
      userRepository: userRepository,
    );

    return _userProfileService!;
  }

  // ==================== RESET SERVICES ====================

  /// Reset all services (useful for testing)
  static void reset() {
    _authService = null;
    _userProfileService = null;
  }
}
