import 'package:flutter/material.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/categories_repository.dart';
import '../../domain/models/budget.dart';

class BudgetManagementViewModel extends ChangeNotifier {
  final BudgetRepository _budgetRepo;
  final TransactionRepository _transactionRepo;
  final DatabaseProvider _dbProvider;

  List<BudgetItem> _budgetItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  List<BudgetItem> get budgetItems => List.unmodifiable(_budgetItems);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalLimit => _budgetItems.fold(0.0, (sum, item) => sum + item.limit);
  double get totalSpent => _budgetItems.fold(0.0, (sum, item) => sum + item.spent);
  double get totalRemaining => totalLimit - totalSpent;

  BudgetManagementViewModel()
      : _budgetRepo = BudgetRepository(DatabaseProvider.instance),
        _transactionRepo = TransactionRepository(DatabaseProvider.instance),
        _dbProvider = DatabaseProvider.instance;

  /// Load budgets cho tháng hiện tại
  Future<void> loadBudgets() async {
    await loadBudgetsForMonth(_currentYear, _currentMonth);
  }

  /// Load budgets cho tháng cụ thể
  Future<void> loadBudgetsForMonth(int year, int month) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentYear = year;
      _currentMonth = month;

      // Lấy budgets từ DB
      final budgets = await _budgetRepo.getBudgetsByMonth(year, month);
      
      // Lấy tất cả categories
      final db = await _dbProvider.database;
      final categoriesRepo = CategoriesRepository(db);
      final categoryIdToName = await categoriesRepo.loadCategoryNames();

      // Lấy transactions cho tháng này
      final transactions = await _transactionRepo.getTransactionsByMonth(year, month);

      // Tính tổng chi tiêu theo category
      final Map<int, double> spentByCategory = {};
      for (final tx in transactions) {
        if (tx.type == 'expense' && tx.categoryId != null) {
          spentByCategory[tx.categoryId!] = 
              (spentByCategory[tx.categoryId!] ?? 0) + tx.amount.abs();
        }
      }

      // Build budget items
      _budgetItems = budgets.map((budget) {
        final categoryName = categoryIdToName[budget.categoryId] ?? 'Không xác định';
        final spent = spentByCategory[budget.categoryId] ?? 0;
        
        return BudgetItem(
          budgetId: budget.id ?? 0,
          categoryId: budget.categoryId,
          categoryName: categoryName,
          emoji: _getEmojiForCategory(categoryName),
          limit: budget.limitAmount.toDouble(),
          spent: spent,
          color: _getColorForCategory(categoryName),
          bgColor: _getBgColorForCategory(categoryName),
        );
      }).toList();

      // Nếu không có budget nào, tạo dữ liệu mẫu để demo
      if (_budgetItems.isEmpty) {
        await _createSampleBudgets(year, month, categoryIdToName);
        // Load lại sau khi tạo
        await loadBudgetsForMonth(year, month);
        return;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tạo budgets mẫu cho demo
  Future<void> _createSampleBudgets(
    int year,
    int month,
    Map<int, String> categoryIdToName,
  ) async {
    // Tìm category IDs theo tên
    final db = await _dbProvider.database;
    final categoriesRepo = CategoriesRepository(db);
    final nameToId = await categoriesRepo.getCategoryNameToIdMap();

    final sampleBudgets = [
      {'name': 'Ăn uống', 'limit': 5000000},
      {'name': 'Mua sắm', 'limit': 3000000},
      {'name': 'Di chuyển', 'limit': 2000000},
      {'name': 'Giải trí', 'limit': 1500000},
      {'name': 'Hóa đơn', 'limit': 1000000},
    ];

    for (final sample in sampleBudgets) {
      final categoryId = nameToId[sample['name']];
      if (categoryId != null) {
        final budget = Budget(
          categoryId: categoryId,
          limitAmount: sample['limit'] as int,
          month: month,
          year: year,
        );
        await _budgetRepo.insertBudget(budget);
      }
    }
  }

  /// Xóa budget
  Future<void> deleteBudget(int budgetId) async {
    try {
      await _budgetRepo.deleteBudget(budgetId);
      await loadBudgets();
    } catch (e) {
      _errorMessage = 'Lỗi khi xóa: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Thêm budget mới
  Future<void> addBudget(String categoryName, int limitAmount) async {
    try {
      final db = await _dbProvider.database;
      final categoriesRepo = CategoriesRepository(db);
      final categoryId = await categoriesRepo.getCategoryIdByName(categoryName);

      if (categoryId == null) {
        throw Exception('Không tìm thấy danh mục: $categoryName');
      }

      // Kiểm tra xem category này đã có budget chưa
      final existingBudget = await _budgetRepo.getBudgetByCategoryAndMonth(
        categoryId,
        _currentYear,
        _currentMonth,
      );

      if (existingBudget != null) {
        throw Exception('Danh mục này đã có hạn mức');
      }

      final budget = Budget(
        categoryId: categoryId,
        limitAmount: limitAmount,
        month: _currentMonth,
        year: _currentYear,
      );

      await _budgetRepo.insertBudget(budget);
      await loadBudgets();
    } catch (e) {
      _errorMessage = 'Lỗi khi thêm: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Cập nhật budget
  Future<void> updateBudget(int budgetId, int newLimitAmount) async {
    try {
      // Tìm budget hiện tại
      final allBudgets = await _budgetRepo.getBudgetsByMonth(_currentYear, _currentMonth);
      final budget = allBudgets.firstWhere((b) => b.id == budgetId);

      final updatedBudget = budget.copyWith(limitAmount: newLimitAmount);
      await _budgetRepo.updateBudget(updatedBudget);
      await loadBudgets();
    } catch (e) {
      _errorMessage = 'Lỗi khi cập nhật: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  /// Lấy danh sách categories có sẵn (chưa có budget)
  Future<List<String>> getAvailableCategories() async {
    try {
      final db = await _dbProvider.database;
      final categoriesRepo = CategoriesRepository(db);
      final allCategories = await categoriesRepo.getAllCategories();
      
      // Lọc chỉ lấy expense categories
      final expenseCategories = allCategories
          .where((cat) => cat['type'] == 'expense')
          .map((cat) => cat['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      return expenseCategories;
    } catch (e) {
      return [];
    }
  }

  /// Helpers
  String _getEmojiForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('ăn') || name.contains('uống')) return '🍜';
    if (name.contains('mua') || name.contains('sắm')) return '🛍️';
    if (name.contains('di') || name.contains('chuyển')) return '🚗';
    if (name.contains('giải') || name.contains('trí')) return '🎮';
    if (name.contains('hóa') || name.contains('đơn')) return '📄';
    if (name.contains('sức') || name.contains('khỏe')) return '💊';
    if (name.contains('học')) return '📚';
    return '📁';
  }

  Color _getColorForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('ăn') || name.contains('uống')) return const Color(0xFFFF6B6B);
    if (name.contains('mua') || name.contains('sắm')) return const Color(0xFF4ECDC4);
    if (name.contains('di') || name.contains('chuyển')) return const Color(0xFFFFD93D);
    if (name.contains('giải') || name.contains('trí')) return const Color(0xFF95E1D3);
    if (name.contains('hóa') || name.contains('đơn')) return const Color(0xFFC7CEEA);
    return const Color(0xFF9CA3AF);
  }

  Color _getBgColorForCategory(String categoryName) {
    final color = _getColorForCategory(categoryName);
    return color.withOpacity(0.13);
  }
}

/// Model cho mỗi budget item trong UI
class BudgetItem {
  final int budgetId;
  final int categoryId;
  final String categoryName;
  final String emoji;
  final double limit;
  final double spent;
  final Color color;
  final Color bgColor;

  BudgetItem({
    required this.budgetId,
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.limit,
    required this.spent,
    required this.color,
    required this.bgColor,
  });

  double get percentage => (spent / limit * 100).clamp(0, 100);
}
