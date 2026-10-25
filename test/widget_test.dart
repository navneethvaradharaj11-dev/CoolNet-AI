import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coolnet/main.dart';

void main() {
  testWidgets('CoolNet AI dashboard smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(const CoolNetApp());
    await tester.pump();

    // Verify that our main title is displayed.
    expect(find.text('CoolNet AI'), findsOneWidget);
  });
}
