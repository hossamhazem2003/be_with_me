import 'package:be_with_me_new_new/features/helper/data/helper%20data%20source/profile_data_source.dart';
import 'package:be_with_me_new_new/features/helper/domain/entites/helper_entity.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/profile_repository.dart';

class GetProfileDataUsecase {
  final ProfileRepository repository = ProfileDataSource();

  Future<HelperEntity> call({required String token}) async {
    return await repository.getProfile(token: token);
  }
}
