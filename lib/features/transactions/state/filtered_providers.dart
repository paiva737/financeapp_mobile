import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction.dart';
import 'transactions_provider.dart';
import 'period_provider.dart';

/// Lista de transações filtradas pelo mês selecionado
final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final all = ref.watch(transactionsProvider);
  final month = ref.watch(selectedMonthProvider);
  final start = startOfMonth(month);
  final end = endOfMonth(month);

  return all.where((t) => t.date.isAfter(start.subtract(const Duration(milliseconds: 1)))
      && t.date.isBefore(end.add(const Duration(milliseconds: 1)))).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

/// Totais (entradas/saídas/saldo) somente do mês selecionado
final filteredTotalsProvider = Provider((ref) {
  final list = ref.watch(filteredTransactionsProvider);
  final income = list.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
  final expense = list.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
  final balance = income - expense;
  return (income: income, expense: expense, balance: balance);
});
