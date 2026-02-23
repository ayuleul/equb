import '../api/api_client.dart';
import '../models/create_contribution_dispute_request.dart';
import '../models/mediate_dispute_request.dart';
import '../models/reject_contribution_request.dart';
import '../models/resolve_dispute_request.dart';
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
  Future<Map<String, dynamic>> verifyContribution(
    String contributionId, {
    String? note,
  });

  Future<Map<String, dynamic>> evaluateCycleCollection(String cycleId);

  Future<List<Map<String, dynamic>>> listContributionDisputes(
    String contributionId,
  );

  Future<Map<String, dynamic>> createContributionDispute(
    String contributionId,
    CreateContributionDisputeRequest request,
  );

  Future<Map<String, dynamic>> mediateDispute(
    String disputeId,
    MediateDisputeRequest request,
  );

  Future<Map<String, dynamic>> resolveDispute(
    String disputeId,
    ResolveDisputeRequest request,
  );

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
      '/cycles/$cycleId/contributions/submit',
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
  Future<Map<String, dynamic>> verifyContribution(
    String contributionId, {
    String? note,
  }) {
    return _apiClient.postMap(
      '/contributions/$contributionId/verify',
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

  @override
  Future<Map<String, dynamic>> evaluateCycleCollection(String cycleId) {
    return _apiClient.postMap('/cycles/$cycleId/evaluate');
  }

  @override
  Future<List<Map<String, dynamic>>> listContributionDisputes(
    String contributionId,
  ) {
    return _apiClient
        .getList('/contributions/$contributionId/disputes')
        .then((items) => items.cast<Map<String, dynamic>>());
  }

  @override
  Future<Map<String, dynamic>> createContributionDispute(
    String contributionId,
    CreateContributionDisputeRequest request,
  ) {
    return _apiClient.postMap(
      '/contributions/$contributionId/disputes',
      data: request.toJson(),
    );
  }

  @override
  Future<Map<String, dynamic>> mediateDispute(
    String disputeId,
    MediateDisputeRequest request,
  ) {
    return _apiClient.postMap(
      '/disputes/$disputeId/mediate',
      data: request.toJson(),
    );
  }

  @override
  Future<Map<String, dynamic>> resolveDispute(
    String disputeId,
    ResolveDisputeRequest request,
  ) {
    return _apiClient.postMap(
      '/disputes/$disputeId/resolve',
      data: request.toJson(),
    );
  }
}
