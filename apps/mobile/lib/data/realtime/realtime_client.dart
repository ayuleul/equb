import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../shared/utils/app_logger.dart';
import '../auth/token_store.dart';
import 'realtime_event.dart';

class RealtimeClient {
  RealtimeClient({
    required this.apiBaseUrl,
    required TokenStore tokenStore,
    required AppLogger logger,
  }) : _tokenStore = tokenStore,
       _logger = logger;

  static const _serverEvents = <String>[
    'member.updated',
    'turn.started',
    'turn.updated',
    'winner.selected',
    'contribution.updated',
    'payout.updated',
    'dispute.updated',
    'turn.completed',
  ];

  final String apiBaseUrl;
  final TokenStore _tokenStore;
  final AppLogger _logger;
  final StreamController<RealtimeEvent> _eventsController =
      StreamController<RealtimeEvent>.broadcast();
  final Map<String, int> _groupRoomRefs = <String, int>{};
  final Map<String, int> _turnRoomRefs = <String, int>{};
  final Map<String, String> _turnGroupIds = <String, String>{};

  io.Socket? _socket;
  bool _hasConnectedOnce = false;

  Stream<RealtimeEvent> get events => _eventsController.stream;
  Iterable<String> get activeGroupIds => _groupRoomRefs.keys;
  Iterable<String> get activeTurnIds => _turnRoomRefs.keys;
  String? groupIdForTurn(String turnId) => _turnGroupIds[turnId];

  Future<void> connect() async {
    final accessToken = await _tokenStore.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    if (_socket?.connected ?? false) {
      return;
    }

    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }

    final socketUri = Uri.parse(apiBaseUrl);
    final endpoint = socketUri.replace(path: '', query: null, fragment: null);
    final socketPath = _buildSocketPath(socketUri);

    final socket = io.io(
      endpoint.toString(),
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setAuth(<String, dynamic>{'token': accessToken})
          .setPath(socketPath)
          .build(),
    );

    _bindSocket(socket);
    _socket = socket;
    socket.connect();
  }

  void disconnect() {
    _hasConnectedOnce = false;
    final socket = _socket;
    _socket = null;
    if (socket == null) {
      return;
    }

    socket.disconnect();
    socket.dispose();
  }

  void dispose() {
    disconnect();
    _eventsController.close();
  }

  void joinGroup(String groupId) {
    _groupRoomRefs[groupId] = (_groupRoomRefs[groupId] ?? 0) + 1;
    _emitIfConnected('join_group_room', <String, dynamic>{'groupId': groupId});
  }

  void leaveGroup(String groupId) {
    final nextCount = (_groupRoomRefs[groupId] ?? 0) - 1;
    if (nextCount <= 0) {
      _groupRoomRefs.remove(groupId);
      _emitIfConnected('leave_group_room', <String, dynamic>{
        'groupId': groupId,
      });
      return;
    }

    _groupRoomRefs[groupId] = nextCount;
  }

  void joinTurn(String turnId, {String? groupId}) {
    _turnRoomRefs[turnId] = (_turnRoomRefs[turnId] ?? 0) + 1;
    if (groupId != null && groupId.isNotEmpty) {
      _turnGroupIds[turnId] = groupId;
    }
    _emitIfConnected('join_turn_room', <String, dynamic>{'turnId': turnId});
  }

  void leaveTurn(String turnId) {
    final nextCount = (_turnRoomRefs[turnId] ?? 0) - 1;
    if (nextCount <= 0) {
      _turnRoomRefs.remove(turnId);
      _turnGroupIds.remove(turnId);
      _emitIfConnected('leave_turn_room', <String, dynamic>{'turnId': turnId});
      return;
    }

    _turnRoomRefs[turnId] = nextCount;
  }

  void _bindSocket(io.Socket socket) {
    socket.onConnect((_) {
      final wasConnectedBefore = _hasConnectedOnce;
      _hasConnectedOnce = true;
      _logger.info('Realtime socket connected.');
      _rejoinRooms();

      if (wasConnectedBefore && !_eventsController.isClosed) {
        _eventsController.add(RealtimeEvent.reconnected());
      }
    });

    socket.onDisconnect((reason) {
      _logger.info('Realtime socket disconnected: $reason');
    });

    socket.onConnectError((error) {
      _logger.error('Realtime socket connect error.', error: error);
    });

    for (final eventName in _serverEvents) {
      socket.on(eventName, (payload) {
        if (_eventsController.isClosed) {
          return;
        }
        _eventsController.add(RealtimeEvent.fromPayload(eventName, payload));
      });
    }
  }

  void _emitIfConnected(String eventName, Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      return;
    }

    socket.emit(eventName, payload);
  }

  void _rejoinRooms() {
    for (final groupId in _groupRoomRefs.keys) {
      _emitIfConnected('join_group_room', <String, dynamic>{
        'groupId': groupId,
      });
    }

    for (final turnId in _turnRoomRefs.keys) {
      _emitIfConnected('join_turn_room', <String, dynamic>{'turnId': turnId});
    }
  }

  String _buildSocketPath(Uri apiUri) {
    final path = apiUri.path.trim();
    if (path.isEmpty || path == '/') {
      return '/socket.io';
    }

    final normalized = path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
    return '$normalized/socket.io';
  }
}
