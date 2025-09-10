import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/formatters.dart';

class IncomeExpensePie extends StatelessWidget {
  final double income;
  final double expense;

  const IncomeExpensePie({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    if (total <= 0) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text('Gráfico aparecerá após adicionar transações'),
      );
    }

    final incomePct = (income / total) * 100;
    final expensePct = 100 - incomePct;

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 52,
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: income,
                      radius: 72,
                      title: incomePct >= 8 ? '${incomePct.toStringAsFixed(0)}%' : '',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      titlePositionPercentageOffset: 0.6,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: expense,
                      radius: 72,
                      title: expensePct >= 8 ? '${expensePct.toStringAsFixed(0)}%' : '',
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      titlePositionPercentageOffset: 0.6,
                    ),
                  ],
                ),
              ),
              // Rótulo central
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${incomePct.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Entradas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: Colors.green, label: 'Entradas (${formatCurrency(income)})'),
            const SizedBox(width: 16),
            _LegendDot(color: Colors.red, label: 'Saídas (${formatCurrency(expense)})'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
