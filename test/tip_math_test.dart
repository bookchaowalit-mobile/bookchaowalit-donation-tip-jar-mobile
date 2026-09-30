import 'package:donation_tip_jar/logic/tip_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseAmountCents', () {
    expect(parseAmountCents('12'), 1200);
    expect(parseAmountCents('12.5'), 1250);
    expect(parseAmountCents('1,234.56'), 123456);
    expect(parseAmountCents(' 0.07 '), 7);
    expect(parseAmountCents('12.'), 1200);
    for (final bad in ['', '-1', '1.234', 'abc', '1e3']) {
      expect(parseAmountCents(bad), isNull, reason: bad);
    }
  });

  test('tip rounds half up to the cent', () {
    final r = computeTip(billCents: 1050, tipPercent: 15); // 157.5 -> 158
    expect(r.tipCents, 158);
    expect(r.totalCents, 1208);
    expect(r.shares, [1208]);
  });

  test('exact split distributes leftover cents', () {
    final r = computeTip(billCents: 1000, tipPercent: 0, people: 3);
    expect(r.shares, [334, 333, 333]);
    expect(r.collectedCents, r.totalCents);
    expect(r.extraFromRoundingCents, 0);
  });

  test('round-up split covers the total', () {
    final r = computeTip(
      billCents: 5000,
      tipPercent: 18,
      people: 3,
      roundUpTo: 100,
    );
    expect(r.totalCents, 5900);
    expect(r.shares, [2000, 2000, 2000]);
    expect(r.extraFromRoundingCents, 100);
  });

  test('invalid arguments throw', () {
    expect(
        () => computeTip(billCents: -1, tipPercent: 10), throwsArgumentError);
    expect(
        () => computeTip(billCents: 1, tipPercent: 101), throwsArgumentError);
    expect(
      () => computeTip(billCents: 1, tipPercent: 10, people: 0),
      throwsArgumentError,
    );
  });

  test('formatCents', () {
    expect(formatCents(5), '0.05');
    expect(formatCents(123456), '1234.56');
  });
}
