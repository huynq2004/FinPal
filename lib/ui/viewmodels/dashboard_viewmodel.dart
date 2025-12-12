import 'package:flutter/foundation.dart';

class DashboardViewModel extends ChangeNotifier {
  int totalIncome = 0;
  int totalExpense = 0;
  int get balance => totalIncome - totalExpense;

  Future<void> loadSummary(int year, int month) async {
    // Sprint 1: fake data để DONE UI
    totalIncome = 5000000;
    totalExpense = 2000000;
    notifyListeners();

    // Sprint sau: thay bằng TransactionRepository.getTransactionsByMonth(...)
  }
}
