import 'package:be_with_me_new_new/features/helper/data/models/response/get_patients_response_model.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/patient_repository.dart';

class GetAllPatientsUseCase {
  final PatientRepository repository;

  GetAllPatientsUseCase(this.repository);

  Future<GetPatientsResponseModel> call({
    required String token,
    int page = 1,
    int pageSize = 5,
    bool status = false,
  }) async {
    return await repository.getAllPatients(
      token: token,
      page: page,
      pageSize: pageSize,
      status: status,
    );
  }
}
