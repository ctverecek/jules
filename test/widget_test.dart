import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NeoSnakeApp());

    // Verify that the title exists.
    expect(find.text('SNAKE'), findsOneWidget);

    // Verify that the start button exists.
    expect(find.text('START GAME'), findsOneWidget);
  });
}
