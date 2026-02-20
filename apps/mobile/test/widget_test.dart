import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/bootstrap.dart';
import 'package:mobile/data/auth/token_store.dart';

void main() {
  testWidgets('routes unauthenticated users to phone login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appBootstrapConfigProvider.overrideWithValue(
            const AppBootstrapConfig(
              apiBaseUrl: 'http://localhost:3000',
              apiTimeoutMs: 15000,
            ),
          ),
          tokenStoreProvider.overrideWithValue(
            TokenStore(_InMemorySecureStore()),
          ),
        ],
        child: const EqubApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Login with your phone'), findsOneWidget);
  });
}

class _InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}
