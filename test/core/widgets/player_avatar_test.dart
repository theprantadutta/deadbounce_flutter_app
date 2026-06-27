import 'package:deadbounce_flutter_app/core/widgets/player_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('falls back to a person icon when there is no photo',
      (tester) async {
    await tester.pumpWidget(host(const PlayerAvatar(photoUrl: null)));
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('an empty url also falls back to the icon', (tester) async {
    await tester.pumpWidget(host(const PlayerAvatar(photoUrl: '')));
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('renders a network Image when a photo url is present',
      (tester) async {
    await tester.pumpWidget(
      host(const PlayerAvatar(photoUrl: 'https://example.com/a.png')),
    );
    expect(find.byType(Image), findsOneWidget);
  });
}
