/// Tip and split maths in integer cents.
library;

const tipPresets = [10, 15, 18, 20];

/// Parses a money amount like `12`, `12.5`, `1,234.56` into cents.
/// Returns null for negatives, more than two decimals or garbage.
int? parseAmountCents(String input) {
  final s = input.trim().replaceAll(',', '');
  final m = RegExp(r'^(\d{1,9})(?:\.(\d{0,2}))?$').firstMatch(s);
  if (m == null) return null;
  final whole = int.parse(m.group(1)!);
  final frac = (m.group(2) ?? '').padRight(2, '0');
  return whole * 100 + int.parse(frac);
}

String formatCents(int cents) =>
    '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

class TipBreakdown {
  const TipBreakdown({
    required this.billCents,
    required this.tipCents,
    required this.totalCents,
    required this.shares,
  });

  final int billCents;
  final int tipCents;
  final int totalCents;

  /// One entry per person; they always sum to at least [totalCents].
  final List<int> shares;

  int get collectedCents => shares.fold(0, (a, b) => a + b);
  int get extraFromRoundingCents => collectedCents - totalCents;
}

/// Computes tip (half-up to the cent) and splits between [people].
///
/// Without rounding the split is exact: the first `remainder` people pay one
/// extra cent. With [roundUpTo] (in cents, e.g. 100 for whole units) every
/// share is rounded up to that multiple so nobody deals with coins.
TipBreakdown computeTip({
  required int billCents,
  required int tipPercent,
  int people = 1,
  int? roundUpTo,
}) {
  if (billCents < 0) throw ArgumentError.value(billCents, 'billCents');
  if (tipPercent < 0 || tipPercent > 100) {
    throw ArgumentError.value(tipPercent, 'tipPercent', 'must be 0-100');
  }
  if (people < 1) throw ArgumentError.value(people, 'people', 'must be >= 1');
  if (roundUpTo != null && roundUpTo < 1) {
    throw ArgumentError.value(roundUpTo, 'roundUpTo');
  }
  final tip = (billCents * tipPercent + 50) ~/ 100;
  final total = billCents + tip;
  final base = total ~/ people;
  final remainder = total % people;
  var shares =
      List<int>.generate(people, (i) => base + (i < remainder ? 1 : 0));
  if (roundUpTo != null) {
    final perPerson = shares.first;
    final rounded = (perPerson + roundUpTo - 1) ~/ roundUpTo * roundUpTo;
    shares = List<int>.filled(people, rounded);
  }
  return TipBreakdown(
    billCents: billCents,
    tipCents: tip,
    totalCents: total,
    shares: shares,
  );
}
