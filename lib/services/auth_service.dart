import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Firebase instances
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    
    // Get current user
User? get CurrentUser => _auth.currentUser;

// Auth state stream
// Listens for login/logout changes in real state
Stream<User> get authStateChanges => _auth.authStateChanges();

// Register
Future<UserCredentials> register({
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
  . collection ('users')
  . doc(credential.user!.uid)
  . set({
  'uid': credential.user!.uid,
  'fullName': fullName,
  'email': email,
  'phone': phone,
  'role': student,
  'createdat': FieldValue.serverTimestamp(),
  });

// Update display name in Firebase Auth
await credential.user!.updateDisplayName(fullName);

return credential;
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
Future<Map<String, dynamic>?> getUserProfile(String, uid) async {
  final doc = await _firestore.collection('users').doc(uid).get();
  return doc.exists ? doc.data() : null;
}
}