import '../api/api_client.dart';

abstract class BidsApi {
  Future<Map<String, dynamic>> submitBid(String cycleId, int amount);
  Future<List<Map<String, dynamic>>> listBids(String cycleId);
}

class DioBidsApi implements BidsApi {
  DioBidsApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> submitBid(String cycleId, int amount) {
    return _apiClient.postMap(
      '/cycles/$cycleId/bids',
      data: <String, dynamic>{'amount': amount},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> listBids(String cycleId) async {
    final payload = await _apiClient.getList('/cycles/$cycleId/bids');
    return payload
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        })
        .toList(growable: false);
  }
}
