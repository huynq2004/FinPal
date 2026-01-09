import 'package:sqflite/sqflite.dart';

class CategoriesRepository {
  final Database db;
  CategoriesRepository(this.db);

  Future<Map<int, String>> loadCategoryNames() async {
    final rows = await db.query('categories', columns: ['id', 'name']);
    final map = <int, String>{};
    for (final r in rows) {
      final id = r['id'] is int ? r['id'] as int : int.parse(r['id'].toString());
      final name = r['name']?.toString() ?? 'Không phân loại';
      map[id] = name;
    }
    return map;
  }

  /// Lấy tất cả categories và trả về map từ name -> id
  Future<Map<String, int>> getCategoryNameToIdMap() async {
    final rows = await db.query('categories', columns: ['id', 'name']);
    final map = <String, int>{};
    for (final r in rows) {
      final id = r['id'] is int ? r['id'] as int : int.parse(r['id'].toString());
      final name = r['name']?.toString() ?? '';
      if (name.isNotEmpty) {
        map[name] = id;
      }
    }
    return map;
  }

  /// Tìm category ID theo tên
  Future<int?> getCategoryIdByName(String name) async {
    final rows = await db.query(
      'categories',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }

  /// Lấy tất cả categories
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    return await db.query('categories');
  }

  /// Lấy categories theo type (expense/income)
  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    return await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
  }

  /// Thêm category mới
  Future<int> addCategory({
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    return await db.insert(
      'categories',
      {
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Cập nhật category
  Future<int> updateCategory({
    required int id,
    String? name,
    String? icon,
    String? color,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (icon != null) updates['icon'] = icon;
    if (color != null) updates['color'] = color;

    if (updates.isEmpty) return 0;

    return await db.update(
      'categories',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Xóa category
  /// Trả về số dòng bị ảnh hưởng
  Future<int> deleteCategory(int id) async {
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Kiểm tra category có đang được sử dụng không
  Future<bool> isCategoryInUse(int id) async {
    final result = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Đếm số giao dịch của category
  Future<int> getTransactionCount(int id) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE category_id = ?',
      [id],
    );
    return result.isNotEmpty ? (result.first['count'] as int?) ?? 0 : 0;
  }

  /// Lấy một category theo ID
  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    final results = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
}