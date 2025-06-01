import 'package:be_with_me_new_new/features/helper/data/helper%20data%20source/calls_data_source.dart';
import 'package:be_with_me_new_new/features/helper/data/models/requests/call_init_model_request.dart';
import 'package:be_with_me_new_new/features/helper/data/models/response/call_init_response_model.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/calls_repository.dart';

class IntiCallUsecase {
  CallsRepository callsRepository;

  IntiCallUsecase({required this.callsRepository});

  Future<CallInitResponseModel> call(
      String token, CallInitRequestModel callInitRequestModel) async {
    return await callsRepository.initCall(token, callInitRequestModel);
  }
}
