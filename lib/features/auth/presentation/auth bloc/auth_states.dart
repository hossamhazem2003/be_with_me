// States
import 'package:be_with_me_new_new/features/auth/data/models/response/login_response_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/register_response_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/reset_password_response_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/send_code_response_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/verify_code_response_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class RegisterSuccess extends AuthState {
  final RegisterResponseModel response;
  RegisterSuccess(this.response);
}

class LoginSuccess extends AuthState {
  final LoginResponseModel response;
  LoginSuccess(this.response);
}

class SendCodeSuccess extends AuthState {
  final SendCodeResponseModel response;
  SendCodeSuccess(this.response);
}

class VerifyCodeSuccess extends AuthState {
  final VerifyCodeResponseModel response;
  VerifyCodeSuccess(this.response);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class ResetPasswordSuccess extends AuthState {
  final ResetPasswordResponseModel response;
  ResetPasswordSuccess(this.response);
}
