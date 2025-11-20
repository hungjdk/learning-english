import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter để lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // Stream để listen auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Đăng ký tài khoản mới
  /// Returns: User nếu thành công, null nếu thất bại
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    UserCredential? credential;

    try {
      _setLoading(true);
      _setError(null);

      // Bước 1: Tạo tài khoản - Đây là bước CRITICAL
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // User đã được tạo thành công tại đây
      if (credential.user == null) {
        _setLoading(false);
        _setError('Không thể tạo tài khoản');
        return null;
      }

      // Bước 2: Update display name (không critical, nếu lỗi vẫn return user)
      try {
        await credential.user!.updateDisplayName(displayName.trim());
        await credential.user!.reload();
      } catch (e) {
        // Log error nhưng không fail toàn bộ process
        debugPrint('Warning: Could not update display name: $e');
      }

      // Bước 3: Gửi email verification (không critical, nếu lỗi vẫn return user)
      try {
        await credential.user!.sendEmailVerification();
      } catch (e) {
        // Log error nhưng không fail toàn bộ process
        debugPrint('Warning: Could not send verification email: $e');
        // Set warning message thay vì error
        _setError(
          'Tài khoản đã tạo nhưng không thể gửi email xác thực. Bạn có thể gửi lại sau.',
        );
      }

      _setLoading(false);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);

      // Nếu user đã được tạo nhưng có lỗi ở các bước sau
      if (credential?.user != null) {
        _setError(
          'Tài khoản đã tạo nhưng có một số vấn đề. Vui lòng đăng nhập.',
        );
        return credential!.user;
      }

      _setError(_getErrorMessage(e.code));
      return null;
    } catch (e) {
      _setLoading(false);

      // Nếu user đã được tạo nhưng có lỗi không xác định
      if (credential?.user != null) {
        debugPrint('Non-critical error after user creation: $e');
        _setError('Tài khoản đã tạo thành công');
        return credential!.user;
      }

      _setError('Đã xảy ra lỗi không xác định: ${e.toString()}');
      return null;
    }
  }

  /// Đăng nhập
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _setLoading(false);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getErrorMessage(e.code));
      return null;
    } catch (e) {
      _setLoading(false);
      _setError('Đã xảy ra lỗi không xác định: ${e.toString()}');
      return null;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);
      await _auth.signOut();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Không thể đăng xuất: ${e.toString()}');
    }
  }

  /// Reset mật khẩu qua email
  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _auth.sendPasswordResetEmail(email: email.trim());

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Không thể gửi email reset mật khẩu: ${e.toString()}');
      return false;
    }
  }

  /// Gửi lại email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setError(null);
      if (currentUser != null && !currentUser!.emailVerified) {
        await currentUser!.sendEmailVerification();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Không thể gửi email xác thực: ${e.toString()}');
      return false;
    }
  }

  /// Reload user để cập nhật emailVerified status
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
      notifyListeners();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  /// Chuyển đổi Firebase error code sang message tiếng Việt
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu, vui lòng chọn mật khẩu mạnh hơn';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'operation-not-allowed':
        return 'Thao tác không được phép';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      case 'requires-recent-login':
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ';
      default:
        return 'Đã xảy ra lỗi: $code';
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
