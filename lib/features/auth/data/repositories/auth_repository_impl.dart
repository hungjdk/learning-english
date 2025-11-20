import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// Implementation of AuthRepository
/// Kết nối giữa Domain Layer và Data Layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _authDatasource;

  AuthRepositoryImpl({
    required AuthDatasource authDatasource,
  }) : _authDatasource = authDatasource;

  @override
  Stream<firebase_auth.User?> get authStateChanges =>
      _authDatasource.authStateChanges;

  @override
  firebase_auth.User? get currentUser => _authDatasource.currentUser;

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _authDatasource.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<UserEntity?> signIn({
    required String email,
    required String password,
  }) async {
    return await _authDatasource.signIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    return await _authDatasource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await _authDatasource.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _authDatasource.resetPassword(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    await _authDatasource.sendEmailVerification();
  }

  @override
  Future<void> reloadUser() async {
    await _authDatasource.reloadUser();
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authDatasource.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    await _authDatasource.deleteAccount(password: password);
  }
}
