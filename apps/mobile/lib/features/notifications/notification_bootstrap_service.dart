import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../shared/utils/app_logger.dart';

typedef NotificationForegroundCallback =
    void Function({required String title, required String body});
typedef NotificationPayloadCallback = void Function(Map<String, dynamic> data);
typedef NotificationTokenCallback = FutureOr<void> Function(String token);

abstract class NotificationBootstrap {
  Future<void> initialize({
    required NotificationForegroundCallback onForegroundNotification,
    required NotificationPayloadCallback onPayloadOpened,
    NotificationTokenCallback? onTokenRefresh,
  });

  Future<String?> getDeviceToken();

  void simulatePayloadTap(Map<String, dynamic> payload);

  void dispose();
}

final notificationBootstrapProvider = Provider<NotificationBootstrap>((ref) {
  final logger = ref.watch(appLoggerProvider);
  final service = NotificationBootstrapService(logger: logger);
  ref.onDispose(service.dispose);
  return service;
});

class NotificationBootstrapService implements NotificationBootstrap {
  NotificationBootstrapService({
    required AppLogger logger,
    FirebaseMessaging? messaging,
  }) : _logger = logger,
       _messaging = messaging ?? FirebaseMessaging.instance;

  final AppLogger _logger;
  final FirebaseMessaging _messaging;

  bool _firebaseChecked = false;
  bool _firebaseAvailable = false;
  bool _initialized = false;

  NotificationForegroundCallback? _onForegroundNotification;
  NotificationPayloadCallback? _onPayloadOpened;
  NotificationTokenCallback? _onTokenRefresh;

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onOpenedSubscription;
  StreamSubscription<String>? _onTokenRefreshSubscription;

  @override
  Future<void> initialize({
    required NotificationForegroundCallback onForegroundNotification,
    required NotificationPayloadCallback onPayloadOpened,
    NotificationTokenCallback? onTokenRefresh,
  }) async {
    _onForegroundNotification = onForegroundNotification;
    _onPayloadOpened = onPayloadOpened;
    _onTokenRefresh = onTokenRefresh;

    if (_initialized) {
      return;
    }

    final available = await _ensureFirebaseAvailable();
    if (!available) {
      return;
    }

    try {
      await _messaging.requestPermission();
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Unable to configure notification permission/presentation.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    _onMessageSubscription = FirebaseMessaging.onMessage.listen((message) {
      final title =
          _normalizeText(message.notification?.title) ??
          _normalizeText(message.data['title']) ??
          'Notification';
      final body =
          _normalizeText(message.notification?.body) ??
          _normalizeText(message.data['body']) ??
          '';
      _onForegroundNotification?.call(title: title, body: body);
    });

    _onOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      _onPayloadOpened?.call(_payloadFromMessage(message));
    });

    _onTokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
      final normalized = token.trim();
      if (normalized.isEmpty) {
        return;
      }

      final callback = _onTokenRefresh;
      if (callback != null) {
        Future<void>.microtask(() => callback(normalized));
      }
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Future<void>.microtask(
        () => _onPayloadOpened?.call(_payloadFromMessage(initialMessage)),
      );
    }

    _initialized = true;
  }

  @override
  Future<String?> getDeviceToken() async {
    final available = await _ensureFirebaseAvailable();
    if (!available) {
      return null;
    }

    try {
      final token = await _messaging.getToken();
      final normalized = token?.trim();
      if (normalized == null || normalized.isEmpty) {
        return null;
      }

      return normalized;
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to fetch device push token.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  void simulatePayloadTap(Map<String, dynamic> payload) {
    _onPayloadOpened?.call(payload);
  }

  Future<bool> _ensureFirebaseAvailable() async {
    if (_firebaseChecked) {
      return _firebaseAvailable;
    }

    _firebaseChecked = true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firebaseAvailable = true;
    } catch (error, stackTrace) {
      _firebaseAvailable = false;
      _logger.info(
        'Firebase Messaging unavailable. Push remains disabled; in-app notifications still work.',
      );
      _logger.error(
        'Firebase initialization failed.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return _firebaseAvailable;
  }

  Map<String, dynamic> _payloadFromMessage(RemoteMessage message) {
    return message.data.map((key, value) => MapEntry(key, value));
  }

  String? _normalizeText(Object? value) {
    if (value is! String) {
      return null;
    }

    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  @override
  void dispose() {
    _onMessageSubscription?.cancel();
    _onOpenedSubscription?.cancel();
    _onTokenRefreshSubscription?.cancel();
  }
}
