class ResetPasswordResponseModel {
    String message;
  ResetPasswordResponseModel({required this.message});

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json){
    return ResetPasswordResponseModel(message: json['message']);
  }
}