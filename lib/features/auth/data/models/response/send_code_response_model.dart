class SendCodeResponseModel {
  String message;
  SendCodeResponseModel({required this.message});

  factory SendCodeResponseModel.fromJson(Map<String, dynamic> json){
    return SendCodeResponseModel(message: json['message']);
  }
}