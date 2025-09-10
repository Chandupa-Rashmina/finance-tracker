import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/services/local_database_service.dart';
import 'package:finance_tracker/models/transaction.dart';

final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return LocalDatabaseService.watchTransactions();
});

final transactionsSummaryProvider = Provider<Map<String, double>>((ref) {
  return LocalDatabaseService.getTransactionsSummary();
});