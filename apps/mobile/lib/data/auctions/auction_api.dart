import '../api/api_client.dart';

abstract class AuctionApi {
  Future<Map<String, dynamic>> openAuction(String cycleId);
  Future<Map<String, dynamic>> closeAuction(String cycleId);
}

class DioAuctionApi implements AuctionApi {
  DioAuctionApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> openAuction(String cycleId) {
    return _apiClient.postMap('/cycles/$cycleId/auction/open');
  }

  @override
  Future<Map<String, dynamic>> closeAuction(String cycleId) {
    return _apiClient.postMap('/cycles/$cycleId/auction/close');
  }
}
