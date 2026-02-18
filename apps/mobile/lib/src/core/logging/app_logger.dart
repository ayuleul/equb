import 'dart:developer' as developer;

class AppLogger {
  const AppLogger();

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'equb.mobile.info',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'equb.mobile.warning',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'equb.mobile.error',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
