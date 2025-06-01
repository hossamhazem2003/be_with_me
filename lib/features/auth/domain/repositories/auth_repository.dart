import 'package:be_with_me_new_new/features/auth/data/models/request/login_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/register_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/reset_password_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/send_code_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/verify_code_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/login_response_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/register_response_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/reset_password_response_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/send_code_response_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/verify_code_response_model.dart';

abstract class AuthRepository {
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<SendCodeResponseModel> sendCode(SendCodeRequestModel request);
  Future<VerifyCodeResponseModel> verifyCode(VerifyCodeRequestModel request);
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request);
}