import '../api/api_client.dart';

abstract class CyclesApi {
  Future<Map<String, dynamic>> startRound(String groupId);

  Future<List<Map<String, dynamic>>> setPayoutOrder(
    String groupId,
    List<Map<String, dynamic>> payload,
  );

  Future<Map<String, dynamic>> generateCycles(String groupId);

  Future<Map<String, dynamic>?> getCurrentCycle(String groupId);
  Future<List<Map<String, dynamic>>> listCycles(String groupId);
  Future<Map<String, dynamic>> getCycle(String groupId, String cycleId);
}

class DioCyclesApi implements CyclesApi {
  DioCyclesApi(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> startRound(String groupId) {
    return _apiClient.postMap('/groups/$groupId/rounds/start');
  }

  @override
  Future<List<Map<String, dynamic>>> setPayoutOrder(
    String groupId,
    List<Map<String, dynamic>> payload,
  ) async {
    final response = await _apiClient.patchList(
      '/groups/$groupId/payout-order',
      data: payload,
    );
    return response.map(_toMap).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> generateCycles(String groupId) async {
    final response = await _apiClient.postMap(
      '/groups/$groupId/rounds/current/draw-next',
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>?> getCurrentCycle(String groupId) async {
    final payload = await _apiClient.getObject(
      '/groups/$groupId/cycles/current',
    );

    if (payload == null) {
      return null;
    }

    return _toMap(payload);
  }

  @override
  Future<List<Map<String, dynamic>>> listCycles(String groupId) async {
    final payload = await _apiClient.getList('/groups/$groupId/cycles');
    return payload.map(_toMap).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> getCycle(String groupId, String cycleId) {
    return _apiClient.getMap('/groups/$groupId/cycles/$cycleId');
  }

  Map<String, dynamic> _toMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}
