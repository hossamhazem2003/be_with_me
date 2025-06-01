import '../entites/helper_entity.dart';

abstract class ProfileRepository {
  Future<HelperEntity> getProfile({required String token});
  Future<void> updateProfile({
    required String token,
    required String fullName,
    required String gender,
    required String languagePreference,
    required String profileImage,
  });
}
