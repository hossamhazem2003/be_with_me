import 'package:be_with_me_new_new/features/patient/vision/data/datasource/helper_data_source.dart';
import 'package:be_with_me_new_new/features/patient/vision/data/models/response/get_helpers_response_model.dart';
import 'package:be_with_me_new_new/features/patient/vision/domain/repositories/helper_repository.dart';

class GetHelpersUseCase{
  HelperRepository helperRepository = HelperDataSource();
  
  Future<List<Helper>> call(String token)async{
    return await helperRepository.getHelperResponse(token);
  }
}