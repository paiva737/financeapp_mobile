import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../transactions/state/filtered_providers.dart';
import '../../transactions/state/period_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../core/categories.dart';

String _amountBR(double v) => v.toStringAsFixed(2).replaceAll('.', ',');
String _esc(String s) => s.replaceAll('"', '""');

Future<void> exportCurrentMonthCsv(BuildContext context, WidgetRef ref) async {
  final list = ref.read(filteredTransactionsProvider);
  final month = ref.read(selectedMonthProvider);
  final monthLabel = DateFormat('yyyy-MM').format(month);

  if (list.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sem transações neste mês para exportar')),
    );
    return;
  }

  final buf = StringBuffer();
  buf.writeln('id;titulo;valor;tipo;categoria;data'); // ; para Excel pt-BR

  for (final t in list) {
    final tipo = t.type == TransactionType.income ? 'entrada' : 'saída';
    final cat = normalizeCategory(t.category);
    final data = DateFormat('dd/MM/yyyy', 'pt_BR').format(t.date);
    buf.writeln(
      '${t.id};"${_esc(t.title)}";${_amountBR(t.amount)};$tipo;"${_esc(cat)}";$data',
    );
  }

  final bytes = Uint8List.fromList(utf8.encode(buf.toString()));
  final fileName = 'transacoes-$monthLabel.csv';

  await Share.shareXFiles(
    [XFile.fromData(bytes, name: fileName, mimeType: 'text/csv')],
    text: 'Transações do mês $monthLabel',
    subject: 'FinanceApp - $fileName',
  );
}
