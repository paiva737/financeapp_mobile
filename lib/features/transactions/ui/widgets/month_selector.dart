import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/formatters.dart';
import '../../state/period_provider.dart';

class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key});

  String _label(DateTime d) {
    // Ex.: "setembro/2025" (usa o formatador de data só pra pegar mês/ano amigável)
    // Você pode customizar se quiser capitalizar a primeira letra.
    final meses = [
      'janeiro','fevereiro','março','abril','maio','junho',
      'julho','agosto','setembro','outubro','novembro','dezembro'
    ];
    return '${meses[d.month - 1]}/${d.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(selectedMonthProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Mês anterior',
            onPressed: () {
              final prev = DateTime(current.year, current.month - 1, 1);
              ref.read(selectedMonthProvider.notifier).state = prev;
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Center(
              child: Text(
                _label(current),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Próximo mês',
            onPressed: () {
              final next = DateTime(current.year, current.month + 1, 1);
              ref.read(selectedMonthProvider.notifier).state = next;
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
