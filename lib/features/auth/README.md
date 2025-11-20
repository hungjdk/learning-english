# Authentication Feature Documentation

## Overview
This authentication feature provides a complete authentication system with:
- **Sign Up**: Create new user accounts
- **Sign In**: Login with email/password
- **Password Reset**: Reset password via email
- **Edit Profile**: Update user profile information
- **User Settings**: Manage user preferences
- **Firestore Integration**: Save user data to Cloud Firestore

## Architecture

The feature follows **Clean Architecture** principles:

```
lib/features/auth/
├── domain/                     # Business logic layer (framework independent)
│   ├── entities/              # Business objects
│   │   └── user_entity.dart
│   └── repositories/          # Repository interfaces
│       ├── auth_repository.dart
│       └── user_repository.dart
│
├── data/                      # Data layer (external dependencies)
│   ├── datasources/          # Data sources (Firebase, API, etc.)
│   │   ├── auth_datasource.dart
│   │   └── user_datasource.dart
│   ├── models/               # Data transfer objects
│   │   └── user_model.dart
│   └── repositories/         # Repository implementations
│       ├── auth_repository_impl.dart
│       └── user_repository_impl.dart
│
├── services/                  # Application services
│   ├── auth_service.dart
│   └── user_profile_service.dart
│
└── auth_setup.dart            # Dependency injection setup
```

## Setup Instructions

### 1. Install Dependencies

The following dependencies are already added to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.2
  cloud_firestore: ^5.5.0
  provider: ^6.1.1
```

Run:
```bash
flutter pub get
```

### 2. Configure Firebase

Ensure Firebase is initialized in your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
```

### 3. Setup Providers

In your `main.dart`, wrap your app with MultiProvider:

```dart
import 'package:provider/provider.dart';
import 'features/auth/auth_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Service
        ChangeNotifierProvider(
          create: (_) => AuthSetup.createAuthService(),
        ),
        // User Profile Service
        ChangeNotifierProvider(
          create: (_) => AuthSetup.createUserProfileService(),
        ),
      ],
      child: MaterialApp(
        title: 'Learn English',
        home: AuthWrapper(), // Your auth wrapper widget
      ),
    );
  }
}
```

## Usage Examples

### 1. Sign Up

```dart
import 'package:provider/provider.dart';
import 'package:learn_english/features/auth/services/auth_service.dart';

class SignUpScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Column(
        children: [
          TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
          TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
          TextField(controller: nameController, decoration: InputDecoration(labelText: 'Display Name')),

          if (authService.errorMessage != null)
            Text(authService.errorMessage!, style: TextStyle(color: Colors.red)),

          ElevatedButton(
            onPressed: authService.isLoading ? null : () async {
              final user = await authService.signUp(
                email: emailController.text,
                password: passwordController.text,
                displayName: nameController.text,
              );

              if (user != null) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            child: authService.isLoading
              ? CircularProgressIndicator()
              : Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
```

### 2. Sign In

```dart
import 'package:provider/provider.dart';
import 'package:learn_english/features/auth/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Column(
        children: [
          TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
          TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),

          if (authService.errorMessage != null)
            Text(authService.errorMessage!, style: TextStyle(color: Colors.red)),

          ElevatedButton(
            onPressed: authService.isLoading ? null : () async {
              final user = await authService.signIn(
                email: emailController.text,
                password: passwordController.text,
              );

              if (user != null) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            child: authService.isLoading
              ? CircularProgressIndicator()
              : Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
```

### 3. Reset Password

```dart
import 'package:provider/provider.dart';
import 'package:learn_english/features/auth/services/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Column(
        children: [
          TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),

          if (authService.errorMessage != null)
            Text(authService.errorMessage!, style: TextStyle(color: Colors.red)),

          ElevatedButton(
            onPressed: authService.isLoading ? null : () async {
              final success = await authService.resetPassword(
                email: emailController.text,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password reset email sent!')),
                );
                Navigator.pop(context);
              }
            },
            child: authService.isLoading
              ? CircularProgressIndicator()
              : Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }
}
```

### 4. Edit Profile

```dart
import 'package:provider/provider.dart';
import 'package:learn_english/features/auth/services/user_profile_service.dart';
import 'package:learn_english/features/auth/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profileService = Provider.of<UserProfileService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Column(
        children: [
          TextField(controller: nameController, decoration: InputDecoration(labelText: 'Display Name')),
          TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone Number')),
          TextField(controller: bioController, decoration: InputDecoration(labelText: 'Bio'), maxLines: 3),

          if (profileService.errorMessage != null)
            Text(profileService.errorMessage!, style: TextStyle(color: Colors.red)),

          if (profileService.successMessage != null)
            Text(profileService.successMessage!, style: TextStyle(color: Colors.green)),

          ElevatedButton(
            onPressed: profileService.isLoading || userId == null ? null : () async {
              final success = await profileService.updateProfile(
                userId: userId,
                displayName: nameController.text.isNotEmpty ? nameController.text : null,
                phoneNumber: phoneController.text.isNotEmpty ? phoneController.text : null,
                bio: bioController.text.isNotEmpty ? bioController.text : null,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated successfully!')),
                );
              }
            },
            child: profileService.isLoading
              ? CircularProgressIndicator()
              : Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
```

### 5. Auth State Management

Create an `AuthWrapper` to handle authentication state:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_english/features/auth/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen();
        }

        // User is not logged in
        return LoginScreen();
      },
    );
  }
}
```

## Features

### AuthService

**Methods:**
- `signUp({email, password, displayName})` - Create new account
- `signIn({email, password})` - Login
- `signOut()` - Logout
- `resetPassword({email})` - Send password reset email
- `sendEmailVerification()` - Send email verification
- `updatePassword({currentPassword, newPassword})` - Update password
- `deleteAccount({password})` - Delete account
- `loadUserData()` - Load user data from Firestore
- `watchUserData()` - Stream user data changes

**Properties:**
- `isLoading` - Loading state
- `errorMessage` - Error message
- `currentUser` - Firebase Auth user
- `currentUserData` - User data from Firestore
- `authStateChanges` - Auth state stream

### UserProfileService

**Methods:**
- `updateProfile({userId, displayName, phoneNumber, bio, photoUrl})` - Update profile
- `updateSettings({userId, ...settings})` - Update settings
- `getUserData(userId)` - Get user data
- `saveUserData(user)` - Save user data
- `watchUserData(userId)` - Stream user data

**Properties:**
- `isLoading` - Loading state
- `errorMessage` - Error message
- `successMessage` - Success message

## Firestore Structure

User data is saved in Firestore with this structure:

```
users/{userId}
  ├── id: string
  ├── email: string
  ├── displayName: string
  ├── photoUrl: string?
  ├── emailVerified: boolean
  ├── createdAt: timestamp
  ├── lastLoginAt: timestamp?
  ├── updatedAt: timestamp
  ├── profile:
  │   ├── phoneNumber: string?
  │   ├── bio: string?
  │   ├── language: string
  │   ├── totalXP: number
  │   ├── currentStreak: number
  │   ├── longestStreak: number
  │   ├── completedLessons: array
  │   └── achievements: map
  └── settings:
      ├── notificationsEnabled: boolean
      ├── soundEnabled: boolean
      ├── darkModeEnabled: boolean
      ├── languagePreference: string
      ├── dailyGoal: number
      ├── reminderEnabled: boolean
      └── reminderTime: timestamp?
```

## Security Rules

Add these Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Users can read and write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Error Handling

All errors are caught and converted to user-friendly messages in Vietnamese. You can modify error messages in:
- `auth_datasource.dart` - `_handleAuthException()` method

## Testing

To test the authentication system:

1. Enable Email/Password authentication in Firebase Console
2. Set up Firestore database
3. Add security rules
4. Run the app and test all features

## Notes

- User data is automatically saved to Firestore on sign up
- User data is loaded on sign in
- All operations are async and use proper error handling
- Services use ChangeNotifier for state management
- Clean architecture allows easy testing and maintenance
