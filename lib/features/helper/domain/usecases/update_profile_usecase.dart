import 'package:be_with_me_new_new/features/helper/data/helper%20data%20source/profile_data_source.dart';
import 'package:be_with_me_new_new/features/helper/domain/repositories/profile_repository.dart';

class UpdateProfileUsecase {
  final ProfileRepository profileRepository = ProfileDataSource();

  Future<void> call(
      {required String token,
      required String fullName,
      required String gender,
      required String languagePreference,
      required String profileImage}) async {
    return await profileRepository.updateProfile(
        token: token,
        fullName: fullName,
        gender: gender,
        languagePreference: languagePreference,
        profileImage: profileImage);
  }
}
