import '../models/cycle_model.dart';
import 'cycles_api.dart';

class CyclesRepository {
  CyclesRepository(this._cyclesApi);

  final CyclesApi _cyclesApi;

  final Map<String, CycleModel?> _currentCycleCache = <String, CycleModel?>{};
  final Map<String, List<CycleModel>> _cyclesListCache =
      <String, List<CycleModel>>{};
  final Map<String, CycleModel> _cycleDetailCache = <String, CycleModel>{};
  final Map<String, Future<CycleModel?>> _pendingCurrentCycleRequests =
      <String, Future<CycleModel?>>{};
  final Map<String, Future<List<CycleModel>>> _pendingCyclesListRequests =
      <String, Future<List<CycleModel>>>{};
  final Map<String, Future<CycleModel>> _pendingCycleDetailRequests =
      <String, Future<CycleModel>>{};

  Future<CycleModel?> getCurrentCycle(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _currentCycleCache.containsKey(groupId)) {
      return _currentCycleCache[groupId];
    }

    if (!forceRefresh) {
      final pending = _pendingCurrentCycleRequests[groupId];
      if (pending != null) {
        return pending;
      }
    }

    final request = _loadCurrentCycle(groupId);
    _pendingCurrentCycleRequests[groupId] = request;
    try {
      return await request;
    } finally {
      _pendingCurrentCycleRequests.remove(groupId);
    }
  }

  Future<List<CycleModel>> listCycles(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    final cached = _cyclesListCache[groupId];
    if (!forceRefresh && cached != null) {
      return cached;
    }

    if (!forceRefresh) {
      final pending = _pendingCyclesListRequests[groupId];
      if (pending != null) {
        return pending;
      }
    }

    final request = _loadCycles(groupId);
    _pendingCyclesListRequests[groupId] = request;
    try {
      return await request;
    } finally {
      _pendingCyclesListRequests.remove(groupId);
    }
  }

  Future<CycleModel> getCycle(
    String groupId,
    String cycleId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = _detailCacheKey(groupId, cycleId);
    final cached = _cycleDetailCache[cacheKey];
    if (!forceRefresh && cached != null) {
      return cached;
    }

    if (!forceRefresh) {
      final pending = _pendingCycleDetailRequests[cacheKey];
      if (pending != null) {
        return pending;
      }
    }

    final request = _loadCycle(groupId, cycleId);
    _pendingCycleDetailRequests[cacheKey] = request;
    try {
      return await request;
    } finally {
      _pendingCycleDetailRequests.remove(cacheKey);
    }
  }

  Future<CycleModel> startCycle(String groupId) async {
    final payload = await _cyclesApi.startCycle(groupId);
    final cycle = CycleModel.fromJson(payload);

    invalidateGroupCache(groupId);

    _cycleDetailCache[_detailCacheKey(groupId, cycle.id)] = cycle;

    return cycle;
  }

  void invalidateGroupCache(String groupId) {
    _currentCycleCache.remove(groupId);
    _cyclesListCache.remove(groupId);
    _pendingCurrentCycleRequests.remove(groupId);
    _pendingCyclesListRequests.remove(groupId);
    _cycleDetailCache.removeWhere((key, _) => key.startsWith('$groupId:'));
    _pendingCycleDetailRequests.removeWhere(
      (key, _) => key.startsWith('$groupId:'),
    );
  }

  void invalidateCycleDetail(String groupId, String cycleId) {
    final cacheKey = _detailCacheKey(groupId, cycleId);
    _cycleDetailCache.remove(cacheKey);
    _pendingCycleDetailRequests.remove(cacheKey);
  }

  Future<CycleModel?> _loadCurrentCycle(String groupId) async {
    final payload = await _cyclesApi.getCurrentCycle(groupId);
    if (payload == null || payload.isEmpty) {
      _currentCycleCache[groupId] = null;
      return null;
    }

    final cycle = CycleModel.fromJson(payload);
    _currentCycleCache[groupId] = cycle;
    _cycleDetailCache[_detailCacheKey(groupId, cycle.id)] = cycle;
    return cycle;
  }

  Future<List<CycleModel>> _loadCycles(String groupId) async {
    final payload = await _cyclesApi.listCycles(groupId);
    final cycles = payload.map(CycleModel.fromJson).toList(growable: false);

    _cyclesListCache[groupId] = cycles;
    for (final cycle in cycles) {
      _cycleDetailCache[_detailCacheKey(groupId, cycle.id)] = cycle;
    }

    return cycles;
  }

  Future<CycleModel> _loadCycle(String groupId, String cycleId) async {
    final payload = await _cyclesApi.getCycle(groupId, cycleId);
    final cycle = CycleModel.fromJson(payload);
    _cycleDetailCache[_detailCacheKey(groupId, cycleId)] = cycle;
    return cycle;
  }

  String _detailCacheKey(String groupId, String cycleId) {
    return '$groupId:$cycleId';
  }
}
