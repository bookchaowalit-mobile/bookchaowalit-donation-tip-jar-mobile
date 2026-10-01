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

  group('edge cases (pass 3)', () {
    test('commas are only thousands separators', () {
      expect(parseAmountCents('1,234,567.89'), 123456789);
      expect(parseAmountCents('999'), 99900);
      for (final bad in [
        '1,2',
        '12,50',
        ',123',
        '1,23,456',
        '1234,567',
        '1,'
      ]) {
        expect(parseAmountCents(bad), isNull, reason: bad);
      }
    });

    test('amount limits and near-misses', () {
      expect(parseAmountCents('0'), 0);
      expect(parseAmountCents('999999999.99'), 99999999999);
      for (final bad in ['1234567890', '.5', '+5', '0x10', '1 000', '١٢']) {
        expect(parseAmountCents(bad), isNull, reason: bad);
      }
    });

    test('parsePercent accepts 0-100 decimals only', () {
      expect(parsePercent(' 0 '), 0);
      expect(parsePercent('100'), 100);
      expect(parsePercent('007'), 7);
      for (final bad in ['', '101', '-1', '+5', '0x10', '12.5', '1e2']) {
        expect(parsePercent(bad), isNull, reason: bad);
      }
    });

    test('zero bill and zero tip', () {
      final r = computeTip(billCents: 0, tipPercent: 20, people: 3);
      expect(r.shares, [0, 0, 0]);
      expect(
          computeTip(billCents: 0, tipPercent: 0, roundUpTo: 100).shares, [0]);
    });

    test('split shares always sum to the total without rounding', () {
      for (var bill = 0; bill < 400; bill += 37) {
        for (var people = 1; people <= 7; people++) {
          final r = computeTip(billCents: bill, tipPercent: 15, people: people);
          expect(r.collectedCents, r.totalCents, reason: '$bill/$people');
          expect(
              r.shares.reduce((a, b) => a > b ? a : b) -
                  r.shares.reduce((a, b) => a < b ? a : b),
              lessThanOrEqualTo(1));
        }
      }
    });

    test('round-up never collects less and adds under one unit per person', () {
      final r = computeTip(
          billCents: 10001, tipPercent: 0, people: 3, roundUpTo: 100);
      expect(r.shares, [3400, 3400, 3400]);
      expect(r.extraFromRoundingCents, 10200 - 10001);
      final exact =
          computeTip(billCents: 3000, tipPercent: 0, people: 3, roundUpTo: 100);
      expect(exact.extraFromRoundingCents, 0);
    });

    test('100% tip and large bills stay exact', () {
      final r = computeTip(billCents: 99999999999, tipPercent: 100);
      expect(r.totalCents, 199999999998);
      expect(formatCents(r.totalCents), '1999999999.98');
    });
  });
}
