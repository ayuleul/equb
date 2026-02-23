import '../models/contribution_dispute_model.dart';
import '../models/contribution_model.dart';
import '../models/create_contribution_dispute_request.dart';
import '../models/cycle_collection_evaluation_model.dart';
import '../models/mediate_dispute_request.dart';
import '../models/reject_contribution_request.dart';
import '../models/resolve_dispute_request.dart';
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

  Future<CycleCollectionEvaluationModel> evaluateCycleCollection(
    String cycleId,
  ) async {
    final payload = await _api.evaluateCycleCollection(cycleId);
    return CycleCollectionEvaluationModel.fromJson(payload);
  }

  Future<List<ContributionDisputeModel>> listContributionDisputes(
    String contributionId,
  ) async {
    final payload = await _api.listContributionDisputes(contributionId);
    return payload
        .map(ContributionDisputeModel.fromJson)
        .toList(growable: false);
  }

  Future<ContributionDisputeModel> createContributionDispute(
    String contributionId, {
    required String reason,
    String? note,
  }) async {
    final payload = await _api.createContributionDispute(
      contributionId,
      CreateContributionDisputeRequest(reason: reason.trim(), note: note),
    );
    return ContributionDisputeModel.fromJson(payload);
  }

  Future<ContributionDisputeModel> mediateDispute(
    String disputeId, {
    required String note,
  }) async {
    final payload = await _api.mediateDispute(
      disputeId,
      MediateDisputeRequest(note: note.trim()),
    );
    return ContributionDisputeModel.fromJson(payload);
  }

  Future<ContributionDisputeModel> resolveDispute(
    String disputeId, {
    required String outcome,
    String? note,
  }) async {
    final payload = await _api.resolveDispute(
      disputeId,
      ResolveDisputeRequest(outcome: outcome.trim(), note: note),
    );
    return ContributionDisputeModel.fromJson(payload);
  }
}
