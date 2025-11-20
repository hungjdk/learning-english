import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/services/pin_security_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'pin_verification_screen.dart';

/// AuthWrapper tự động chuyển đổi giữa Login và Home screen
/// dựa trên auth state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _userDataLoaded = false;
  bool _isPinVerified = false;
  final _pinService = PinSecurityService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reset PIN verification when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setState(() {
        _isPinVerified = false;
      });
    }
  }

  Future<void> _checkAndShowPinVerification() async {
    final pinEnabled = await _pinService.isPinEnabled();
    if (pinEnabled && !_isPinVerified && mounted) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const PinVerificationScreen(),
          fullscreenDialog: true,
        ),
      );

      if (result == true && mounted) {
        setState(() {
          _isPinVerified = true;
        });
      } else if (mounted) {
        // PIN verification failed or cancelled - keep showing verification
        _checkAndShowPinVerification();
      }
    } else {
      setState(() {
        _isPinVerified = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Đang loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Đã đăng nhập
        if (snapshot.hasData && snapshot.data != null) {
          // Load user data from Firestore if not loaded yet
          if (!_userDataLoaded) {
            _userDataLoaded = true;
            // Load asynchronously without blocking UI
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authService.loadUserData();
            });
          }

          // Check PIN authentication
          if (!_isPinVerified) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _checkAndShowPinVerification();
            });
          }

          // Show HomeScreen (PIN verification will overlay if needed)
          return const HomeScreen();
        }

        // Reset flags when user logs out
        _userDataLoaded = false;
        _isPinVerified = false;

        // Chưa đăng nhập
        return const LoginScreen();
      },
    );
  }
}
