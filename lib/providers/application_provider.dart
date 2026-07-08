import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApplicationProvider extends ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _totalApplied = 0;
  int _underReview = 0;
  int _accepted = 0;
  int _rejected = 0;

  int get totalApplied => _totalApplied;
  int get underReview => _underReview;
  int get accepted => _accepted;
  int get rejected => _rejected;

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
}