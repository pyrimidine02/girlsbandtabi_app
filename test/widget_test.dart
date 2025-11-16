// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/widgets/flow_components.dart';

void main() {
  testWidgets('FlowCard renders provided content / FlowCard가 전달된 콘텐츠를 렌더링해야 함', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FlowCard(
          child: Text('GirlsBandTabi Place Detail'),
        ),
      ),
    );

    expect(find.text('GirlsBandTabi Place Detail'), findsOneWidget);
  });
}
