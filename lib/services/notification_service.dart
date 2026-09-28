import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/push_payload.dart';

/// Top-level background handler — must not use UI or Flutter bindings.
/// Runs when a push notification arrives while the app is terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background notification: ${message.notification?.title}');
}

/// Handles FCM push notification setup and token registration.
///
/// In-app notifications live in Firestore (see `NotificationProvider`); this
/// service wires up the device-level push channel and turns a tapped message
/// into a [PushPayload].
///
/// The service never navigates — it only reports payloads on [payloads]. That
/// keeps it free of UI concerns; `PushNavigationProvider` resolves the payload
/// into a route.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<PushPayload> _payloadController =
      StreamController<PushPayload>.broadcast();

  final StreamController<RemoteMessage> _onNotificationTappedController =
      StreamController<RemoteMessage>.broadcast();

  final StreamController<RemoteMessage> _onForegroundMessageController =
      StreamController<RemoteMessage>.broadcast();

  final StreamController<RemoteMessage> _onLaunchMessageController =
      StreamController<RemoteMessage>.broadcast();

  PushPayload? _initialPayload;
  String? _tokenUid;
  bool _initialized = false;

  /// Emits the payload of every notification the user taps while the app is
  /// running (background or foreground).
  Stream<PushPayload> get payloads => _payloadController.stream;

  /// Stream of notification tap events while app is backgrounded/running.
  Stream<RemoteMessage> get onNotificationTapped =>
      _onNotificationTappedController.stream;

  /// Stream of notification messages received while app is in foreground.
  Stream<RemoteMessage> get onForegroundMessage =>
      _onForegroundMessageController.stream;

  /// Stream of messages that launched the app from a terminated state.
  Stream<RemoteMessage> get onLaunchMessage =>
      _onLaunchMessageController.stream;

  /// The payload the app was cold-started with (tapped while terminated).
  /// Cleared on read so a pending notification is only opened once.
  PushPayload? takeInitialPayload() {
    final payload = _initialPayload;
    _initialPayload = null;
    return payload;
  }

  /// Requests permission and wires up message listeners.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Foreground messages. The `notifications` Firestore collection is the
      // source of truth for the in-app list, so a foreground push only needs
      // logging — no navigation, no local notification.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          'Foreground notification: ${message.notification?.title}',
        );
        _onForegroundMessageController.add(message);
      });

      // User tapped a notification while the app was in background.
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _onNotificationOpened(message);
        _onNotificationTappedController.add(message);
      });

      // The FCM token can rotate (reinstall, restore, token refresh) — keep
      // the copy on the user document current so pushes keep arriving.
      _messaging.onTokenRefresh.listen((String token) {
        final uid = _tokenUid;
        if (uid == null) return;
        _storeToken(uid, token);
      });

      // App launched by tapping a notification.
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        final payload = _parse(initialMessage);
        if (payload == null) {
          debugPrint(
            'App launched from a notification with no routable payload: '
            '${initialMessage.data}',
          );
        } else {
          // Held until a listener is ready — see `takeInitialPayload`.
          _initialPayload = payload;
        }
        _onLaunchMessageController.add(initialMessage);
      }
    } catch (e) {
      debugPrint('NotificationService initialize failed: $e');
    }
  }

  void _onNotificationOpened(RemoteMessage message) {
    final payload = _parse(message);
    if (payload == null) {
      debugPrint(
        'Notification opened with no routable payload: ${message.data}',
      );
      return;
    }
    debugPrint('Notification opened: ${message.data}');
    _payloadController.add(payload);
  }

  PushPayload? _parse(RemoteMessage message) {
    return PushPayload.fromData(
      message.data,
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }

  /// Stores the device's FCM token on the user's Firestore document so a
  /// server/Cloud Function can send them push notifications.
  Future<void> registerFcmToken(String uid) async {
    _tokenUid = uid;
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _storeToken(uid, token);
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  /// Stops refreshing the stored token (e.g. after logout).
  void clearFcmTokenUser() {
    _tokenUid = null;
  }

  /// Helper to simulate tapping a notification for testing & deep link testing.
  void simulateNotificationTap(RemoteMessage message) {
    _onNotificationOpened(message);
    _onNotificationTappedController.add(message);
  }

  /// Helper to simulate receiving a foreground notification for testing.
  void simulateForegroundMessage(RemoteMessage message) {
    _onForegroundMessageController.add(message);
  }

  /// Helper to simulate launching the app from a notification for testing.
  void simulateLaunchMessage(RemoteMessage message) {
    final payload = _parse(message);
    if (payload != null) {
      _initialPayload = payload;
    }
    _onLaunchMessageController.add(message);
  }

  Future<void> _storeToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Failed to store FCM token: $e');
    }
  }

  void dispose() {
    _payloadController.close();
    _onNotificationTappedController.close();
    _onForegroundMessageController.close();
    _onLaunchMessageController.close();
  }
}
