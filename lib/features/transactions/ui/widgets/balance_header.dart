import 'package:flutter/material.dart';
import '../../../../core/formatters.dart';

class BalanceHeader extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const BalanceHeader({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo'),
                    const SizedBox(height: 6),
                    Text(
                      formatCurrency(balance),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text('Entradas: ${formatCurrency(income)}')),
                        Expanded(child: Text('Saídas: ${formatCurrency(expense)}')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
