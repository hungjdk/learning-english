import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service for managing PIN authentication
/// Stores PIN securely and handles verification
class PinSecurityService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _pinKey = 'user_pin_hash';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _pinLengthKey = 'pin_length';

  // ==================== PIN SETUP ====================

  /// Check if PIN is enabled
  Future<bool> isPinEnabled() async {
    final value = await _secureStorage.read(key: _pinEnabledKey);
    return value == 'true';
  }

  /// Check if PIN exists
  Future<bool> hasPinSet() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  /// Get PIN length (4 or 6)
  Future<int> getPinLength() async {
    final length = await _secureStorage.read(key: _pinLengthKey);
    return int.tryParse(length ?? '4') ?? 4;
  }

  /// Set up a new PIN
  /// Returns true if successful
  Future<bool> setupPin({
    required String pin,
    required int pinLength,
  }) async {
    try {
      // Validate PIN
      if (!_isValidPin(pin, pinLength)) {
        return false;
      }

      // Hash the PIN before storing
      final hashedPin = _hashPin(pin);

      // Store PIN hash, enabled status, and length
      await _secureStorage.write(key: _pinKey, value: hashedPin);
      await _secureStorage.write(key: _pinEnabledKey, value: 'true');
      await _secureStorage.write(key: _pinLengthKey, value: pinLength.toString());

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verify PIN
  /// Returns true if PIN matches
  Future<bool> verifyPin(String pin) async {
    try {
      final storedHash = await _secureStorage.read(key: _pinKey);
      if (storedHash == null) return false;

      final inputHash = _hashPin(pin);
      return inputHash == storedHash;
    } catch (e) {
      return false;
    }
  }

  /// Change existing PIN
  /// Requires old PIN for verification
  Future<bool> changePin({
    required String oldPin,
    required String newPin,
    required int pinLength,
  }) async {
    try {
      // Verify old PIN first
      final isOldPinCorrect = await verifyPin(oldPin);
      if (!isOldPinCorrect) return false;

      // Set up new PIN
      return await setupPin(pin: newPin, pinLength: pinLength);
    } catch (e) {
      return false;
    }
  }

  /// Enable PIN authentication
  Future<void> enablePin() async {
    await _secureStorage.write(key: _pinEnabledKey, value: 'true');
  }

  /// Disable PIN authentication
  Future<void> disablePin() async {
    await _secureStorage.write(key: _pinEnabledKey, value: 'false');
  }

  /// Delete PIN completely
  /// Use this when user wants to remove PIN security
  Future<void> deletePin() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.delete(key: _pinEnabledKey);
    await _secureStorage.delete(key: _pinLengthKey);
  }

  // ==================== PRIVATE HELPERS ====================

  /// Hash PIN using SHA-256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate PIN format
  bool _isValidPin(String pin, int expectedLength) {
    // Check if PIN is numeric
    if (!RegExp(r'^\d+$').hasMatch(pin)) return false;

    // Check length
    if (pin.length != expectedLength) return false;

    return true;
  }
}
