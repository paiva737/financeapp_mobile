import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/ui/auth_gate.dart';
import '../../auth/state/auth_providers.dart';

import '../../transactions/state/filtered_providers.dart';
import '../../transactions/state/category_filter_provider.dart';
import '../../transactions/state/type_filter_provider.dart';
import '../../reports/ui/reports_pages.dart';

import 'widgets/type_filter_chips.dart';
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
    final type = ref.watch(selectedTypeFilterProvider);

    String typeLabel(TxTypeFilter t) => switch (t) {
      TxTypeFilter.all => 'Todos os tipos',
      TxTypeFilter.income => 'Entradas',
      TxTypeFilter.expense => 'Saídas',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanceApp'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Relatórios',
            icon: const Icon(Icons.insert_chart_outlined_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportsPage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();


              ref.invalidate(selectedCategoryProvider);
              ref.invalidate(selectedTypeFilterProvider);
              ref.invalidate(filteredTransactionsProvider);
              ref.invalidate(filteredTotalsProvider);

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                      (route) => false,
                );
              }
            },
          ),
        ],
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
                const SizedBox(height: 8),
                const TypeFilterChips(),
                if (cat != null || type != TxTypeFilter.all)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(
                      'Filtrando: ${cat ?? "Todas as categorias"} • ${typeLabel(type)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
