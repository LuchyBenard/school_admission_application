import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Wraps device biometrics (fingerprint / face) and the secure
/// storage used to hold the credentials for fingerprint sign-in.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _emailKey = 'biometric_email';
  static const String _passwordKey = 'biometric_password';

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

  /// Prompts the user to authenticate with their fingerprint / face.
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Confirm your fingerprint to sign in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

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
}
