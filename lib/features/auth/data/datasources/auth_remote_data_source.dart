import 'dart:developer';

import 'package:be_with_me_new_new/core/utils/shared_preferences_manager.dart';
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
import 'package:be_with_me_new_new/features/auth/domain/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRemoteDataSource implements AuthRepository {
  String baseUrl = 'https://bewtihme-001-site1.jtempurl.com/api/Account';

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      log('11');
      final response = await http.post(
        Uri.parse('$baseUrl/Login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      log(response.body);

      if (response.statusCode == 200) {
        final loginResponse =
            LoginResponseModel.fromJson(jsonDecode(response.body));
        // Save token to SharedPreferences
        await SharedPreferencesManager.setToken(loginResponse.token);
        await SharedPreferencesManager.setUserId(loginResponse.userId);
        return loginResponse;
      } else {
        log(response.body);
        throw Exception(
            'Failed to login: ${jsonDecode(response.body)['errors']}');
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      var headers = {
        'Host': 'bewtihme-001-site1.jtempurl.com',
        'Connection': 'keep-alive',
      };

      var uri = Uri.parse('$baseUrl/Register');
      var multipartRequest = http.MultipartRequest('POST', uri);
      multipartRequest.headers.addAll(headers);

      multipartRequest.fields.addAll({
        'Username': request.username,
        'Email': request.email,
        'Password': request.password,
        'ConfirmPassword': request.confirmPassword,
        'Role': request.role,
        'Gender': request.gender,
        'FullName': request.fullName,
        'DateOfBirth': request.dateOfBirth,
        'ProfileImage': request.profileImage
      });

      multipartRequest.headers.addAll(headers);
      final response = await multipartRequest.send();
      final responseBody = await response.stream.bytesToString();

      log('Register Response Status: ${response.statusCode}');
      log('Register Response Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        final registerResponse = RegisterResponseModel.fromJson(jsonResponse);
        return registerResponse;
      } else {
        final errorJson = jsonDecode(responseBody);
        throw Exception(errorJson['message'] ?? 'فشل في التسجيل');
      }
    } catch (e) {
      log('Register Error: $e');
      throw Exception('فشل في التسجيل: ${e.toString()}');
    }
  }

  @override
  Future<SendCodeResponseModel> sendCode(SendCodeRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/SendCode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return SendCodeResponseModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to sendCode: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to sendCode: ${e.toString()}');
    }
  }

  @override
  Future<VerifyCodeResponseModel> verifyCode(
      VerifyCodeRequestModel request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/VerifyCode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return VerifyCodeResponseModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to verifyCode: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to verifyCode: ${e.toString()}');
    }
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword(
      ResetPasswordRequestModel request) async {
    try {
      log(request.email);
      log(request.token);
      log(request.confirmPassword);

      final response = await http.post(
        Uri.parse('$baseUrl/ResetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      log(response.body);

      if (response.statusCode == 200) {
        return ResetPasswordResponseModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to reset password: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }
}
