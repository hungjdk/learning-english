import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/services/auth_service.dart';
import '../core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    final success = await authService.resetPassword(
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _emailSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Password reset email sent!'),
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
              Expanded(
                child: Text(
                  authService.errorMessage ?? 'Failed to send reset email',
                ),
              ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reset Password',
          style: TextStyle(color: AppTheme.textDark),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _emailSent ? _buildSuccessView() : _buildResetForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.paleBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.lock_reset,
                size: 50,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Text(
            'No worries! Enter your email and we\'ll send you a reset link',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleResetPassword(),
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
          const SizedBox(height: 24),

          // Info Box
          AppTheme.infoBox(
            icon: Icons.info_outline,
            text:
                'Check your spam folder if you don\'t see the email in your inbox',
            backgroundColor: AppTheme.paleBlue,
            iconColor: AppTheme.primaryBlue,
            textColor: AppTheme.textGrey,
          ),
          const SizedBox(height: 32),

          // Send Button
          Consumer<AuthService>(
            builder: (context, authService, child) {
              return ElevatedButton(
                onPressed: authService.isLoading ? null : _handleResetPassword,
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
                    : Text('Send Reset Link'),
              );
            },
          ),
          const SizedBox(height: 16),

          // Back to Login
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back to Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Icon
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              size: 50,
              color: AppTheme.successGreen,
            ),
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        Text(
          'We\'ve sent a password reset link to:',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textGrey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        Text(
          _emailController.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Instructions
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.paleBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.list_alt, color: AppTheme.primaryBlue, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Next Steps',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStep('1', 'Open the email we just sent'),
              _buildStep('2', 'Click on the reset password link'),
              _buildStep('3', 'Create your new password'),
              _buildStep('4', 'Sign in with your new password'),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Resend Button
        OutlinedButton.icon(
          onPressed: _handleResetPassword,
          icon: Icon(Icons.refresh),
          label: Text('Resend Email'),
        ),
        const SizedBox(height: 12),

        // Back to Login
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Back to Sign In'),
        ),
        const SizedBox(height: 24),

        // Additional Help
        AppTheme.infoBox(
          icon: Icons.help_outline,
          text: 'Still having trouble? Contact our support team for help',
          backgroundColor: Color(0xFFFFF3CD),
          iconColor: AppTheme.warningYellow,
          textColor: Color(0xFF856404),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
