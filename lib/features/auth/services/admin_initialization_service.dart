import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';
import '../data/models/user_model.dart' show UserSettingsModel;

/// Service to initialize default admin user
class AdminInitializationService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AdminInitializationService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Initialize default admin user with credentials
  /// Returns true if admin was created, false if already exists
  Future<bool> initializeDefaultAdmin({
    String email = 'admin@example.com',
    String password = 'admin123', // Min 6 characters required
    String displayName = 'Admin User',
  }) async {
    try {
      // Check if admin already exists
      final adminDoc = await _firestore.collection('users').doc(email).get();
      if (adminDoc.exists) {
        print('✓ Admin user already exists');
        return false;
      }

      // Create Firebase Auth account for admin
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      final adminUser = userCredential.user!;



      // Create UserModel with admin role


      
      final adminUserModel = UserModel(
        id: adminUser.uid,
        email: adminUser.email ?? email,
        displayName: displayName,
        photoUrl: adminUser.photoURL,
        emailVerified: adminUser.emailVerified,
        createdAt: adminUser.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: adminUser.metadata.lastSignInTime,
        role: 'admin', // Set admin role
        profile: null,
        settings: const UserSettingsModel(),
      );

      // Save admin user to Firestore
      await _firestore
          .collection('users')
          .doc(adminUser.uid)
          .set(adminUserModel.toJson());

      print('✓ Default admin user created successfully');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('  📧 Email: $email');
      print('  🔑 Password: $password');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('  ⚠️  Change the password after first login!');

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('✓ Admin user already exists');
        return false;
      }
      print('✗ Error creating admin user: ${e.message}');
      rethrow;
    } catch (e) {
      print('✗ Error initializing admin: $e');
      rethrow;
    }
  }

  /// Check if admin user exists
  Future<bool> adminExists() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking admin existence: $e');
      return false;
    }
  }

  /// Get all admin users
  Future<List<UserModel>> getAllAdmins() async {
    try {
      final querySnapshot =
          await _firestore.collection('users').where('role', isEqualTo: 'admin').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching admins: $e');
      return [];
    }
  }

  /// Promote a user to admin
  Future<bool> promoteToAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'admin',
      });
      print('✓ User promoted to admin');
      return true;
    } catch (e) {
      print('Error promoting user to admin: $e');
      return false;
    }
  }

  /// Demote an admin to regular user
  Future<bool> demoteToUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'user',
      });
      print('✓ Admin demoted to user');
      return true;
    } catch (e) {
      print('Error demoting admin: $e');
      return false;
    }
  }
}
