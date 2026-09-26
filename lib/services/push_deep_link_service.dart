import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/application_model.dart';
import 'notification_service.dart';

/// Follows a tapped push notification to the screen it refers to.
///
/// The Cloud Function sends `{notificationId, type, applicationId}` as the
/// data payload, so a tap on a status update opens
/// `ApplicationDetailScreen` for the application that was updated. Payloads
/// without an application (e.g. a deadline reminder) open the notification
/// list instead.
///
/// Navigation is driven from a global [navigatorKey] (wired into MaterialApp
/// in main.dart) because a tap can arrive while the app is backgrounded, or
/// before the first frame has been built.
class PushDeepLinkService {
  PushDeepLinkService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'navigator');

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Tap waiting for the app to be routed (cold start) or for the user to be
  /// authenticated.
  static RemoteMessage? _pendingMessage;
  static bool _isNavigating = false;
  static bool _isAppReady = false;

  /// Subscribes to the push events published by [NotificationService].
  /// Call once, before `runApp`.
  static void init(NotificationService service) {
    service.onNotificationTapped.listen(handleTap);
    service.onForegroundMessage.listen(_promptForegroundTap);
    service.onLaunchMessage.listen(_bufferLaunchMessage);
  }

  /// Called by the splash screen once the user has been routed (dashboard,
  /// login, onboarding…). Any push that arrived before this point is followed
  /// as soon as navigation is possible.
  static void setAppReady() {
    _isAppReady = true;
    handlePendingMessage();
  }

  static void _bufferLaunchMessage(RemoteMessage message) {
    _pendingMessage ??= message;
    handlePendingMessage();
  }

  static Future<void> handlePendingMessage() async {
    final message = _pendingMessage;
    if (message == null) return;
    _pendingMessage = null;
    await handleTap(message);
  }

  /// Opens the screen referenced by a tapped push notification.
  static Future<void> handleTap(RemoteMessage message) async {
    // A tap that arrives while a previous one is still resolving is buffered
    // instead of stacking two screens on top of each other.
    if (_isNavigating) {
      _pendingMessage ??= message;
      return;
    }

    if (!_isAppReady || navigatorKey.currentState == null) {
      _pendingMessage ??= message;
      return;
    }

    _isNavigating = true;
    try {
      final data = message.data;
      final notificationId = data['notificationId']?.toString();
      if (notificationId != null && notificationId.isNotEmpty) {
        unawaited(_markAsRead(notificationId));
      }

      final user = _auth.currentUser ?? await _waitForUser();
      if (user == null) {
        // Signed out — the application cannot be shown, so the student is
        // sent to the login screen instead.
        _push('/login');
        return;
      }

      final applicationId = await _resolveApplicationId(data);
      if (applicationId != null) {
        final application = await _loadApplication(applicationId);
        if (application != null) {
          _push('/application-detail', arguments: application);
          return;
        }
      }

      _push('/notifications');
    } catch (e) {
      debugPrint('PushDeepLinkService: could not follow push: $e');
    } finally {
      _isNavigating = false;
    }
  }

  /// Loads an application by id and confirms it belongs to the signed-in user
  /// so a stale or tampered payload cannot open someone else's application.
  static Future<ApplicationModel?> _loadApplication(String id) async {
    try {
      final doc = await _firestore.collection('applications').doc(id).get();
      final data = doc.data();
      if (!doc.exists || data == null) return null;

      final application = ApplicationModel.fromFirestore(data, doc.id);
      if (application.userId != _auth.currentUser?.uid) return null;
      return application;
    } catch (e) {
      debugPrint('PushDeepLinkService: failed to load application $id: $e');
      return null;
    }
  }

  /// The application id is normally in the payload, but pushes sent before
  /// the deep-link payload shipped only carry the notification id — the
  /// notification document is then the source of truth.
  static Future<String?> _resolveApplicationId(
    Map<String, dynamic> data,
  ) async {
    final fromPayload = data['applicationId']?.toString();
    if (fromPayload != null && fromPayload.isNotEmpty) return fromPayload;

    final notificationId = data['notificationId']?.toString();
    if (notificationId == null || notificationId.isEmpty) return null;

    try {
      final doc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();
      final id = doc.data()?['applicationId']?.toString();
      return (id != null && id.isNotEmpty) ? id : null;
    } catch (e) {
      debugPrint('PushDeepLinkService: failed to resolve notification: $e');
      return null;
    }
  }

  static Future<void> _markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('PushDeepLinkService: failed to mark notification read: $e');
    }
  }

  /// The OS shows no tray notification while the app is in the foreground, so
  /// the push is surfaced in-app with an action that follows it.
  static void _promptForegroundTap(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message.notification?.title ?? 'You have a new update',
          ),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => handleTap(message),
          ),
        ),
      );
  }

  /// Auth state is restored asynchronously, so a cold-start tap can arrive
  /// before the session is available.
  static Future<User?> _waitForUser() {
    return _auth.userChanges()
        .firstWhere((user) => user != null)
        .timeout(const Duration(seconds: 10), onTimeout: () => null);
  }

  static void _push(String route, {Object? arguments}) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    if (arguments == null) {
      navigator.pushNamed(route);
    } else {
      navigator.pushNamed(route, arguments: arguments);
    }
  }
}
