import 'package:deadbounce_flutter_app/core/theme/app_theme.dart';
import 'package:deadbounce_flutter_app/core/widgets/db_button.dart';
import 'package:deadbounce_flutter_app/core/widgets/db_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('design system widgets render under the app theme',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Column(
            children: [
              const DbLogo(size: 64),
              DbPrimaryButton(label: 'PLAY', onPressed: () {}),
              DbSecondaryButton(label: 'GUEST', onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(DbLogo), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('GUEST'), findsOneWidget);
  });
}
