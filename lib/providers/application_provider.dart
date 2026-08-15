import 'dart:async';
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

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _appSub;
  String? _subscribedUid;


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

      final apps = snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(
            doc.data(),
            doc.id,
          ))
          .toList();

      _updateStatsFrom(apps);

      notifyListeners();
    } catch (e) {
      return;
    }
  }

  // Subscribe to real-time application updates
  // Prevents duplicate listeners and keeps stats in sync
  // when admin updates an application's status
  void subscribeToApplications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _appSub?.cancel();
      _appSub = null;
      _subscribedUid = null;
      _applications = [];
      _resetStats();
      _status = ApplicationStatus.initial;
      notifyListeners();
      return;
    }

    if (_subscribedUid == uid) return;

    _appSub?.cancel();
    _subscribedUid = uid;
    _status = ApplicationStatus.loading;
    notifyListeners();

    // No orderBy here - avoids the composite index requirement.
    // Results are sorted manually in Dart instead.
    _appSub = _firestore
        .collection('applications')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      final apps = snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(
            doc.data(),
            doc.id,
          ))
          .toList()
        ..sort((a, b) {
          final at = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bt.compareTo(at);
        });

      _applications = apps;
      _updateStatsFrom(apps);
      _status = ApplicationStatus.loaded;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = 'Failed to load applications.';
      _status = ApplicationStatus.error;
      notifyListeners();
    });
  }

  void _updateStatsFrom(List<ApplicationModel> apps) {
    _totalApplied = apps.length;
    _underReview = apps.where((a) => a.status == 'under_review').length;
    _accepted = apps.where((a) => a.status == 'accepted').length;
    _rejected = apps.where((a) => a.status == 'rejected').length;
  }

  void _resetStats() {
    _totalApplied = 0;
    _underReview = 0;
    _accepted = 0;
    _rejected = 0;
  }

  @override
  void dispose() {
    _appSub?.cancel();
    super.dispose();
  }

  // Delete application
Future<bool> deleteApplication(String id) async {
    if (id.isEmpty) return false;

    try {
      final docRef = _firestore.collection('applications').doc(id);

      // Remove uploaded documents subcollection first
      final docsSnapshot = await docRef.collection('documents').get();
      final batch = _firestore.batch();
      for (final doc in docsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Then remove the application itself
      await docRef.delete();

      // Remove from local list immediately (stream will also update)
      _applications.removeWhere((a) => a.id == id);
      _updateStatsFrom(_applications);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete application. Please try again.';
      notifyListeners();
      return false;
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
          .get();

      _applications = snapshot.docs
      .map((doc) => ApplicationModel.fromFirestore(
        doc.data(),
        doc.id,
      ))
      .toList()
      ..sort((a, b) {
        final at = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at);
      });

      _status = ApplicationStatus.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load applications.';
      _status = ApplicationStatus.error;
    }

    notifyListeners();
}

// Submit application
Future<String?> submitApplication(ApplicationModel application) async {
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

      return docRef.id;
    } catch (e) {
      _errorMessage = 'Failed to submit applications. Please try again.';
      _status = ApplicationStatus.error;
      notifyListeners();
      return null;
    }
}
}