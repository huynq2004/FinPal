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
}