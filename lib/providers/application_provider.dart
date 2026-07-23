import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application_model.dart';

enum ApplicationStatus { initial, loading, loaded, error }

class ApplicationProvider extends ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ApplicationStatus _status = ApplicationStatus.initial;
  List<ApplicationModel> _applications = [];
  String? _errorMessage;


  // Stats
  int _totalApplied = 0;
  int _underReview = 0;
  int _accepted = 0;
  int _rejected = 0;

  // Getters
  ApplicationStatus get status => _status;
  List<ApplicationModel> get applications => _applications;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ApplicationStatus.loading;
  int get totalApplied => _totalApplied;
  int get underReview => _underReview;
  int get accepted => _accepted;
  int get rejected => _rejected;

  // Load Application Stats
  Future<void> loadApplicationStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('userId', isEqualTo: uid)
          .get();

      _totalApplied = snapshot.docs.length;
      _underReview = snapshot.docs
      .where((d) => d['status'] == 'under_review')
      .length;
      _accepted = snapshot.docs
      .where((d) => d['status'] == 'accepted')
      .length;
      _rejected = snapshot.docs
          .where((d) => d['status'] == 'rejected')
          .length;

      notifyListeners();
    } catch (e) {
      return;
    }
  }

  // Load all applications
Future<void> loadApplications() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _status = ApplicationStatus.loading;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('applications')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      _applications = snapshot.docs
      .map((doc) => ApplicationModel.fromFirestore(
        doc.data(),
        doc.id,
      ))
      .toList();

      _status = ApplicationStatus.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load applications.';
      _status = ApplicationStatus.error;
    }

    notifyListeners();
}

// Submit application
Future<String> submitApplication(ApplicationModel application) async {
    _status = ApplicationStatus.loading;
    notifyListeners();

    try {
      final docRef = await _firestore.collection('applications').add({
        ...application.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Refresh stats
      await loadApplicationStats();

      _status = ApplicationStatus.loaded;
      notifyListeners();

      return docRef.id;;
    } catch (e) {
      _errorMessage = 'Failed to submit applications. Please try again.';
      _status = ApplicationStatus.error;
      notifyListeners();
      return null;
    }
}
}