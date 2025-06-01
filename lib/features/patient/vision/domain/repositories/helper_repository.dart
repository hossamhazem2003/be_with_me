import '../../data/models/response/get_helpers_response_model.dart';

abstract class HelperRepository {
  Future<List<Helper>> getHelperResponse(String token);
}