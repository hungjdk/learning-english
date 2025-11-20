import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/services/auth_service.dart';
import '../core/theme/app_theme.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    final user = await authService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Welcome back! 🎉'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(authService.errorMessage ?? 'Login failed')),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final user = await authService.signInWithGoogle();

    if (!mounted) return;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Welcome! 🎉'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
        ),
      );
    } else if (authService.errorMessage != null && authService.errorMessage != 'Google sign in canceled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(authService.errorMessage ?? 'Google sign in failed')),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleBlue,
      body: Stack(
        children: [
          // Decorative floating elements
          Positioned(
            top: 50,
            right: 30,
            child: _buildFloatingEmoji('✨', 60),
          ),
          Positioned(
            top: 120,
            left: 30,
            child: _buildFloatingEmoji('📚', 50),
          ),
          Positioned(
            top: 200,
            right: 60,
            child: _buildFloatingEmoji('🌟', 45),
          ),
          Positioned(
            bottom: 150,
            left: 40,
            child: _buildFloatingEmoji('🎯', 55),
          ),
          Positioned(
            bottom: 80,
            right: 50,
            child: _buildFloatingEmoji('💡', 50),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Fun mascot area with emoji
                      Center(
                        child: Column(
                          children: [
                            // Main mascot
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(36),
                                border: Border.all(
                                  color: AppTheme.primaryBlue,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '🎓',
                                  style: TextStyle(fontSize: 70),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Small floating emoji
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSmallFloatingEmoji('📖', -20, -10),
                                const SizedBox(width: 120),
                                _buildSmallFloatingEmoji('✏️', 20, -15),
                              ],
                            ),
                          ],
                        ),
                      ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Sign in to continue learning',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppTheme.textGrey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'your.email@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return ElevatedButton(
                        onPressed: authService.isLoading ? null : _handleLogin,
                        child: authService.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text('Sign In'),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Sign-In Button
                  OutlinedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Text('🔵', style: TextStyle(fontSize: 20)),
                    label: Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textDark,
                      side: BorderSide(color: Colors.grey.shade300, width: 2),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Link với background xanh nhạt
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.paleBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                      // Fun motivational quote
                      AppTheme.infoBox(
                        icon: Icons.lightbulb_outline,
                        text: 'Learning a new language opens new worlds! 🌍',
                        backgroundColor: Colors.white,
                        iconColor: AppTheme.accentYellow,
                        textColor: AppTheme.textGrey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for floating emoji decorations
  Widget _buildFloatingEmoji(String emoji, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.6),
        ),
      ),
    );
  }

  // Helper method for small floating emoji around mascot
  Widget _buildSmallFloatingEmoji(String emoji, double offsetX, double offsetY) {
    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentYellow.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
