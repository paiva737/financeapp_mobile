import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/categories.dart';
import '../../../core/formatters.dart';
import '../../transactions/state/period_provider.dart';
import '../state/category_report_provider.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final expenses = ref.watch(expenseByCategoryProvider);
    final total = expenses.fold<double>(0, (s, e) => s + e.value);
    final barItems = expenses.take(8).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gastos por categoria — ${month.month}/${month.year}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Total de gastos: ${formatCurrency(total)}'),
            const SizedBox(height: 16),

            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: (barItems.isEmpty
                      ? 0
                      : barItems.first.value) *
                      1.15, // um respiro acima da maior barra
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= barItems.length) {
                            return const SizedBox.shrink();
                          }
                          final cat = barItems[i].key;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              cat,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(barItems.length, (i) {
                    final cat = barItems[i].key;
                    final val = barItems[i].value;
                    final color = (categories[cat]?.color ?? Colors.grey);
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: val,
                        color: color,
                        width: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ]);
                  }),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (barItems.isEmpty)
              const Center(child: Text('Sem despesas neste mês'))
            else
              ...barItems.map((e) {
                final c = categories[e.key];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: (c?.color ?? Colors.grey).withOpacity(0.2),
                    child: Icon(c?.icon ?? Icons.category,
                        size: 14, color: c?.color ?? Colors.grey),
                  ),
                  title: Text(e.key),
                  trailing: Text('- ${formatCurrency(e.value)}'),
                );
              }),
          ],
        ),
      ),
    );
  }
}
