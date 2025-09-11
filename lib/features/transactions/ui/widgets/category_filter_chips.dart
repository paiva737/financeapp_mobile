import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/categories.dart';
import '../../state/category_filter_provider.dart';

class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    final items = ['Todas', ...categories.keys];
    final selectedLabel = selected ?? 'Todas';

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label = items[i];
          final isSelected = label == selectedLabel;

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) {

              ref.read(selectedCategoryProvider.notifier).state =
              (label == 'Todas') ? null : label;
            },
          );
        },
      ),
    );
  }
}
