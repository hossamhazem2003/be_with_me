abstract class ProfileEvent {}

class GetProfileDataEvent extends ProfileEvent {
  GetProfileDataEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String fullName;
  final String gender;
  final String languagePreference;
  final String profileImage;
  UpdateProfileEvent({
    required this.fullName,
    required this.gender,
    required this.languagePreference,
    required this.profileImage,
  });
}
