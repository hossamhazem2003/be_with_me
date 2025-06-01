
import '../../../domain/entites/helper_entity.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class GetProfileSuccess extends ProfileState {
  final HelperEntity profile;
  const GetProfileSuccess({required this.profile});
}

class UpdateProfileLoading extends ProfileState {
  final HelperEntity currentProfile;
  const UpdateProfileLoading({required this.currentProfile});
}

class UpdateProfileSuccess extends ProfileState {
  final HelperEntity profile;
  final String fullName;
  final String gender;
  final String languagePreference;
  final String profileImage;

  const UpdateProfileSuccess({
    required this.profile,
    required this.fullName,
    required this.gender,
    required this.languagePreference,
    required this.profileImage,
  });
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});
}