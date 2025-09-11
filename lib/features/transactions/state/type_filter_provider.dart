import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TxTypeFilter { all, income, expense }


final selectedTypeFilterProvider =
StateProvider<TxTypeFilter>((ref) => TxTypeFilter.all);
