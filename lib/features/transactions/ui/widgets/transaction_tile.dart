import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/formatters.dart';
import '../../../../data/models/transaction.dart';
import '../../state/transactions_provider.dart';
import 'add_transaction_sheet.dart';

class TransactionTile extends ConsumerWidget {
  final TransactionModel model;
  const TransactionTile({super.key, required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = model.type == TransactionType.income;

    Future<bool> _confirmDelete() async {
      final result = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Excluir transação?'),
          content: Text('Tem certeza que deseja excluir "${model.title}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
          ],
        ),
      );
      return result ?? false;
    }

    return Dismissible(
      key: ValueKey(model.id),
      background: Container(color: Colors.red),
      confirmDismiss: (_) => _confirmDelete(),
      onDismissed: (_) => ref.read(transactionsProvider.notifier).remove(model.id),
      child: ListTile(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => AddTransactionSheet(editing: model),
        ),
        leading: CircleAvatar(child: Icon(isIncome ? Icons.south_west : Icons.north_east)),
        title: Text(model.title),
        subtitle: Text('${model.category} • ${formatDate(model.date)}'),
        trailing: Text(
          (isIncome ? '+' : '-') + formatCurrency(model.amount),
          style: TextStyle(color: isIncome ? Colors.green : Colors.red),
        ),
      ),
    );
  }
}
