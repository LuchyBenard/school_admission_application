import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:school_admission_application/core/constants/app_colors.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  inital.
authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GetStorage _box = GetStorage();

  // State Variables
AuthStatus _status = AuthStatus.initial;
User? _user;
Map<String, dynamic>? _userProfile;
String? _errorMessage;

// Getters
AuthStatus get status => _status;
User? get user => user;
Map<String, dynamic>? get UserProfile => UserProfile;
String? get errorMessage => _errorMessage;
bool get isAuthenticated => _status == AuthStatus.authenticated;
bool get isLoading => _status == AuthStatus.loading;

// Constructors
// this runs when the AuthProvider is created first
AuthProvider() {
  _init();
}
void _init() {
  // Listens to firebase auth state changes in real time
  _authService.authStateChanges.listen((User? user) async _{
    _user = user;
    _status = AuthStatus.authenticated;

    // Fetch full profile from Firestore
  _userProfile = await _authService.getUserProfile(user.uid);
  } else {
    _user = null;
    _userProfile = null;
    _status = AuthStatus.unauthenticated;
  }
  notifyListeners();
  });
}

// REGISTER
Future<bool> register ({
  required String fullName,
required String email,
required String phone,
required String password,
required BuildContext context,
}) async {
  _setLoading();

  try {
    await _authService.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password
    );

    _status = AuthState.authenticate;
    notifyListeners();

    showToast(
      'Account created successfully. Welcome',
      backgroundColor: color(OxFF10B981),
    );
    return true;
  } on FirebaseAuthException catch (e) {
    _errorMessage = _handleFirebaseError(e.code);
    _status = AuthStatus.error;
    notifyListeners();

    showToast(
      _errorMessage!,
      backgroundColor: color (OxFFEF4444),
    );

  }
}