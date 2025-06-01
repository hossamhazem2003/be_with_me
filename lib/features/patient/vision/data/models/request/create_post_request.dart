class CreatePostRequest {
  final String content;
  final DateTime createdAt;

  CreatePostRequest({
    required this.content,
    required this.createdAt,
  });

  factory CreatePostRequest.fromJson(Map<String, dynamic> json) {
    return CreatePostRequest(
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
