import 'package:be_with_me_new_new/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/send_code_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/send_code_response_model.dart';
import 'package:be_with_me_new_new/features/auth/domain/repositories/auth_repository.dart';

class SendCodeUsecase {
  AuthRepository repository = AuthRemoteDataSource();

  Future<SendCodeResponseModel> call(SendCodeRequestModel request) async{
    return await repository.sendCode(request);
  }
}