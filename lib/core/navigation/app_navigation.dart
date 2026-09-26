import 'package:flutter/material.dart';
import '../constants/app_routes.dart';

/// Global navigator key so non-widget layers (push notification handlers,
/// services) can navigate without a `BuildContext`.
///
/// Deliberately created at the top level: `NotificationService` and
/// `PushNavigationProvider` both need a stable reference, and a `StatefulWidget`
/// key would be unavailable while `main()` is still running.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Tracks which named route is currently on screen and notifies listeners when
/// that changes, so a pending deep link can wait for the splash/onboarding
/// stack to be replaced by the real app before navigating.
class AppRouteObserver extends NavigatorObserver with ChangeNotifier {
  String? _currentRoute;

  /// Name of the top-most route, or null before the first route is pushed.
  String? get currentRoute => _currentRoute;

  /// True once the user is past the pre-auth screens, i.e. the app is ready to
  /// show a deep-linked screen.
  bool get isReady =>
      _currentRoute != null && !kPreAuthRoutes.contains(_currentRoute);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _currentRoute = route.settings.name;
    notifyListeners();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_currentRoute == route.settings.name) {
      _currentRoute = previousRoute?.settings.name;
    }
    notifyListeners();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _currentRoute = newRoute?.settings.name;
    notifyListeners();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_currentRoute == route.settings.name) {
      _currentRoute = previousRoute?.settings.name;
    }
    notifyListeners();
  }
}

final AppRouteObserver appRouteObserver = AppRouteObserver();
