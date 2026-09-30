import 'package:flutter/material.dart';

import '../logic/tip_math.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bill = TextEditingController(text: '50.00');
  final _custom = TextEditingController();
  int _percent = 15;
  int _people = 1;
  bool _roundUp = false;

  @override
  void dispose() {
    _bill.dispose();
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bill = parseAmountCents(_bill.text);
    final customPct = parsePercent(_custom.text);
    final customInvalid = _custom.text.trim().isNotEmpty && customPct == null;
    final pct = customPct ?? _percent;
    // No result while either field is invalid, so the card never shows a
    // total computed from a percentage the user did not enter.
    final result = bill == null || customInvalid
        ? null
        : computeTip(
            billCents: bill,
            tipPercent: pct,
            people: _people,
            roundUpTo: _roundUp ? 100 : null,
          );
    return Scaffold(
      appBar: AppBar(title: const Text('Donation Tip Jar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('bill-input'),
            controller: _bill,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              border: const OutlineInputBorder(),
              errorText: bill == null ? 'Enter an amount like 42.50' : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text('Tip', style: textTheme.titleMedium),
          Wrap(
            spacing: 8,
            children: [
              for (final p in tipPresets)
                ChoiceChip(
                  label: Text('$p%'),
                  selected: _custom.text.trim().isEmpty && _percent == p,
                  onSelected: (_) => setState(() {
                    _percent = p;
                    _custom.clear();
                  }),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('custom-input'),
            controller: _custom,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Custom %',
              border: const OutlineInputBorder(),
              errorText: customInvalid ? 'Use 0 to 100' : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Semantics(
                liveRegion: true,
                child: Text('People: $_people', style: textTheme.titleMedium),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Fewer people',
                icon: const Icon(Icons.remove),
                onPressed: _people > 1 ? () => setState(() => _people--) : null,
              ),
              IconButton(
                tooltip: 'More people',
                icon: const Icon(Icons.add),
                onPressed:
                    _people < 50 ? () => setState(() => _people++) : null,
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Round each share up to a whole amount'),
            value: _roundUp,
            onChanged: (v) => setState(() => _roundUp = v),
          ),
          if (result != null)
            Card(
              key: const Key('result'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tip ($pct%): ${formatCents(result.tipCents)}'),
                    Text(
                      'Total: ${formatCents(result.totalCents)}',
                      key: const Key('total'),
                      style: textTheme.titleLarge,
                    ),
                    Text(
                      _people == 1
                          ? 'One person pays ${formatCents(result.shares.first)}'
                          : 'Each pays ${formatCents(result.shares.first)}'
                              '${result.shares.toSet().length > 1 ? ' (some pay ${formatCents(result.shares.last)})' : ''}',
                      key: const Key('share'),
                    ),
                    if (result.extraFromRoundingCents > 0)
                      Text(
                        'Rounding adds ${formatCents(result.extraFromRoundingCents)} extra',
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
