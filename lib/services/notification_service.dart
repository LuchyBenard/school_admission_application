import 'dart:async';

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
/// this service wires up the device-level push channel and publishes the
/// payloads the user interacted with (see PushDeepLinkService).
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<RemoteMessage> _tappedController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _foregroundController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _launchController =
      StreamController<RemoteMessage>.broadcast();

  /// Payloads of notifications tapped while the app was already running
  /// (background → foreground). Hot start taps are published on
  /// [onLaunchMessage] instead, because the navigator is not ready yet.
  Stream<RemoteMessage> get onNotificationTapped => _tappedController.stream;

  /// Notifications received while the app is in the foreground. The OS shows
  /// no tray notification for these, so the UI presents an in-app prompt.
  Stream<RemoteMessage> get onForegroundMessage => _foregroundController.stream;

  /// The notification the app was cold started from, if any.
  Stream<RemoteMessage> get onLaunchMessage => _launchController.stream;

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
        if (!_foregroundController.isClosed) {
          _foregroundController.add(message);
        }
      });

      // User tapped a notification while the app was in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification opened: ${message.data}');
        if (!_tappedController.isClosed) {
          _tappedController.add(message);
        }
      });

      // App launched by tapping a notification. This resolves well after the
      // first frame, so it is published as a stream: subscribers buffer it
      // until the app is routed and ready to navigate.
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched from notification: ${initialMessage.data}');
        if (!_launchController.isClosed) {
          _launchController.add(initialMessage);
        }
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

  void dispose() {
    _tappedController.close();
    _foregroundController.close();
    _launchController.close();
  }
}
