class RegisterResponseModel {
  final String message;
  final String userId;
  final String role;
  final String token;

  RegisterResponseModel({
    required this.message,
    required this.userId,
    required this.role,
    required this.token,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'],
      userId: json['userId'],
      role: json['role'],
      token: json['token'],
    );
  }
} 