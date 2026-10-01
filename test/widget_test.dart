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

  Widget home({double textScale = 1}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const HomeScreen(),
        ),
      );

  testWidgets('invalid custom percent hides the result', (tester) async {
    await tester.pumpWidget(home());
    for (final bad in ['101', '0x10', '12.5']) {
      await tester.enterText(find.byKey(const Key('custom-input')), bad);
      await tester.pump();
      expect(find.text('Use 0 to 100'), findsOneWidget, reason: bad);
      expect(find.byKey(const Key('result')), findsNothing, reason: bad);
    }
    await tester.enterText(find.byKey(const Key('custom-input')), '');
    await tester.pump();
    expect(find.byKey(const Key('result')), findsOneWidget);
  });

  testWidgets('ambiguous comma amounts are rejected', (tester) async {
    await tester.pumpWidget(home());
    await tester.enterText(find.byKey(const Key('bill-input')), '12,50');
    await tester.pump();
    expect(find.text('Enter an amount like 42.50'), findsOneWidget);
    expect(find.byKey(const Key('result')), findsNothing);
  });

  testWidgets('round-up switch reports the extra amount', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(home());
    await tester.enterText(find.byKey(const Key('bill-input')), '100');
    await tester.enterText(find.byKey(const Key('custom-input')), '0');
    await tester.tap(find.byTooltip('More people'));
    await tester.tap(find.byTooltip('More people'));
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.text('Each pays 34.00'), findsOneWidget);
    expect(find.text('Rounding adds 2.00 extra'), findsOneWidget);
  });

  testWidgets('fewer-people button is disabled at one person', (tester) async {
    await tester.pumpWidget(home());
    final fewer = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.remove),
    );
    expect(fewer.onPressed, isNull);
  });

  testWidgets('meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('lays out at 200% text scale on a phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(home(textScale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
