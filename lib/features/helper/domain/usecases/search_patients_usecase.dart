import 'package:be_with_me_new_new/features/helper/data/models/response/get_patients_response_model.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/patient_repository.dart';

class SearchPatientsUseCase {
  final PatientRepository repository;

  SearchPatientsUseCase(this.repository);

  Future<GetPatientsResponseModel> call({
    required String token,
    required String search,
    int page = 1,
    int pageSize = 5,
    bool status = false,
  }) async {
    return await repository.searchPatients(
      token: token,
      search: search,
      page: page,
      pageSize: pageSize,
      status: status,
    );
  }
}
