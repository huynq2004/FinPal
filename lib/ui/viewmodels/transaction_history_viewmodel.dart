import 'package:flutter/foundation.dart';
import '../../domain/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/db/database_provider.dart';

class TransactionHistoryViewModel extends ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Load transactions from database for a specific month
  Future<void> loadFromDb(int year, int month) async {
    try {
      final repo = TransactionRepository(DatabaseProvider.instance);
      final transactions = await repo.getTransactionsByMonth(year, month);
      _transactions
        ..clear()
        ..addAll(transactions);
      notifyListeners();
    } catch (e) {
      // Log error or notify UI
      debugPrint('Error loading transactions from DB: $e');
      notifyListeners();
    }
  }

  /// Reload all transactions from database
  Future<void> loadAllFromDb() async {
    try {
      final repo = TransactionRepository(DatabaseProvider.instance);
      final transactions = await repo.getAllTransactions();
      _transactions
        ..clear()
        ..addAll(transactions);
      notifyListeners();
    } catch (e) {
      // Log error or notify UI
      debugPrint('Error loading transactions from DB: $e');
      notifyListeners();
    }
  }

  /// ONLY FOR TESTING: Load fake data
  Future<void> loadFakeData() async {
    _transactions
      ..clear()
      ..addAll([
        Transaction(
          id: 1,
          amount: 55000,
          type: 'expense',
          categoryName: 'Di chuyển',
          bank: 'VCB',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          note: 'GRAB',
          source: 'sms',
        ),
        Transaction(
          id: 2,
          amount: 120000,
          type: 'expense',
          categoryName: 'Ăn uống',
          bank: 'TCB',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          note: 'THE COFFEE HOUSE',
          source: 'sms',
        ),
        Transaction(
          id: 3,
          amount: 5000000,
          type: 'income',
          categoryName: 'Thu nhập',
          bank: 'ACB',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          note: 'Salary',
          source: 'manual',
        ),
      ]);

    notifyListeners();
  }
}
