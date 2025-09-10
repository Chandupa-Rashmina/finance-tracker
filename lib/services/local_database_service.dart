import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../models/transaction.dart';

class LocalDatabaseService {
  static const String _transactionBoxName = 'transactions';
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    Hive.registerAdapter(TransactionAdapter());
    await Hive.openBox<Transaction>(_transactionBoxName);
    _isInitialized = true;
  }

  static Box<Transaction> get _transactionBox => Hive.box<Transaction>(_transactionBoxName);

  static Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  static List<Transaction> getTransactions() {
    final transactions = _transactionBox.values.toList();
    // Sort by date descending (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  static Stream<List<Transaction>> watchTransactions() {
    return _transactionBox.watch().map((event) => getTransactions());
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String transactionId) async {
    await _transactionBox.delete(transactionId);
  }

  static Map<String, double> getTransactionsSummary() {
    final transactions = getTransactions();
    
    double totalIncome = 0;
    double totalExpense = 0;

    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  static Future<void> clearAllData() async {
    await _transactionBox.clear();
  }
}