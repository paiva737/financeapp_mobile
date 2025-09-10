import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/state/filtered_providers.dart';
import '../../transactions/state/transactions_provider.dart';
import '../../../core/formatters.dart';
import 'widgets/balance_header.dart';
import 'widgets/income_expense_pie.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/month_selector.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredTransactionsProvider);
    final totals = ref.watch(filteredTotalsProvider);


    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanceApp'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const MonthSelector(),
          BalanceHeader(
            balance: totals.balance,
            income: totals.income,
            expense: totals.expense,
          ),
          IncomeExpensePie(
            income: totals.income,
            expense: totals.expense,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Sem transações ainda'))
                : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => TransactionTile(model: items[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const AddTransactionSheet(),
        ),
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
