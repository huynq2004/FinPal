import 'package:flutter/material.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/domain/models/transaction.dart';

class MonthlyReportViewModel extends ChangeNotifier {
  final TransactionRepository _repo;

  int year = 0;
  int month = 0;

  // Current month
  int currentIncome = 0;
  int currentExpense = 0;
  int currentBalance = 0;

  // Previous month
  int prevIncome = 0;
  int prevExpense = 0;
  int prevBalance = 0;

  // By category
  Map<String, int> categoryExpenses = {};

  // Suggestions
  List<String> suggestions = [];

  bool isLoading = false;

  MonthlyReportViewModel()
    : _repo = TransactionRepository(DatabaseProvider.instance);

  /// Load report for given month
  Future<void> loadReport(int year, int month) async {
    try {
      isLoading = true;
      notifyListeners();

      // Current month data
      final currentStart = DateTime(year, month, 1);
      final currentEnd = DateTime(year, month + 1, 0, 23, 59, 59);
      final currentTxs = await _repo.getTransactionsByDateRange(
        startDate: currentStart,
        endDate: currentEnd,
      );

      // Previous month data
      final prevDate = DateTime(year, month - 1);
      final prevStart = DateTime(prevDate.year, prevDate.month, 1);
      final prevEnd = DateTime(
        prevDate.year,
        prevDate.month + 1,
        0,
        23,
        59,
        59,
      );
      final prevTxs = await _repo.getTransactionsByDateRange(
        startDate: prevStart,
        endDate: prevEnd,
      );

      // Calculate current month
      currentIncome = 0;
      currentExpense = 0;
      categoryExpenses.clear();

      for (final tx in currentTxs) {
        if (tx.type == 'income') {
          currentIncome += tx.amount;
        } else {
          currentExpense += tx.amount;
          // Group by category
          final catName = tx.categoryName;
          categoryExpenses[catName] =
              (categoryExpenses[catName] ?? 0) + tx.amount;
        }
      }

      currentBalance = currentIncome - currentExpense;

      // Calculate previous month
      prevIncome = 0;
      prevExpense = 0;

      for (final tx in prevTxs) {
        if (tx.type == 'income') {
          prevIncome += tx.amount;
        } else {
          prevExpense += tx.amount;
        }
      }

      prevBalance = prevIncome - prevExpense;

      // Generate suggestions
      _generateSuggestions(currentTxs, currentExpense, prevExpense);

      this.year = year;
      this.month = month;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading monthly report: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  void _generateSuggestions(
    List<Transaction> txs,
    int currentExp,
    int prevExp,
  ) {
    suggestions.clear();

    // Check month over month change
    if (currentExp > prevExp) {
      final increase = currentExp - prevExp;
      final percent = ((increase / prevExp) * 100).toStringAsFixed(1);
      suggestions.add(
        '💡 Chi tiêu tăng ${percent}% so với tháng trước. Hãy kiểm soát ngân sách!',
      );
    } else if (currentExp < prevExp && prevExp > 0) {
      final decrease = prevExp - currentExp;
      final percent = ((decrease / prevExp) * 100).toStringAsFixed(1);
      suggestions.add(
        '🎉 Bạn tiết kiệm được ${percent}% so với tháng trước. Tiếp tục cố gắng!',
      );
    }

    // Check highest spending category
    if (categoryExpenses.isNotEmpty) {
      var maxCat = '';
      var maxAmount = 0;
      categoryExpenses.forEach((cat, amount) {
        if (amount > maxAmount) {
          maxAmount = amount;
          maxCat = cat;
        }
      });

      if (maxAmount > 0) {
        final percent = ((maxAmount / currentExp) * 100).toStringAsFixed(1);
        suggestions.add(
          '📊 "$maxCat" là mục chi tiêu lớn nhất của bạn ($percent% tổng chi tiêu).',
        );
      }
    }

    // Check if no income
    if (currentIncome == 0 && txs.isNotEmpty) {
      suggestions.add(
        '⚠️ Bạn chưa ghi nhận thu nhập tháng này. Hãy thêm nguồn tiền của bạn!',
      );
    }

    // Generic encouragement if no suggestions
    if (suggestions.isEmpty) {
      suggestions.add(
        '✨ Bạn đang quản lý tài chính rất tốt. Tiếp tục duy trì thói quen!',
      );
    }
  }

  String get monthLabel {
    final now = DateTime(year, month);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month - 1]} $year';
  }

  String get prevMonthLabel {
    final prev = DateTime(year, month - 1);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[prev.month - 1]} ${prev.year}';
  }

  /// Calculate percentage change between current and previous month
  String getExpenseChangePercent() {
    if (prevExpense == 0) return 'N/A';
    final change = ((currentExpense - prevExpense) / prevExpense * 100);
    return change >= 0
        ? '+${change.toStringAsFixed(1)}%'
        : '${change.toStringAsFixed(1)}%';
  }

  /// Calculate percentage change for income
  String getIncomeChangePercent() {
    if (prevIncome == 0) return 'N/A';
    final change = ((currentIncome - prevIncome) / prevIncome * 100);
    return change >= 0
        ? '+${change.toStringAsFixed(1)}%'
        : '${change.toStringAsFixed(1)}%';
  }

  /// Get top 3 expense categories
  List<MapEntry<String, int>> getTopCategories([int limit = 3]) {
    final sorted = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }
}
