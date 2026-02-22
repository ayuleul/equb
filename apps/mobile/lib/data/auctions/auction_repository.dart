import '../models/cycle_auction_state_model.dart';
import '../models/cycle_bid_model.dart';
import 'auction_api.dart';
import 'bids_api.dart';

class AuctionRepository {
  AuctionRepository({required AuctionApi auctionApi, required BidsApi bidsApi})
    : _auctionApi = auctionApi,
      _bidsApi = bidsApi;

  final AuctionApi _auctionApi;
  final BidsApi _bidsApi;

  Future<CycleAuctionStateModel> openAuction(String cycleId) async {
    final payload = await _auctionApi.openAuction(cycleId);
    return CycleAuctionStateModel.fromJson(payload);
  }

  Future<CycleAuctionStateModel> closeAuction(String cycleId) async {
    final payload = await _auctionApi.closeAuction(cycleId);
    return CycleAuctionStateModel.fromJson(payload);
  }

  Future<CycleBidModel> submitBid(String cycleId, int amount) async {
    final payload = await _bidsApi.submitBid(cycleId, amount);
    return CycleBidModel.fromJson(payload);
  }

  Future<List<CycleBidModel>> listBids(String cycleId) async {
    final payload = await _bidsApi.listBids(cycleId);
    return payload.map(CycleBidModel.fromJson).toList(growable: false);
  }
}
