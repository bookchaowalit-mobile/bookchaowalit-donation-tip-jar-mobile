import 'package:donation_tip_jar/main.dart';
import 'package:donation_tip_jar/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell shows tip jar and about tab', (tester) async {
    await tester.pumpWidget(const DonationTipJarApp());
    expect(find.text('Donation Tip Jar'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('presets, custom percent and split update totals', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    String text(String key) => tester.widget<Text>(find.byKey(Key(key))).data!;
    expect(text('total'), 'Total: 57.50');

    await tester.tap(find.text('20%'));
    await tester.pump();
    expect(text('total'), 'Total: 60.00');

    await tester.enterText(find.byKey(const Key('custom-input')), '10');
    await tester.pump();
    expect(text('total'), 'Total: 55.00');

    await tester.tap(find.byTooltip('More people'));
    await tester.pump();
    expect(text('share'), 'Each pays 27.50');

    await tester.enterText(find.byKey(const Key('bill-input')), 'abc');
    await tester.pump();
    expect(find.text('Enter an amount like 42.50'), findsOneWidget);
  });
}
