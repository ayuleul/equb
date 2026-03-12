import '../models/reputation_model.dart';
import '../models/user_model.dart';
import 'profile_api.dart';

class ProfileRepository {
  ProfileRepository(this._profileApi);

  final ProfileApi _profileApi;

  Future<UserModel> getMe() async {
    final payload = await _profileApi.getMe();
    return UserModel.fromJson(payload);
  }

  Future<ReputationProfileModel> getReputation(String userId) async {
    final payload = await _profileApi.getReputation(userId);
    return ReputationProfileModel.fromJson(payload);
  }

  Future<ReputationHistoryPageModel> getReputationHistory(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    final payload = await _profileApi.getReputationHistory(
      userId,
      page: page,
      limit: limit,
    );
    return ReputationHistoryPageModel.fromJson(payload);
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String middleName,
    String? lastName,
  }) async {
    final payload = await _profileApi.updateProfile(
      firstName: _normalize(firstName),
      middleName: _normalize(middleName),
      lastName: _normalizeOptional(lastName),
    );
    return UserModel.fromJson(payload);
  }

  String _normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _normalizeOptional(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return _normalize(trimmed);
  }
}
