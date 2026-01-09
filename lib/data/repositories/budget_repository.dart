import 'package:sqflite/sqflite.dart';
import '../../domain/models/budget.dart';
import '../db/database_provider.dart';

class BudgetRepository {
  final DatabaseProvider _dbProvider;

  BudgetRepository(this._dbProvider);

  /// Lấy tất cả budgets
  Future<List<Budget>> getAllBudgets() async {
    final db = await _dbProvider.database;
    final results = await db.query('budgets');
    return results.map((row) => Budget.fromMap(row)).toList();
  }

  /// Lấy budgets theo tháng và năm
  Future<List<Budget>> getBudgetsByMonth(int year, int month) async {
    final db = await _dbProvider.database;
    final results = await db.query(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );
    return results.map((row) => Budget.fromMap(row)).toList();
  }

  /// Lấy budget theo category ID và tháng/năm
  Future<Budget?> getBudgetByCategoryAndMonth(
    int categoryId,
    int year,
    int month,
  ) async {
    final db = await _dbProvider.database;
    final results = await db.query(
      'budgets',
      where: 'category_id = ? AND year = ? AND month = ?',
      whereArgs: [categoryId, year, month],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Budget.fromMap(results.first);
  }

  /// Thêm budget mới
  Future<Budget> insertBudget(Budget budget) async {
    final db = await _dbProvider.database;
    final id = await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return budget.copyWith(id: id);
  }

  /// Cập nhật budget
  Future<void> updateBudget(Budget budget) async {
    final db = await _dbProvider.database;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  /// Xóa budget
  Future<void> deleteBudget(int id) async {
    final db = await _dbProvider.database;
    await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Lấy tổng limit amount cho tháng
  Future<int> getTotalLimitByMonth(int year, int month) async {
    final budgets = await getBudgetsByMonth(year, month);
    return budgets.fold<int>(0, (sum, budget) => sum + budget.limitAmount);
  }
}
