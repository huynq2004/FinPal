import 'package:flutter/foundation.dart';
import '../../domain/models/transaction.dart';

class DashboardViewModel extends ChangeNotifier {
  int totalIncome = 0;
  int totalExpense = 0;
  int get balance => totalIncome - totalExpense;

  // tạm dùng dữ liệu giả / lấy từ TransactionHistoryViewModel
  Future<void> loadSummaryFake() async {
    // Ví dụ tạm: income 5tr, expense 2tr
    totalIncome = 5000000;
    totalExpense = 2000000;
    notifyListeners();
  }

  Future<void> loadSummary(int year, int month) async {
    // TODO: sau này gọi TransactionRepository.getTransactionsByMonth(...)
    // final list = await _transactionRepository.getTransactionsByMonth(year, month);
    // _calculateFromTransactions(list);
  }

  void calculateFromTransactions(List<Transaction> transactions) {
    totalIncome = 0;
    totalExpense = 0;

    for (final tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense') {
        totalExpense += tx.amount;
      }
    }
    notifyListeners();
  }
}
