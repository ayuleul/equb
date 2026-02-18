import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/app.dart';

void main() {
  testWidgets('shows config guidance when API_BASE_URL is not provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: EqubApp()));

    expect(find.text('Equb Configuration'), findsOneWidget);
    expect(
      find.textContaining('API_BASE_URL is not configured'),
      findsOneWidget,
    );
  });
}
