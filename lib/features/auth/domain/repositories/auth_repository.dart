import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../entities/user_entity.dart';

/// Repository Interface cho Authentication
/// Define các method cần implement ở Data Layer
abstract class AuthRepository {
  // Auth state stream
  Stream<firebase_auth.User?> get authStateChanges;

  // Current user
  firebase_auth.User? get currentUser;

  /// Sign up with email and password
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with email and password
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<UserEntity?> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Reset password
  Future<void> resetPassword({required String email});

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Reload user
  Future<void> reloadUser();

  /// Update password (requires recent login)
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Delete account (requires recent login)
  Future<void> deleteAccount({required String password});
}
