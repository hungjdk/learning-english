import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'features/auth/auth_setup.dart';
import 'screens/auth_wrapper.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Đảm bảo Flutter binding được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Service with Firestore integration
        ChangeNotifierProvider(
          create: (_) => AuthSetup.createAuthService(),
        ),
        // User Profile Service for editing profile
        ChangeNotifierProvider(
          create: (_) => AuthSetup.createUserProfileService(),
        ),
      ],
      child: MaterialApp(
        title: 'Learn English',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
