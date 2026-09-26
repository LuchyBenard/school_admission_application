/// The `data` payload of an FCM message, parsed into something the app can act
/// on.
///
/// The Cloud Function (`functions/index.js`) builds this payload when a
/// `notifications` document is created, so the keys below are the contract
/// between the backend and the app:
///
/// ```json
/// {
///   "notificationId": "notifDocId",
///   "applicationId":  "applicationDocId",
///   "type":           "accepted"
/// }
/// ```
///
/// Kept free of any Firebase imports so it can be unit tested and reused for
/// both push payloads and in-app notification taps.
class PushPayload {
  final String? notificationId;
  final String? applicationId;
  final String type;
  final String? title;
  final String? body;

  const PushPayload({
    this.notificationId,
    this.applicationId,
    this.type = 'update',
    this.title,
    this.body,
  });

  /// True when the payload points at a specific application, i.e. tapping it
  /// should open `/application-detail` rather than the notification list.
  bool get hasApplication =>
      applicationId != null && applicationId!.isNotEmpty;

  /// Builds a payload from an FCM `data` map.
  ///
  /// Returns null when the payload carries nothing to navigate to, so callers
  /// can ignore malformed or legacy messages.
  static PushPayload? fromData(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    final notificationId = _string(data['notificationId']);
    final applicationId = _string(data['applicationId']);

    if (notificationId == null && applicationId == null) return null;

    return PushPayload(
      notificationId: notificationId,
      applicationId: applicationId,
      type: _string(data['type']) ?? 'update',
      title: title,
      body: body,
    );
  }

  static String? _string(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
