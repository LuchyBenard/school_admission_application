import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // Firebase instances
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    
    // Get current user
User? get currentUser => _auth.currentUser;

// Auth state stream
// Listens for login/logout changes in real state
Stream<User?> get authStateChanges => _auth.authStateChanges();

// Register
Future<UserCredential> register({
required String fullName,
required String email,
required String phone, 
  required String password,
}) async {
// _Create account in Firebase Auth
final UserCredential credential = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
);

// Save extra details to Firestore
// Firebase Auth only stores email and password. Everything else goes to Firestore
await _firestore
  .collection ('users')
  .doc(credential.user!.uid)
  .set({
  'uid': credential.user!.uid,
  'fullName': fullName,
  'email': email,
  'phone': phone,
  'role': 'student',
  'emailVerified': false,
  'createdAt': FieldValue.serverTimestamp(),
  });

// Update display name in Firebase Auth
await credential.user!.updateDisplayName(fullName);

// Send an email verification (link + code) so new accounts can't access
// the dashboard until the email is confirmed. A failure here must NOT
// fail the whole registration — the user can resend from the verify screen.
try {
  await credential.user!.sendEmailVerification();
} catch (e) {
  debugPrint('[AuthService] sendEmailVerification failed: $e');
}

return credential;
}

// EMAIL VERIFICATION
Future<void> sendEmailVerification() async {
  final user = _auth.currentUser;
  if (user == null) return;
  await user.sendEmailVerification();
}

// Reload the current user so `emailVerified` reflects the latest
// Firebase Auth state (e.g. after the user clicks the verify link).
Future<bool> reloadAndCheckVerified() async {
  final user = _auth.currentUser;
  if (user == null) return false;
  try {
    await user.reload();
  } catch (e) {
    debugPrint('[AuthService] reload failed: $e');
    return _auth.currentUser?.emailVerified == true;
  }
  return _auth.currentUser?.emailVerified == true;
}

// Verify the email using the code from the verification email.
// Firebase verification emails contain a link whose `oobCode` query
// parameter is the action code this method consumes.
Future<bool> verifyEmailWithActionCode(String code) async {
  final user = _auth.currentUser;
  if (user == null || code.trim().isEmpty) return false;
  try {
    await _auth.applyActionCode(code.trim());
    await user.reload();
    return _auth.currentUser?.emailVerified == true;
  } catch (e) {
    debugPrint('[AuthService] applyActionCode failed: $e');
    return false;
  }
}

// LOGIN
Future<UserCredential> login({
required String email,
  required String password,
}) async {
  return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password
  );
}

// ADMIN LOGIN
Future<UserCredential> adminLogin({
  required String email,
  required String password,
}) async {
  final credential = await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  // Check if user is admin
  final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
  final userData = userDoc.data();

  if (userData == null || userData['role'] != 'admin') {
    await _auth.signOut();
    throw Exception('Unauthorized access. Admin only.');
  }

  return credential;
}

// VERIFY PASSWORD (used to enable fingerprint sign-in)
Future<bool> verifyPassword({
  required String email,
  required String password,
}) async {
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return true;
  } catch (e) {
    return false;
  }
}

// LOGOUT
Future<void> logout() async {
  await _auth.signOut();
}

// FORGOT PASSWORD
Future<void> sendPasswordResetEmail({
    required String email,
}) async {
  await _auth.sendPasswordResetEmail(email: email);
}

// RESET PASSWORD WITH OTP
Future<void> confirmPasswordReset({
    required String otp,
  required String newPassword,
}) async {
  await _auth.confirmPasswordReset(
      code: otp,
      newPassword: newPassword,
  );
}

// GET USER PROFILE FROM FIRESTORE
Future<Map<String, dynamic>?> getUserProfile(String uid) async {
  final doc = await _firestore
      .collection('users')
      .doc(uid).get();
  return doc.exists ? doc.data() : null;
}

// UPDATE USER PROFILE
Future<void> updateUserProfile({
  required String uid,
  required Map<String, dynamic> data,
}) async {
  await _firestore
      .collection('users')
      .doc(uid)
      .update(data);
  }
}