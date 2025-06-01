// Events
import 'package:be_with_me_new_new/features/auth/data/models/request/login_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/register_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/reset_password_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/send_code_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/verify_code_request_model.dart';

abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final RegisterRequestModel request;
  RegisterEvent(this.request);
}

class LoginEvent extends AuthEvent {
  final LoginRequestModel request;
  LoginEvent(this.request);
}

class SendCodeEvent extends AuthEvent {
  final SendCodeRequestModel request;
  SendCodeEvent(this.request);
}

class VerifyCodeEvent extends AuthEvent {
  final VerifyCodeRequestModel request;
  VerifyCodeEvent(this.request);
}

class ResetPasswordEvent extends AuthEvent {
  final ResetPasswordRequestModel request;
  ResetPasswordEvent(this.request);
}

