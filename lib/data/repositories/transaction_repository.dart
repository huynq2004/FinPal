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

  /// Kiểm tra xem giao dịch đã tồn tại hay chưa
  /// Rule: amount + time ±1 phút + bank + content (note)
  Future<bool> isDuplicateTransaction({
    required int amount,
    required DateTime time,
    String? bank,
    String? content,
  }) async {
    try {
      final db = await _dbProvider.database;
      
      // Tính thời gian ±1 phút
      final startTime = time.subtract(const Duration(minutes: 1));
      final endTime = time.add(const Duration(minutes: 1));
      
      // Query tìm giao dịch trùng
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'amount = ? AND created_at >= ? AND created_at <= ?',
        whereArgs: [
          amount,
          startTime.toIso8601String(),
          endTime.toIso8601String(),
        ],
      );
      
      // Nếu không có giao dịch nào trong khoảng thời gian → không trùng
      if (maps.isEmpty) return false;
      
      // Kiểm tra thêm bank và content
      for (final map in maps) {
        final existingBank = map['bank'] as String?;
        final existingNote = map['note'] as String?;
        
        // So sánh bank (bỏ qua nếu một trong hai null)
        final bankMatch = (bank == null || existingBank == null) 
            ? true 
            : bank.toLowerCase() == existingBank.toLowerCase();
        
        // So sánh content/note (bỏ qua nếu một trong hai null)
        final contentMatch = (content == null || existingNote == null)
            ? true
            : content.toLowerCase() == existingNote.toLowerCase();
        
        // Nếu tất cả điều kiện match → là trùng
        if (bankMatch && contentMatch) {
          print('⚠️ [TransactionRepo] Phát hiện giao dịch trùng: amount=$amount, time=$time, bank=$bank');
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('❌ [TransactionRepo] Lỗi khi kiểm tra trùng: ${e.toString()}');
      // Nếu có lỗi, cho phép thêm giao dịch (fail-safe)
      return false;
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
  
  /// Insert transaction với kiểm tra trùng lặp
  /// Trả về null nếu giao dịch đã tồn tại (duplicate)
  Future<Transaction?> insertTransactionIfNotDuplicate(Transaction transaction) async {
    try {
      // Kiểm tra trùng lặp
      final isDuplicate = await isDuplicateTransaction(
        amount: transaction.amount,
        time: transaction.createdAt,
        bank: transaction.bank,
        content: transaction.note,
      );
      
      if (isDuplicate) {
        print('⏭️ [TransactionRepo] Bỏ qua giao dịch trùng lặp');
        return null; // Trả về null để báo hiệu đã tồn tại
      }
      
      // Nếu không trùng, thêm mới
      return await insertTransaction(transaction);
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
