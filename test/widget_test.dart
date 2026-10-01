import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:operon/theme/operon_theme.dart';

void main() {
  testWidgets('OPERON Flutter shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OperonTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: Text('OPERON'),
          ),
        ),
      ),
    );

    expect(find.text('OPERON'), findsOneWidget);
  });
}
