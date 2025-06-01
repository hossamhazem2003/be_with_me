import 'package:be_with_me_new_new/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/reset_password_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/reset_password_response_model.dart';
import 'package:be_with_me_new_new/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUsecase {
  AuthRepository repository = AuthRemoteDataSource();

  Future<ResetPasswordResponseModel> call(ResetPasswordRequestModel request) async{
    return await repository.resetPassword(request);
  }
}