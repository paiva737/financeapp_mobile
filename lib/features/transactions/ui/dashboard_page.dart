import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/state/filtered_providers.dart';
import '../../transactions/state/category_filter_provider.dart';
import '../../../core/formatters.dart';

import 'widgets/balance_header.dart';
import 'widgets/income_expense_pie.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/month_selector.dart';
import 'widgets/category_filter_chips.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredTransactionsProvider);
    final totals = ref.watch(filteredTotalsProvider);
    final cat = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanceApp'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MonthSelector(),
                const SizedBox(height: 4),
                const CategoryFilterChips(),
                if (cat != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text('Filtrando: $cat',
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                const SizedBox(height: 8),
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
              ],
            ),
          ),
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Sem transações ainda')),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) => TransactionTile(model: items[i]),
                childCount: items.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
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
