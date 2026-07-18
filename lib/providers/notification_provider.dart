import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  // Load notifications
Future<void> loadNotifications() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

  _isLoading = true;
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

// Mark one as read
Future<void> markAsRead(String notificationId) async {
  try {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});

    // Update locally without refetching
    final index = _notifications
    .indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        isRead: true,
        createdAt: _notifications[index].createdAt,
      );
      _unreadCount =
          _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  } catch (e) {
    return;
  }
}

// Mark all as read
Future<void> markAllAsRead() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

  try {
    final batch = _firestore.batch();

    for (final notification in _notifications) {
      if (!notification.isRead) {
        final ref = _firestore
            .collection('notifications')
            .doc(notification.id);
        batch.update(ref, {'isRead': true});
      }
    }

    await batch.commit();

    // update all locally
    _notifications = _notifications
    .map((n) => NotificationModel(
        id: n.id,
        userId: n.userId,
        title: n.title,
        message: n.message,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
    ))
    .toList();
    _unreadCount = 0;
    notifyListeners();
  } catch (e) {
    return;
  }
}

// Delete one notification
Future<void> deleteNotification(String notificationId) async {
  try {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .delete();

    _notifications
    .removeWhere((n) => n.id == notificationId);
    _unreadCount =
        _notifications.where((n) => !n.isRead).length;
    notifyListeners();
  } catch (e) {
    return;
  }
    }

    // Clear all notifications
Future<void> clearAllNotifications() async {
  final uid = _auth.currentUser?.uid;
  if (uid == null) return;

  try {
    final batch = _firestore.batch();

     for (final notification in _notifications) {
       final ref = _firestore
           .collection('notifications')
           .doc(notification.id);
       batch.delete(ref);
     }

     await batch.commit();

     _notifications = [];
     _unreadCount = 0;
     notifyListeners();
  } catch (e) {
    return;
  }
  }
}