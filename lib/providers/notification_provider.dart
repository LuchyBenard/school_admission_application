import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<NotificationModel> _notifications = [];
  bool _isloading = false;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isloading;
  int get unreadCount => _unreadCount;

  // Load notifications
Future<void> loadNotifications() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

  _isloading = true;
  notifyListeners();

  try {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    _notifications = snapshot.docs
    .map((doc) => NotificationModel.fromFireStore(
      doc.data(),
      doc.id,
    ))
    .toList();
  }

  _unreadCount =
      _notifications.where((n) => !n.isRead).length;
} catch (e) {
  // if no notifications yet, just show empty list
  _notifications = [];
  _unreadCount = 0;
  }

  _isLoading = false;
notifyListeners();
}

