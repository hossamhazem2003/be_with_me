import 'package:be_with_me_new_new/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:be_with_me_new_new/features/auth/data/models/request/register_request_model.dart';
import 'package:be_with_me_new_new/features/auth/data/models/response/register_response_model.dart';
import 'package:be_with_me_new_new/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository = AuthRemoteDataSource();

  Future<RegisterResponseModel> call(RegisterRequestModel request) async {
    return await repository.register(request);
  }
} 