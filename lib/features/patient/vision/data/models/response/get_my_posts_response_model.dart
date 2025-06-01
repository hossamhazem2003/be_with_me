class GetMyPostsResponse {
  final int id;
  final String content;
  final DateTime createdAt;
  final int status;

  GetMyPostsResponse({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.status,
  });

  factory GetMyPostsResponse.fromJson(Map<String, dynamic> json) {
    return GetMyPostsResponse(
      id: json['id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
