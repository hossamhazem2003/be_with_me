class VerifyCodeResponseModel {
  String resetToken;
  VerifyCodeResponseModel({required this.resetToken});

  factory VerifyCodeResponseModel.fromJson(Map<String,dynamic> json){
    return VerifyCodeResponseModel(resetToken: json['resetToken']);
  }
}