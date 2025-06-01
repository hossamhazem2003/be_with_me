class RegisterRequestModel {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String role;
  final String gender;
  final String fullName;
  final String dateOfBirth;
  final String profileImage;

  RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
    required this.gender,
    required this.fullName,
    required this.dateOfBirth,
    required this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'Username': username,
      'Email': email,
      'Password': password,
      'ConfirmPassword': confirmPassword,
      'Role': role,
      'Gender': gender,
      'FullName':fullName,
      'DateOfBirth': dateOfBirth,
      'ProfileImage': profileImage,
    };
  }
} 