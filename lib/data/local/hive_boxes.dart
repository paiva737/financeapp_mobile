import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class HiveBoxes {
  static const transactions = 'transactions_box';
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  await Hive.openBox<TransactionModel>(HiveBoxes.transactions);
}
