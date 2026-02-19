import 'dart:developer' as developer;

class AppLogger {
  const AppLogger();

  void info(String message) {
    developer.log(message, name: 'equb.mobile.info');
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
