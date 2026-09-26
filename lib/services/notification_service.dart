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

  PushPayload? _initialPayload;
  String? _tokenUid;
  bool _initialized = false;

  /// Emits the payload of every notification the user taps while the app is
  /// running (background or foreground).
  Stream<PushPayload> get payloads => _payloadController.stream;

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
      });

      // User tapped a notification while the app was in background.
      FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);

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
}
