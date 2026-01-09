// lib/data/services/analytics_service.dart

import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/domain/models/transaction.dart';

class AnalyticsService {
  final TransactionRepository _transactionRepo;

  AnalyticsService(this._transactionRepo);

  /// Lấy tổng chi tiêu theo danh mục trong tháng
  Future<int> getExpenseByCategory(int year, int month, int categoryId) async {
    try {
      final transactions = await _transactionRepo.getTransactionsByMonth(year, month);
      
      final categoryExpenses = transactions.where((t) => 
        t.type == 'expense' && 
        t.categoryId == categoryId
      );
      
      return categoryExpenses.fold<int>(0, (sum, t) => sum + t.amount);
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getExpenseByCategory: $e');
      return 0;
    }
  }

  /// Lấy tổng chi tiêu theo tên danh mục (fallback nếu không có categoryId)
  Future<int> getExpenseByCategoryName(int year, int month, String categoryName) async {
    try {
      final transactions = await _transactionRepo.getTransactionsByMonth(year, month);
      
      final categoryExpenses = transactions.where((t) => 
        t.type == 'expense' && 
        t.categoryName.toLowerCase() == categoryName.toLowerCase()
      );
      
      return categoryExpenses.fold<int>(0, (sum, t) => sum + t.amount);
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getExpenseByCategoryName: $e');
      return 0;
    }
  }

  /// Lấy tổng chi tiêu trong tháng
  Future<int> getTotalExpense(int year, int month) async {
    try {
      final transactions = await _transactionRepo.getTransactionsByMonth(year, month);
      
      final expenses = transactions.where((t) => t.type == 'expense');
      
      return expenses.fold<int>(0, (sum, t) => sum + t.amount);
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getTotalExpense: $e');
      return 0;
    }
  }

  /// Lấy tổng thu nhập trong tháng
  Future<int> getTotalIncome(int year, int month) async {
    try {
      final transactions = await _transactionRepo.getTransactionsByMonth(year, month);
      
      final income = transactions.where((t) => t.type == 'income');
      
      return income.fold<int>(0, (sum, t) => sum + t.amount);
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getTotalIncome: $e');
      return 0;
    }
  }

  /// Lấy chi tiêu trung bình hàng tuần theo danh mục
  Future<double> getWeeklyAverageExpense(int categoryId) async {
    try {
      // Lấy giao dịch 4 tuần gần nhất
      final now = DateTime.now();
      final fourWeeksAgo = now.subtract(const Duration(days: 28));
      
      final transactions = await _transactionRepo.getTransactionsByDateRange(
        startDate: fourWeeksAgo,
        endDate: now,
      );
      
      final categoryExpenses = transactions.where((t) => 
        t.type == 'expense' && 
        t.categoryId == categoryId
      );
      
      final total = categoryExpenses.fold<int>(0, (sum, t) => sum + t.amount);
      
      // Chia cho 4 tuần
      return total / 4.0;
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getWeeklyAverageExpense: $e');
      return 0.0;
    }
  }

  /// Lấy chi tiêu trung bình hàng tuần theo tên danh mục
  Future<double> getWeeklyAverageExpenseByCategoryName(String categoryName) async {
    try {
      // Lấy giao dịch 4 tuần gần nhất
      final now = DateTime.now();
      final fourWeeksAgo = now.subtract(const Duration(days: 28));
      
      final transactions = await _transactionRepo.getTransactionsByDateRange(
        startDate: fourWeeksAgo,
        endDate: now,
      );
      
      final categoryExpenses = transactions.where((t) => 
        t.type == 'expense' && 
        t.categoryName.toLowerCase() == categoryName.toLowerCase()
      );
      
      final total = categoryExpenses.fold<int>(0, (sum, t) => sum + t.amount);
      
      // Chia cho 4 tuần
      return total / 4.0;
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getWeeklyAverageExpenseByCategoryName: $e');
      return 0.0;
    }
  }

  /// Lấy chi tiêu trung bình hàng ngày của tháng hiện tại
  Future<double> getDailyAverageExpense(int year, int month) async {
    try {
      final transactions = await _transactionRepo.getTransactionsByMonth(year, month);
      
      final expenses = transactions.where((t) => t.type == 'expense');
      final total = expenses.fold<int>(0, (sum, t) => sum + t.amount);
      
      // Lấy số ngày đã trải qua trong tháng
      final now = DateTime.now();
      final daysInMonth = now.year == year && now.month == month 
          ? now.day 
          : DateTime(year, month + 1, 0).day;
      
      return daysInMonth > 0 ? total / daysInMonth : 0.0;
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getDailyAverageExpense: $e');
      return 0.0;
    }
  }

  /// Lấy chi tiêu trung bình hàng ngày theo danh mục
  Future<double> getDailyAverageExpenseByCategory(int year, int month, int categoryId) async {
    try {
      final transactions = await _transactionRepo.getTransactionsByMonth(year, month);
      
      final categoryExpenses = transactions.where((t) => 
        t.type == 'expense' && 
        t.categoryId == categoryId
      );
      
      final total = categoryExpenses.fold<int>(0, (sum, t) => sum + t.amount);
      
      // Lấy số ngày đã trải qua trong tháng
      final now = DateTime.now();
      final daysInMonth = now.year == year && now.month == month 
          ? now.day 
          : DateTime(year, month + 1, 0).day;
      
      return daysInMonth > 0 ? total / daysInMonth : 0.0;
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getDailyAverageExpenseByCategory: $e');
      return 0.0;
    }
  }

  /// Lấy tất cả giao dịch của một danh mục trong tháng
  Future<List<Transaction>> getCategoryTransactions(
    int year, 
    int month, 
    String categoryName,
  ) async {
    try {
      final transactions = await _transactionRepo.getTransactionsByMonth(year, month);
      
      return transactions.where((t) => 
        t.categoryName.toLowerCase() == categoryName.toLowerCase()
      ).toList();
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getCategoryTransactions: $e');
      return [];
    }
  }

  /// Lấy top N danh mục chi tiêu nhiều nhất trong tháng
  Future<Map<String, int>> getTopExpenseCategories(
    int year, 
    int month, 
    {int limit = 5}
  ) async {
    try {
      final transactions = await _transactionRepo.getTransactionsByMonth(year, month);
      
      final expenses = transactions.where((t) => t.type == 'expense');
      
      // Tính tổng theo category
      final Map<String, int> categoryTotals = {};
      for (final t in expenses) {
        categoryTotals[t.categoryName] = 
          (categoryTotals[t.categoryName] ?? 0) + t.amount;
      }
      
      // Sort và lấy top N
      final sorted = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return Map.fromEntries(sorted.take(limit));
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getTopExpenseCategories: $e');
      return {};
    }
  }

  /// Lấy tên danh mục từ categoryId (từ transactions gần đây)
  Future<String> getCategoryNameById(int categoryId) async {
    try {
      final now = DateTime.now();
      final transactions = await _transactionRepo.getTransactionsByMonth(now.year, now.month);
      
      final matchingTransaction = transactions.firstWhere(
        (t) => t.categoryId == categoryId,
        orElse: () => Transaction(
          amount: 0,
          type: 'expense',
          categoryName: 'Danh mục',
          createdAt: DateTime.now(),
          source: 'unknown',
        ),
      );
      
      return matchingTransaction.categoryName;
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getCategoryNameById: $e');
      return 'Danh mục';
    }
  }

  /// So sánh chi tiêu tháng này với tháng trước
  Future<double> getExpenseGrowthRate(int year, int month) async {
    try {
      final currentMonthExpense = await getTotalExpense(year, month);
      
      // Tính tháng trước
      final previousMonth = month == 1 ? 12 : month - 1;
      final previousYear = month == 1 ? year - 1 : year;
      
      final previousMonthExpense = await getTotalExpense(previousYear, previousMonth);
      
      if (previousMonthExpense == 0) return 0.0;
      
      return ((currentMonthExpense - previousMonthExpense) / previousMonthExpense) * 100;
    } catch (e) {
      print('❌ [AnalyticsService] Lỗi getExpenseGrowthRate: $e');
      return 0.0;
    }
  }
}
