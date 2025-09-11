import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/type_filter_provider.dart';

class TypeFilterChips extends ConsumerWidget {
  const TypeFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTypeFilterProvider);

    Widget chip(String label, TxTypeFilter value) {
      final isSelected = selected == value;
      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) =>
        ref.read(selectedTypeFilterProvider.notifier).state = value,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          chip('Todas', TxTypeFilter.all),
          chip('Entradas', TxTypeFilter.income),
          chip('Saídas', TxTypeFilter.expense),
        ],
      ),
    );
  }
}


class _TypeChip extends ConsumerWidget {
  final String label;
  final TxTypeFilter value;
  const _TypeChip({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTypeFilterProvider);
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => ref.read(selectedTypeFilterProvider.notifier).state = value,
    );
  }
}
