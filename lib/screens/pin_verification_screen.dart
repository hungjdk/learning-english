import 'package:flutter/material.dart';
import '../features/auth/services/pin_security_service.dart';
import '../core/theme/app_theme.dart';

class PinVerificationScreen extends StatefulWidget {
  const PinVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final _pinService = PinSecurityService();

  int _pinLength = 4;
  String _pin = '';
  bool _isLoading = true;
  String? _errorMessage;
  int _attemptCount = 0;
  static const int _maxAttempts = 5;

  @override
  void initState() {
    super.initState();
    _loadPinLength();
  }

  Future<void> _loadPinLength() async {
    final length = await _pinService.getPinLength();
    setState(() {
      _pinLength = length;
      _isLoading = false;
    });
  }

  void _onNumberPressed(int number) {
    if (_pin.length >= _pinLength) return;

    setState(() {
      _pin += number.toString();
      _errorMessage = null;
    });

    if (_pin.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_pin.isEmpty) return;

    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _verifyPin() async {
    final isCorrect = await _pinService.verifyPin(_pin);

    if (isCorrect && mounted) {
      // PIN correct - return success
      Navigator.pop(context, true);
    } else {
      // PIN incorrect
      setState(() {
        _attemptCount++;
        if (_attemptCount >= _maxAttempts) {
          _errorMessage = 'Too many attempts. Please restart the app.';
        } else {
          _errorMessage = 'Incorrect PIN. ${_maxAttempts - _attemptCount} attempts left.';
        }
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: AppTheme.paleBlue,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // App Logo/Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Enter PIN',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'Unlock to continue',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // PIN Dots
                    _buildPinDots(),

                    // Error Message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppTheme.errorRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Number Pad
                    _buildNumberPad(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pinLength,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _pin.length
                ? AppTheme.primaryBlue
                : Colors.grey.shade300,
            border: Border.all(
              color: index < _pin.length
                  ? AppTheme.primaryBlue
                  : Colors.grey.shade400,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildNumberRow([1, 2, 3]),
          const SizedBox(height: 20),
          _buildNumberRow([4, 5, 6]),
          const SizedBox(height: 20),
          _buildNumberRow([7, 8, 9]),
          const SizedBox(height: 20),
          _buildNumberRow([null, 0, -1]), // null for empty, -1 for delete
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<int?> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number == null) {
          return const SizedBox(width: 75, height: 75);
        }

        if (number == -1) {
          // Delete button
          return GestureDetector(
            onTap: _onDeletePressed,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.backspace_outlined,
                color: AppTheme.textDark,
                size: 26,
              ),
            ),
          );
        }

        // Number button
        return GestureDetector(
          onTap: () => _onNumberPressed(number),
          child: Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
