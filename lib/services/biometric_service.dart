import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Wraps device biometrics (fingerprint / face) and the secure
/// storage used to hold credentials for fingerprint sign-in.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _emailKey = 'biometric_email';
  static const String _passwordKey = 'biometric_password';
  static const String _adminEmailKey = 'biometric_admin_email';
  static const String _adminPasswordKey = 'biometric_admin_password';

  /// Whether the device supports and has biometrics enrolled.
  Future<bool> get isSupported async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final deviceSupported = await _auth.isDeviceSupported();
      return canCheck && deviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Friendly label for the device's biometric type.
  Future<String> get biometricTypeLabel async {
    try {
      final types = await _auth.getAvailableBiometrics();
      if (types.contains(BiometricType.fingerprint)) return 'fingerprint';
      if (types.contains(BiometricType.face)) return 'Face ID';
      if (types.contains(BiometricType.strong)) return 'biometrics';
      if (types.contains(BiometricType.weak)) return 'device unlock';
      return 'biometrics';
    } catch (e) {
      return 'biometrics';
    }
  }

  /// Prompts the user to authenticate with their fingerprint / face.
  Future<bool> authenticate({
    String reason = 'Confirm your fingerprint to continue',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // ---- Student credentials ----

  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
  }

  Future<({String email, String password})?> readCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    if (email == null || password == null) return null;
    return (email: email, password: password);
  }

  Future<bool> get hasCredentials async {
    final email = await _storage.read(key: _emailKey);
    return email != null;
  }

  Future<void> deleteCredentials() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }

  // ---- Admin credentials ----

  Future<void> saveAdminCredentials(String email, String password) async {
    await _storage.write(key: _adminEmailKey, value: email);
    await _storage.write(key: _adminPasswordKey, value: password);
  }

  Future<({String email, String password})?> readAdminCredentials() async {
    final email = await _storage.read(key: _adminEmailKey);
    final password = await _storage.read(key: _adminPasswordKey);
    if (email == null || password == null) return null;
    return (email: email, password: password);
  }

  Future<bool> get hasAdminCredentials async {
    final email = await _storage.read(key: _adminEmailKey);
    return email != null;
  }

  Future<void> deleteAdminCredentials() async {
    await _storage.delete(key: _adminEmailKey);
    await _storage.delete(key: _adminPasswordKey);
  }
}
