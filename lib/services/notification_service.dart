import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background handler — must not use UI or Flutter bindings.
/// Runs when a push notification arrives while the app is terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background notification: ${message.notification?.title}');
}

/// Handles FCM push notification setup and token registration.
/// In-app notifications live in Firestore (see NotificationProvider);
/// this service wires up the device-level push channel.
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Requests permission and wires up message listeners.
  Future<void> initialize() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground notification: ${message.notification?.title}');
      });

      // User tapped a notification while the app was in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification opened: ${message.data}');
      });

      // App launched by tapping a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched from notification: ${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('NotificationService initialize failed: $e');
    }
  }

  /// Stores the device's FCM token on the user's Firestore document so a
  /// server/Cloud Function can send them push notifications.
  Future<void> registerFcmToken(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _firestore.collection('users').doc(uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }
}
