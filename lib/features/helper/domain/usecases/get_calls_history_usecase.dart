import 'package:be_with_me_new_new/features/helper/domain/repositories/calls_repository.dart';

import '../../data/models/response/get_calls_history_response_model.dart';

class GetCallsHistoryUseCase {
  CallsRepository callsRepository;

  GetCallsHistoryUseCase({required this.callsRepository});

  Future<List<GetCallHistoryResponseModel>> call(
      String token, String userId) async {
    return await callsRepository.getCallsHistory(token, userId);
  }
}
