import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_routes.dart';
import '../core/navigation/app_navigation.dart';
import '../models/application_model.dart';
import '../models/notification_model.dart';
import '../models/push_payload.dart';
import '../services/notification_service.dart';
import 'notification_provider.dart';

/// Turns a tapped push notification into a navigation event.
///
/// `NotificationService` reports raw payloads; this provider owns the rest of
/// the deep-link flow:
///  - buffers the payload until the app has finished its cold-start
///    navigation (splash -> dashboard), so a push tapped from the terminated
///    state is never dropped or pushed on top of the splash;
///  - marks the notification as read;
///  - loads the `ApplicationModel` the payload points at, because
///    `/application-detail` and `/admin-applicant-detail` read their
///    `ApplicationModel` from `ModalRoute.settings.arguments`.
class PushNavigationProvider extends ChangeNotifier {
  PushNavigationProvider({required GlobalKey<NavigatorState> navigatorKey})
      : _navigatorKey = navigatorKey {
    appRouteObserver.addListener(_onRouteChanged);
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((_) => _flush());
    _payloadSubscription =
        NotificationService.instance.payloads.listen(_onPayload);

    // Push tapped while the app was terminated.
    final initial = NotificationService.instance.takeInitialPayload();
    if (initial != null) _onPayload(initial);

    // Safety net: the observer only fires on route changes, so retry until the
    // navigator is attached and the app is past the pre-auth screens.
    _scheduleRetry();
  }

  final GlobalKey<NavigatorState> _navigatorKey;

  late final StreamSubscription<User?> _authSubscription;
  late final StreamSubscription<PushPayload> _payloadSubscription;

  /// Set from `main.dart` through a `ChangeNotifierProxyProvider` so marking a
  /// notification as read reuses `NotificationProvider` (and its live Firestore
  /// subscription) instead of writing to Firestore a second time.
  NotificationProvider? _notificationProvider;

  PushPayload? _pending;
  Timer? _retryTimer;
  bool _opening = false;
  int _retryAttempts = 0;

  /// The payload waiting for the app to become navigable, if any.
  PushPayload? get pendingPayload => _pending;

  void attach(NotificationProvider notificationProvider) {
    _notificationProvider = notificationProvider;
  }

  /// Opens the screen a notification points at. Used by the in-app
  /// notification list so a tap behaves the same as a push tap.
  Future<void> openNotification(NotificationModel notification) {
    _onPayload(
      PushPayload(
        notificationId: notification.id,
        applicationId: notification.applicationId,
        type: notification.type,
        title: notification.title,
        body: notification.message,
      ),
    );
    return _flush();
  }

  void _onPayload(PushPayload payload) {
    _pending = payload;
    _retryAttempts = 0;
    unawaited(_flush());
  }

  void _onRouteChanged() {
    unawaited(_flush());
  }

  Future<void> _flush() async {
    final payload = _pending;
    if (payload == null || _opening) return;

    // Wait for the navigator to exist and for the splash / login stack to be
    // replaced by the app itself.
    if (_navigatorKey.currentState == null || !appRouteObserver.isReady) {
      _scheduleRetry();
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      // Signed out — there is no application to open.
      _pending = null;
      debugPrint('[PushNavigation] ignoring payload: no authenticated user');
      return;
    }

    _opening = true;
    _pending = null;
    _retryTimer?.cancel();

    try {
      await _open(payload);
    } catch (e) {
      debugPrint('[PushNavigation] failed to open payload: $e');
    } finally {
      _opening = false;
    }
  }

  Future<void> _open(PushPayload payload) async {
    final notificationId = payload.notificationId;
    if (notificationId != null) {
      await _markAsRead(notificationId);
    }

    if (!payload.hasApplication) {
      // Nothing to deep link into (e.g. a general announcement) — show the
      // notification list instead of silently doing nothing.
      _push(AppRoutes.notifications);
      return;
    }

    final application = await _loadApplication(payload.applicationId!);
    if (application == null) {
      debugPrint(
        '[PushNavigation] application ${payload.applicationId} not found',
      );
      _push(AppRoutes.notifications);
      return;
    }

    final isAdmin = await _isAdmin();

    // A student may only open their own application.
    if (!isAdmin && application.userId != FirebaseAuth.instance.currentUser?.uid) {
      debugPrint('[PushNavigation] application does not belong to this user');
      return;
    }

    _push(
      isAdmin ? AppRoutes.adminApplicantDetail : AppRoutes.applicationDetail,
      application,
    );
  }

  void _push(String route, [Object? arguments]) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    // Already on the destination (e.g. tapping inside the notification list).
    if (arguments == null && appRouteObserver.currentRoute == route) return;

    navigator.pushNamed(route, arguments: arguments);
  }

  Future<ApplicationModel?> _loadApplication(String applicationId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .get();
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return ApplicationModel.fromFirestore(data, doc.id);
    } catch (e) {
      debugPrint('[PushNavigation] could not load $applicationId: $e');
      return null;
    }
  }

  Future<bool> _isAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return doc.data()?['role'] == 'admin';
    } catch (e) {
      debugPrint('[PushNavigation] role lookup failed: $e');
      return false;
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    final provider = _notificationProvider;
    if (provider != null) {
      await provider.markAsRead(notificationId);
      return;
    }

    // Fallback: the provider may not be attached yet on a cold start.
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('[PushNavigation] could not mark $notificationId read: $e');
    }
  }

  void _scheduleRetry() {
    if (_pending == null || _retryTimer != null) return;
    // Bounded: ~6s of polling covers the splash animation.
    if (_retryAttempts >= 20) {
      _pending = null;
      return;
    }
    _retryAttempts++;
    _retryTimer = Timer(const Duration(milliseconds: 300), () {
      _retryTimer = null;
      unawaited(_flush());
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    appRouteObserver.removeListener(_onRouteChanged);
    _authSubscription.cancel();
    _payloadSubscription.cancel();
    super.dispose();
  }
}
