import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/category_stat.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/db/database_provider.dart';

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
    try {
      final repo = TransactionRepository(DatabaseProvider.instance);
      final transactions = await repo.getTransactionsByMonth(year, month);
      
      debugPrint('📊 Dashboard: Loaded ${transactions.length} transactions from DB for $month/$year');
      
      // Tính tổng thu nhập và chi tiêu từ transactions thực
      totalIncome = 0;
      totalExpense = 0;
      for (final txn in transactions) {
        if (txn.type == 'income') {
          totalIncome += txn.amount;
        } else if (txn.type == 'expense') {
          totalExpense += txn.amount;
        }
      }
      
      debugPrint('📊 Dashboard: Income=$totalIncome, Expense=$totalExpense');
      
      // Lấy 3 giao dịch gần nhất để hiển thị trên dashboard
      _recent
        ..clear()
        ..addAll(transactions.take(3));
      
      debugPrint('📊 Dashboard: Recent transactions = ${_recent.length}');
      for (final tx in _recent) {
        debugPrint('  - ${tx.note ?? tx.categoryName}: ${tx.amount}đ (${tx.type})');
      }
      
      // Tính category stats từ transactions thực
      _categories = _calculateCategoryStats(transactions);
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading dashboard summary: $e');
      // Reset về giá trị mặc định nếu có lỗi
      totalIncome = 0;
      totalExpense = 0;
      _recent.clear();
      _categories = [];
      notifyListeners();
    }
  }
  
  /// Tính toán category statistics từ danh sách transactions
  List<CategoryStat> _calculateCategoryStats(List<Transaction> transactions) {
    // Lọc chỉ các giao dịch chi tiêu
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    debugPrint('📊 Calculate Category Stats: Found ${expenses.length} expense transactions');
    if (expenses.isEmpty) return [];
    
    // Nhóm theo category và tính tổng
    final Map<String, int> categoryTotals = {};
    for (final txn in expenses) {
      final catName = txn.categoryName;
      categoryTotals[catName] = (categoryTotals[catName] ?? 0) + txn.amount;
    }
    
    debugPrint('📊 Category totals: $categoryTotals');
    
    // Tính tổng chi tiêu
    final totalExpenseAmount = categoryTotals.values.fold<int>(0, (sum, amt) => sum + amt);
    debugPrint('📊 Total expense amount: $totalExpenseAmount');
    if (totalExpenseAmount == 0) return [];
    
    // Tạo danh sách CategoryStat với màu sắc
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFD93D),
      const Color(0xFF95E1D3),
      const Color(0xFFC7CEEA),
      const Color(0xFFFF9FF3),
      const Color(0xFF54A0FF),
      const Color(0xFFFECA57),
    ];
    
    int colorIndex = 0;
    final stats = categoryTotals.entries.map((entry) {
      final stat = CategoryStat(
        name: entry.key,
        color: colors[colorIndex % colors.length],
        percent: entry.value / totalExpenseAmount,
        amount: entry.value,
      );
      colorIndex++;
      return stat;
    }).toList();
    
    // Sắp xếp theo amount giảm dần
    stats.sort((a, b) => b.amount.compareTo(a.amount));
    return stats;
  }
}
