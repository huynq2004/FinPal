import 'package:finpal/domain/models/transaction.dart';
import 'package:finpal/data/db/database_provider.dart';

class TransactionRepository {
  final DatabaseProvider _dbProvider;

  TransactionRepository(this._dbProvider);

  Future<List<Transaction>> getAllTransactions() async {
    try {
      final db = await _dbProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        orderBy: 'created_at DESC',
      );
      return _mapToTransactions(maps);
    } catch (e) {
      // Nếu bảng chưa tồn tại, trả về danh sách rỗng
      return [];
    }
  }

  Future<Transaction> insertTransaction(Transaction transaction) async {
    try {
      final db = await _dbProvider.database;
      final map = transaction.toMap();
      // Loại bỏ id khi insert vì id sẽ được tự động tạo
      map.remove('id');
      final id = await db.insert('transactions', map);
      return transaction.copyWith(id: id);
    } catch (e) {
      throw Exception('Lỗi khi thêm giao dịch: ${e.toString()}');
    }
  }

  Future<int> updateTransaction(Transaction transaction) async {
    if (transaction.id == null) {
      throw Exception('Cannot update transaction without id');
    }
    try {
      final db = await _dbProvider.database;
      final map = transaction.toMap();
      // Loại bỏ id khỏi map khi update vì không nên update id
      map.remove('id');
      final result = await db.update(
        'transactions',
        map,
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      return result;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật giao dịch: ${e.toString()}');
    }
  }

  Future<int> deleteTransaction(int id) async {
    try {
      final db = await _dbProvider.database;
      return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Lỗi khi xóa giao dịch: ${e.toString()}');
    }
  }

  Future<Transaction?> getTransactionById(int id) async {
    try {
      final db = await _dbProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Transaction.fromMap(maps.first);
    } catch (e) {
      throw Exception('Lỗi khi lấy giao dịch: ${e.toString()}');
    }
  }

  Future<List<Transaction>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await _dbProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'created_at >= ? AND created_at <= ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'created_at DESC',
      );
      return _mapToTransactions(maps);
    } catch (e) {
      throw Exception(
        'Lỗi khi lấy giao dịch theo khoảng thời gian: ${e.toString()}',
      );
    }
  }

  Future<List<Transaction>> getTransactionsByType(String type) async {
    try {
      final db = await _dbProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'created_at DESC',
      );
      return _mapToTransactions(maps);
    } catch (e) {
      throw Exception('Lỗi khi lấy giao dịch theo loại: ${e.toString()}');
    }
  }

  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    try {
      final db = await _dbProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'created_at DESC',
      );
      return _mapToTransactions(maps);
    } catch (e) {
      throw Exception('Lỗi khi lấy giao dịch theo danh mục: ${e.toString()}');
    }
  }

  Future<List<Transaction>> getTransactionsByMonth(int year, int month) async {
    try {
      final db = await _dbProvider.database;
      
      // Tính ngày đầu và cuối của tháng
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
      
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'created_at >= ? AND created_at <= ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'created_at DESC',
      );
      return _mapToTransactions(maps);
    } catch (e) {
      throw Exception('Lỗi khi lấy giao dịch theo tháng: ${e.toString()}');
    }
  }

  // Helper method để giảm code duplication
  List<Transaction> _mapToTransactions(List<Map<String, dynamic>> maps) {
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }
}
