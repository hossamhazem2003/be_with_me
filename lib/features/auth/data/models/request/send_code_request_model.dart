class SendCodeRequestModel {
  String email;
  SendCodeRequestModel({required this.email});
    Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}