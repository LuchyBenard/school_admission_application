class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final dateTime createdAt;

  NotificationModel({
    required this.id,
  required this.userId,
  required this.title,
  required this.message,
  required this.type,
  required this.isRead,
  required this.createdAt,
  });

  factory NotificationModel.fromFireStore(
  Map<String, dynamic> json, String is) {
    return NotificationModel(
  id: id,
  userId: json['userId'] ?? '',
  title: json['title'] ?? '',
  message: json['message'] ?? '',
  type: json['type'] ?? '',
  isRead: json['isRead'] ?? false,
  createdAt: json['createdAt'] != null
  ? Datetime.parse(json['createdAt'])
  : DateTime.now(),
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
    };
  }
  }
}