import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction.dart';
import '../../../core/categories.dart';
import '../../transactions/state/filtered_providers.dart';

/// Retorna a lista de categorias de DESPESA ordenadas por valor (mês selecionado)
final expenseByCategoryProvider =
Provider<List<MapEntry<String, double>>>((ref) {
  final list = ref.watch(filteredTransactionsProvider);
  final map = <String, double>{};

  for (final t in list) {
    if (t.type == TransactionType.expense) {
      final key = normalizeCategory(t.category);
      map[key] = (map[key] ?? 0) + t.amount;
    }
  }

  final entries = map.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries;
});
