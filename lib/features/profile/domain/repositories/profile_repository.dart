import '../entities/profile_data.dart';

abstract interface class ProfileRepository {
  Future<ProfileData> getProfile();
}
