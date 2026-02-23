import '../models/contribution_model.dart';
import '../models/reject_contribution_request.dart';
import '../models/submit_contribution_request.dart';
import 'contributions_api.dart';

class ContributionsRepository {
  ContributionsRepository(this._api);

  final ContributionsApi _api;

  Future<ContributionListModel> listCycleContributions(
    String groupId,
    String cycleId,
  ) async {
    final payload = await _api.listCycleContributions(groupId, cycleId);
    return ContributionListModel.fromJson(payload);
  }

  Future<ContributionModel> submitContribution(
    String cycleId,
    SubmitContributionRequest request,
  ) async {
    final payload = await _api.submitContribution(cycleId, request);
    return ContributionModel.fromJson(payload);
  }

  Future<ContributionModel> confirmContribution(
    String contributionId, {
    String? note,
  }) async {
    final payload = await _api.verifyContribution(contributionId, note: note);
    return ContributionModel.fromJson(payload);
  }

  Future<ContributionModel> rejectContribution(
    String contributionId,
    String reason,
  ) async {
    final payload = await _api.rejectContribution(
      contributionId,
      RejectContributionRequest(reason: reason.trim()),
    );
    return ContributionModel.fromJson(payload);
  }
}
