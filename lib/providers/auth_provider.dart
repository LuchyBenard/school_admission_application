import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oktoast/oktoast.dart';
import '../core/constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State Variables
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  Map<String, dynamic>? _userProfile;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Constructors
  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        // Fetch full profile from Firestore
        _userProfile = await _authService.getUserProfile(user.uid);
        // Register this device for push notifications
        await NotificationService().registerFcmToken(user.uid);
      } else {
        _user = null;
        _userProfile = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  // REGISTER
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required BuildContext context,
  }) async {
    _setLoading();
    try {
      await _authService.register(
          fullName: fullName, email: email, phone: phone, password: password);

      _status = AuthStatus.authenticated;
      notifyListeners();

      showToast(
        'Account created successfully. Welcome',
        backgroundColor: AppColors.success,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();

      showToast(
        e.toString(),
        backgroundColor: AppColors.error,
      );
      return false;
    }
  }

  // LOGIN
  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _setLoading();
    try {
      await _authService.login(
        email: email,
        password: password,
      );

      _status = AuthStatus.authenticated;
      notifyListeners();

      showToast(
        'Welcome back!',
        backgroundColor: AppColors.success,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseError(e.code);
      _status = AuthStatus.error;
      notifyListeners();

      showToast(
        _errorMessage!,
        backgroundColor: AppColors.error,
      );

      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _status = AuthStatus.error;
      notifyListeners();

      showToast(
        _errorMessage!,
        backgroundColor: AppColors.error,
      );
      return false;
    }
  }

  // VERIFY PASSWORD (used to enable fingerprint sign-in from profile)
  Future<bool> verifyPassword({
    required String email,
    required String password,
  }) async {
    return _authService.verifyPassword(email: email, password: password);
  }

  // LOGOUT
  Future<void> logout(BuildContext context) async {
    _setLoading();
    try {
      await _authService.logout();
      if (!context.mounted) return;
      _user = null;
      _userProfile = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    } catch (e) {
      _errorMessage = 'Failed to logout. Please try again.';
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  // Forgot password
  Future<bool> sendPasswordResetEmail({
    required String email,
  }) async {
    _setLoading();
    try {
      await _authService.sendPasswordResetEmail(email: email);
      _status = AuthStatus.unauthenticated;
      notifyListeners(); // Added notify
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseError(e.code);
      _status = AuthStatus.error;
      notifyListeners();

      showToast(
        _errorMessage!,
        backgroundColor: AppColors.error,
      );
      return false;
    }
  }

  // RESET PASSWORD
  Future<bool> confirmPasswordReset({
    required String otp,
    required String newPassword,
  }) async {
    _setLoading();
    try {
      await _authService.confirmPasswordReset(
        otp: otp,
        newPassword: newPassword,
      );

      _status = AuthStatus.unauthenticated;
      notifyListeners();

      showToast(
        'Password reset successful! Please sign in.',
        backgroundColor: AppColors.success,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _handleFirebaseError(e.code);
      _status = AuthStatus.error;
      notifyListeners();

      showToast(
        _errorMessage!,
        backgroundColor: AppColors.error,
      );
      return false;
    }
  }

  // UPDATE PROFILE
  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String dateOfBirth,
    required String stateOfOrigin,
  }) async {
    if (_user == null) return false;
    _setLoading();
    try {
      final uid = _user!.uid;

      await _authService.updateUserProfile(
        uid: uid,
        data: {
          'fullName': fullName,
          'phone': phone,
          'dateOfBirth': dateOfBirth,
          'stateOfOrigin': stateOfOrigin,
        },
      );

      // Update local profile
      _userProfile = {
        ..._userProfile ?? {},
        'fullName': fullName,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'stateOfOrigin': stateOfOrigin,
      };
      _status = AuthStatus.authenticated;
      notifyListeners();

      showToast(
        'Profile updated successfully',
        backgroundColor: AppColors.success,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile. Please try again.';
      _status = AuthStatus.error;
      notifyListeners();
      showToast(
        _errorMessage!,
        backgroundColor: AppColors.error,
      );
      return false;
    }
  }

  // Helpers
  void _setLoading() {
    _status = AuthStatus.loading;
    notifyListeners();
  }

  String _handleFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-action-code':
        return 'Invalid or expired OTP. Please request a new one.';
      case 'expired-action-code':
        return 'OTP has expired. Please request a new one.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}