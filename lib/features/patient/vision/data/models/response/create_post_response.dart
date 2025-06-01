class CreatePostResponse {
  final int postId;
  final String message;

  CreatePostResponse({
    required this.postId,
    required this.message,
  });

  factory CreatePostResponse.fromJson(Map<String, dynamic> json) {
    return CreatePostResponse(
      postId: json['postId'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'message': message,
    };
  }
}
