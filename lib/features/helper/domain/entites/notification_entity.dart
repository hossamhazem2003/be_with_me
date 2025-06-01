class Notification {
  final int id;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final String type;
  final String patientName;
  final String profileImageUrl;

  Notification({
    required this.id,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.type,
    required this.patientName,
    required this.profileImageUrl,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      content: json['content'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
      type: json['type'] as String,
      patientName: json['patientName'] as String,
      profileImageUrl: (json['profileImageUrl'] as String).replaceAll("\\", "/"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'type': type,
      'patientName': patientName,
      'profileImageUrl': profileImageUrl,
    };
  }
}
