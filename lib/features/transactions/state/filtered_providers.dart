import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction.dart';
import '../../../core/categories.dart';
import 'transactions_provider.dart';
import 'period_provider.dart';
import 'category_filter_provider.dart';
import 'type_filter_provider.dart';


final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final all = ref.watch(transactionsProvider);
  final month = ref.watch(selectedMonthProvider);
  final selectedCat = ref.watch(selectedCategoryProvider);
  final typeFilter = ref.watch(selectedTypeFilterProvider);

  final start = startOfMonth(month);
  final end = endOfMonth(month);

  return all.where((t) {
    final inMonth =
        t.date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
            t.date.isBefore(end.add(const Duration(milliseconds: 1)));

    final catOk = selectedCat == null
        ? true
        : normalizeCategory(t.category) == normalizeCategory(selectedCat);

    final typeOk = switch (typeFilter) {
      TxTypeFilter.all => true,
      TxTypeFilter.income => t.type == TransactionType.income,
      TxTypeFilter.expense => t.type == TransactionType.expense,
    };

    return inMonth && catOk && typeOk;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});


final filteredTotalsProvider = Provider((ref) {
  final list = ref.watch(filteredTransactionsProvider);
  final income = list.where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);
  final expense = list.where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);
  final balance = income - expense;
  return (income: income, expense: expense, balance: balance);
});
