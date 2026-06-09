// Basic smoke test：确保 App 能正常构建并完成首帧。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:likenovel/app/app.dart';

void main() {
  testWidgets('likenovel app boots without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: likenovelApp()),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
