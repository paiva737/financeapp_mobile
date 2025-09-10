import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');
final _date = DateFormat('dd/MM/yyyy', 'pt_BR');

String formatCurrency(double v) => _currency.format(v);
String formatDate(DateTime d) => _date.format(d);
