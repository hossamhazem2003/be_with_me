class ResetPasswordRequestModel {
  final String email;
  final String password;
  final String confirmPassword;
  final String token;
  
  ResetPasswordRequestModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.token,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'confirmPassword': confirmPassword,
    'token': token,
  };
}