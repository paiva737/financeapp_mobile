import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/transaction.dart';
import '../../state/transactions_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final TransactionModel? editing; // null = criar, != null = editar
  const AddTransactionSheet({super.key, this.editing});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _category;
  late DateTime _date;
  late TransactionType _type;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _title = TextEditingController(text: e?.title ?? '');
    _amount = TextEditingController(text: e != null ? e.amount.toString() : '');
    _category = TextEditingController(text: e?.category ?? '');
    _date = e?.date ?? DateTime.now();
    _type = e?.type ?? TransactionType.income;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.editing != null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'Editar transação' : 'Nova transação',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TransactionType>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: TransactionType.income, child: Text('Entrada')),
                    DropdownMenuItem(value: TransactionType.expense, child: Text('Saída')),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? TransactionType.income),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um título' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amount,
                  decoration: const InputDecoration(labelText: 'Valor (ex: 120.50)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d <= 0) return 'Informe um valor válido';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _category,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a categoria' : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text('Data: ${_date.day.toString().padLeft(2,'0')}/${_date.month.toString().padLeft(2,'0')}/${_date.year}')),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2015),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                      child: const Text('Selecionar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;

                      final notifier = ref.read(transactionsProvider.notifier);
                      final amount = double.parse(_amount.text.trim());

                      if (isEditing) {
                        // mantém o mesmo id para sobrescrever no Hive
                        final updated = TransactionModel(
                          id: widget.editing!.id,
                          title: _title.text.trim(),
                          amount: amount,
                          date: _date,
                          type: _type,
                          category: _category.text.trim(),
                        );
                        notifier.update(updated);
                      } else {
                        notifier.add(
                          title: _title.text.trim(),
                          amount: amount,
                          date: _date,
                          type: _type,
                          category: _category.text.trim(),
                        );
                      }

                      Navigator.pop(context);
                    },
                    child: Text(isEditing ? 'Salvar alterações' : 'Salvar'),
                  ),
                ),
                if (isEditing) const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
