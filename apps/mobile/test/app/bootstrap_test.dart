import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/bootstrap.dart';

void main() {
  group('AppBootstrapConfig.fromMap', () {
    test('parses required environment values', () {
      final config = AppBootstrapConfig.fromMap({
        'API_BASE_URL': 'http://localhost:3000',
        'API_TIMEOUT_MS': '15000',
      });

      expect(config.apiBaseUrl, 'http://localhost:3000');
      expect(config.apiTimeoutMs, 15000);
    });

    test('throws when API_BASE_URL is missing', () {
      expect(
        () => AppBootstrapConfig.fromMap({'API_TIMEOUT_MS': '15000'}),
        throwsA(isA<StateError>()),
      );
    });
  });
}
