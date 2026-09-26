import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  /// Firestore document id of the application this notification is about.
  /// Written by the admin when a status is updated, and forwarded to the push
  /// payload by the Cloud Function so a tapped notification can open
  /// `/application-detail`.
  final String? applicationId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.applicationId,
  });

  factory NotificationModel.fromFireStore(
      Map<String, dynamic> json, String id) {
    final applicationId = json['applicationId']?.toString().trim();
    return NotificationModel(
      id: id,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      applicationId: (applicationId == null || applicationId.isEmpty)
          ? null
          : applicationId,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      applicationId: applicationId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'applicationId': applicationId,
    };
  }
}
