class LoginResponseModel {
  final String token;
  final String message;
  final String role;
  final String userId;

  LoginResponseModel({
    required this.token,
    required this.message,
    required this.role,
    required this.userId
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'],
      message: json['message'],
      role: json['role'],
      userId: json['userId']
    );
  }
}
