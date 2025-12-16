import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/category_stat.dart';

class DashboardViewModel extends ChangeNotifier {
  int totalIncome = 0;
  int totalExpense = 0;
  int get balance => totalIncome - totalExpense;

  final List<Transaction> _recent = [];

  List<Transaction> get recentTransactions => List.unmodifiable(_recent);

  List<CategoryStat> _categories = [];
  List<CategoryStat> get categories => List.unmodifiable(_categories);

  String monthLabel(int year, int month) {
    return 'Tháng $month/$year';
  }

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

    // Fake category stats for pie chart
    _categories = [
      const CategoryStat(name: 'Ăn uống', color: Color(0xFFFF6B6B), percent: 0.40, amount: 3280000),
      const CategoryStat(name: 'Mua sắm', color: Color(0xFF4ECDC4), percent: 0.20, amount: 1640000),
      const CategoryStat(name: 'Di chuyển', color: Color(0xFFFFD93D), percent: 0.15, amount: 1230000),
      const CategoryStat(name: 'Hóa đơn', color: Color(0xFF95E1D3), percent: 0.10, amount: 820000),
      const CategoryStat(name: 'Khác', color: Color(0xFFC7CEEA), percent: 0.15, amount: 1230000),
    ];

    notifyListeners();

    // Sprint sau: thay bằng TransactionRepository.getTransactionsByMonth(...)
  }
}
