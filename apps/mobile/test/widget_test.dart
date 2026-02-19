import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/bootstrap.dart';
import 'package:mobile/app/router.dart';

void main() {
  testWidgets('routes unauthenticated users to login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appBootstrapConfigProvider.overrideWithValue(
            const AppBootstrapConfig(
              apiBaseUrl: 'http://localhost:3000',
              apiTimeoutMs: 15000,
            ),
          ),
          authBootstrapProvider.overrideWith((ref) async => false),
        ],
        child: const EqubApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(
      find.text('OTP login will be implemented in Phase 1.'),
      findsOneWidget,
    );
  });
}
