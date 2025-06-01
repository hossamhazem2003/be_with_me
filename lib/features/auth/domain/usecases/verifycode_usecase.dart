import 'package:be_with_me_new_new/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/verify_code_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/verify_code_response_model.dart';
import 'package:be_with_me_new_new/features/auth/domain/repositories/auth_repository.dart';

class VerifyCodeUsecase {
  AuthRepository repository = AuthRemoteDataSource();

  Future<VerifyCodeResponseModel> call(VerifyCodeRequestModel request) async{
    return await repository.verifyCode(request);
  }
}