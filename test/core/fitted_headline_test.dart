import 'package:deadbounce_flutter_app/core/theme/app_theme.dart';
import 'package:deadbounce_flutter_app/core/widgets/fitted_headline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FittedHeadline keeps the wordmark on one line without '
      'overflow on a very narrow screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(200, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              child: Builder(
                builder: (context) => FittedHeadline(
                  'DEADBOUNCE',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Renders, stays a single Text, and overflow (which throws in tests)
    // never fires.
    expect(find.text('DEADBOUNCE'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final textWidget = tester.widget<Text>(find.text('DEADBOUNCE'));
    expect(textWidget.maxLines, 1);
  });
}
