import 'package:flutter/material.dart';
import '../features/auth/services/pin_security_service.dart';
import '../core/theme/app_theme.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isChanging; // true if changing existing PIN, false for new setup

  const PinSetupScreen({
    Key? key,
    this.isChanging = false,
  }) : super(key: key);

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pinService = PinSecurityService();

  int _pinLength = 4; // Default 4-digit
  String _pin = '';
  String _confirmPin = '';
  String _oldPin = '';

  bool _isEnteringPin = true; // First step: enter PIN
  bool _isEnteringOldPin = false; // For PIN change
  bool _isConfirming = false; // Second step: confirm PIN
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isChanging) {
      _isEnteringOldPin = true;
      _isEnteringPin = false;
    }
  }

  void _onNumberPressed(int number) {
    setState(() {
      _errorMessage = null;

      if (_isEnteringOldPin) {
        if (_oldPin.length < _pinLength) {
          _oldPin += number.toString();
          if (_oldPin.length == _pinLength) {
            _verifyOldPin();
          }
        }
      } else if (_isEnteringPin) {
        if (_pin.length < _pinLength) {
          _pin += number.toString();
          if (_pin.length == _pinLength) {
            // Move to confirmation step
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                _isEnteringPin = false;
                _isConfirming = true;
              });
            });
          }
        }
      } else if (_isConfirming) {
        if (_confirmPin.length < _pinLength) {
          _confirmPin += number.toString();
          if (_confirmPin.length == _pinLength) {
            _verifyAndSave();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_isEnteringOldPin && _oldPin.isNotEmpty) {
        _oldPin = _oldPin.substring(0, _oldPin.length - 1);
      } else if (_isEnteringPin && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      } else if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      }
      _errorMessage = null;
    });
  }

  Future<void> _verifyOldPin() async {
    setState(() => _isLoading = true);

    final isCorrect = await _pinService.verifyPin(_oldPin);

    if (isCorrect) {
      setState(() {
        _isLoading = false;
        _isEnteringOldPin = false;
        _isEnteringPin = true;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Incorrect PIN. Try again.';
        _oldPin = '';
      });
    }
  }

  Future<void> _verifyAndSave() async {
    if (_pin != _confirmPin) {
      setState(() {
        _errorMessage = 'PINs do not match. Try again.';
        _confirmPin = '';
      });
      return;
    }

    setState(() => _isLoading = true);

    bool success;
    if (widget.isChanging) {
      success = await _pinService.changePin(
        oldPin: _oldPin,
        newPin: _pin,
        pinLength: _pinLength,
      );
    } else {
      success = await _pinService.setupPin(
        pin: _pin,
        pinLength: _pinLength,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(widget.isChanging ? 'PIN changed successfully!' : 'PIN set up successfully!'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Failed to save PIN. Try again.';
        _pin = '';
        _confirmPin = '';
        _isEnteringPin = true;
        _isConfirming = false;
      });
    }
  }

  String _getTitle() {
    if (_isEnteringOldPin) return 'Enter Current PIN';
    if (_isEnteringPin) return 'Create Your PIN';
    return 'Confirm Your PIN';
  }

  String _getSubtitle() {
    if (_isEnteringOldPin) return 'Enter your current PIN to continue';
    if (_isEnteringPin) return 'Enter a $_pinLength-digit PIN';
    return 'Enter your PIN again to confirm';
  }

  String _getCurrentPin() {
    if (_isEnteringOldPin) return _oldPin;
    if (_isEnteringPin) return _pin;
    return _confirmPin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paleBlue,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isChanging ? 'Change PIN' : 'Set Up PIN',
          style: const TextStyle(color: AppTheme.textDark),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 40),

                // Title
                Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  _getSubtitle(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                  ),
                ),

                // PIN Length Selector (only show for new PIN)
                if (_isEnteringPin && !widget.isChanging) ...[
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPinLengthOption(4),
                      const SizedBox(width: 16),
                      _buildPinLengthOption(6),
                    ],
                  ),
                ],

                const SizedBox(height: 40),

                // PIN Dots
                _buildPinDots(),

                // Error Message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
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
    );
  }

  Widget _buildPinLengthOption(int length) {
    final isSelected = _pinLength == length;
    return GestureDetector(
      onTap: () {
        setState(() {
          _pinLength = length;
          _pin = '';
          _confirmPin = '';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          '$length Digits',
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    final currentPin = _getCurrentPin();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pinLength,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < currentPin.length
                ? AppTheme.primaryBlue
                : Colors.grey.shade300,
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
          const SizedBox(height: 16),
          _buildNumberRow([4, 5, 6]),
          const SizedBox(height: 16),
          _buildNumberRow([7, 8, 9]),
          const SizedBox(height: 16),
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
          return const SizedBox(width: 70, height: 70);
        }

        if (number == -1) {
          // Delete button
          return GestureDetector(
            onTap: _onDeletePressed,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.backspace_outlined,
                color: AppTheme.textDark,
                size: 24,
              ),
            ),
          );
        }

        // Number button
        return GestureDetector(
          onTap: () => _onNumberPressed(number),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  fontSize: 24,
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
