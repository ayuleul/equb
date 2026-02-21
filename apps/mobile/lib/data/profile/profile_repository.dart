import '../models/user_model.dart';
import 'profile_api.dart';

class ProfileRepository {
  ProfileRepository(this._profileApi);

  final ProfileApi _profileApi;

  Future<UserModel> getMe() async {
    final payload = await _profileApi.getMe();
    return UserModel.fromJson(payload);
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String middleName,
    required String lastName,
  }) async {
    final payload = await _profileApi.updateProfile(
      firstName: _normalize(firstName),
      middleName: _normalize(middleName),
      lastName: _normalize(lastName),
    );
    return UserModel.fromJson(payload);
  }

  String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
