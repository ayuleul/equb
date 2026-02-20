import '../api/api_client.dart';
import '../models/reject_contribution_request.dart';
import '../models/submit_contribution_request.dart';

abstract class ContributionsApi {
  Future<Map<String, dynamic>> listCycleContributions(
    String groupId,
    String cycleId,
  );

  Future<Map<String, dynamic>> submitContribution(
    String cycleId,
    SubmitContributionRequest request,
  );

  Future<Map<String, dynamic>> confirmContribution(
    String contributionId, {
    String? note,
  });

  Future<Map<String, dynamic>> rejectContribution(
    String contributionId,
    RejectContributionRequest request,
  );
}

class DioContributionsApi implements ContributionsApi {
  DioContributionsApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> listCycleContributions(
    String groupId,
    String cycleId,
  ) {
    return _apiClient.getMap('/groups/$groupId/cycles/$cycleId/contributions');
  }

  @override
  Future<Map<String, dynamic>> submitContribution(
    String cycleId,
    SubmitContributionRequest request,
  ) {
    return _apiClient.postMap(
      '/cycles/$cycleId/contributions',
      data: request.toJson(),
    );
  }

  @override
  Future<Map<String, dynamic>> confirmContribution(
    String contributionId, {
    String? note,
  }) {
    return _apiClient.patchMap(
      '/contributions/$contributionId/confirm',
      data: note == null || note.trim().isEmpty
          ? <String, dynamic>{}
          : <String, dynamic>{'note': note.trim()},
    );
  }

  @override
  Future<Map<String, dynamic>> rejectContribution(
    String contributionId,
    RejectContributionRequest request,
  ) {
    return _apiClient.patchMap(
      '/contributions/$contributionId/reject',
      data: request.toJson(),
    );
  }
}
