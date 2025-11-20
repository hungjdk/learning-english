import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Auth Datasource - Direct interaction with Firebase Authentication
class AuthDatasource {
  final FirebaseAuth _firebaseAuth;

  AuthDatasource({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // ==================== GETTERS ====================

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  // ==================== SIGN UP ====================

  /// Sign up with email and password
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user account
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to create user account');
      }

      // Update display name
      try {
        await credential.user!.updateDisplayName(displayName.trim());
        await credential.user!.reload();
      } catch (e) {
        debugPrint('Warning: Could not update display name: $e');
      }

      // Send email verification
      try {
        await credential.user!.sendEmailVerification();
      } catch (e) {
        debugPrint('Warning: Could not send verification email: $e');
      }

      // Convert to UserEntity
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return UserModel.fromFirebaseUser(user).toEntity();
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // ==================== SIGN IN ====================

  /// Sign in with email and password
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        return UserModel.fromFirebaseUser(credential.user!).toEntity();
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // ==================== SIGN IN WITH GOOGLE ====================

  /// Sign in with Google
  Future<UserEntity?> signInWithGoogle() async {
    try {
      debugPrint('🔐 Datasource: Initiating Google Sign-In flow');

      // Trigger the Google Sign-In flow
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        debugPrint('🔐 Datasource: User canceled sign-in');
        return null;
      }

      debugPrint('🔐 Datasource: Google user selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      debugPrint('🔐 Datasource: Got authentication tokens');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      debugPrint('🔐 Datasource: Created Firebase credential');

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      debugPrint('🔐 Datasource: Firebase sign-in successful: ${userCredential.user?.uid}');

      if (userCredential.user != null) {
        final userEntity = UserModel.fromFirebaseUser(userCredential.user!).toEntity();
        debugPrint('🔐 Datasource: Returning user entity: ${userEntity.id}');
        return userEntity;
      }

      debugPrint('🔐 Datasource: userCredential.user is null!');
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('🔐 Datasource: FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('🔐 Datasource: Exception: $e');
      throw Exception('Google sign in failed: $e');
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      // Sign out from Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Reset password via email
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // ==================== EMAIL VERIFICATION ====================

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (currentUser != null && !currentUser!.emailVerified) {
        await currentUser!.sendEmailVerification();
      } else {
        throw Exception('No user logged in or email already verified');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Send email verification failed: $e');
    }
  }

  // ==================== RELOAD USER ====================

  /// Reload user to get updated information
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  // ==================== UPDATE PASSWORD ====================

  /// Update password (requires recent authentication)
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Update password failed: $e');
    }
  }

  // ==================== DELETE ACCOUNT ====================

  /// Delete user account (requires recent authentication)
  Future<void> deleteAccount({required String password}) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Delete account failed: $e');
    }
  }

  // ==================== ERROR HANDLING ====================

  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('Mật khẩu quá yếu, vui lòng chọn mật khẩu mạnh hơn');
      case 'email-already-in-use':
        return Exception('Email này đã được sử dụng');
      case 'invalid-email':
        return Exception('Email không hợp lệ');
      case 'operation-not-allowed':
        return Exception('Thao tác không được phép');
      case 'user-disabled':
        return Exception('Tài khoản đã bị vô hiệu hóa');
      case 'user-not-found':
        return Exception('Không tìm thấy tài khoản với email này');
      case 'wrong-password':
        return Exception('Mật khẩu không đúng');
      case 'too-many-requests':
        return Exception('Quá nhiều yêu cầu. Vui lòng thử lại sau');
      case 'network-request-failed':
        return Exception('Lỗi kết nối mạng');
      case 'requires-recent-login':
        return Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại');
      case 'invalid-credential':
        return Exception('Thông tin đăng nhập không hợp lệ');
      default:
        return Exception('Đã xảy ra lỗi: ${e.code}');
    }
  }
}
