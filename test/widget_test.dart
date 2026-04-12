import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/main.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KontaApp()));

    expect(find.text('Konta'), findsOneWidget);
    expect(find.text('Comptabilité Marocaine'), findsOneWidget);
  });
}
