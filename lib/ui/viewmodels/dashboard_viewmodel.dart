import 'package:flutter/foundation.dart';
import '../../domain/models/transaction.dart';

class DashboardViewModel extends ChangeNotifier {
  int totalIncome = 0;
  int totalExpense = 0;
  int get balance => totalIncome - totalExpense;

  final List<Transaction> _recent = [];

  List<Transaction> get recentTransactions => List.unmodifiable(_recent);

  Future<void> loadSummary(int year, int month) async {
    // Sprint 1: fake data để DONE UI
    totalIncome = 5000000;
    totalExpense = 2000000;
    // Fake recent transactions (preview on dashboard)
    _recent
      ..clear()
      ..addAll([
        Transaction(
          id: 3,
          amount: 5000000,
          type: 'income',
          categoryName: 'Thu nhập',
          bank: 'ACB',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          note: 'Salary',
        ),
        Transaction(
          id: 2,
          amount: 120000,
          type: 'expense',
          categoryName: 'Ăn uống',
          bank: 'TCB',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          note: 'THE COFFEE HOUSE',
        ),
        Transaction(
          id: 1,
          amount: 55000,
          type: 'expense',
          categoryName: 'Di chuyển',
          bank: 'VCB',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          note: 'GRAB',
        ),
      ]);

    notifyListeners();

    // Sprint sau: thay bằng TransactionRepository.getTransactionsByMonth(...)
  }
}
