import 'package:be_with_me_new_new/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/login_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/login_response_model.dart';
import 'package:be_with_me_new_new/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository = AuthRemoteDataSource();

  Future<LoginResponseModel> call(LoginRequestModel request) async{
    return await repository.login(request);
  }
}