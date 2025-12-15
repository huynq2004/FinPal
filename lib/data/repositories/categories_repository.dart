import 'package:sqflite/sqflite.dart';

class CategoriesRepository {
  final Database db;
  CategoriesRepository(this.db);

  Future<Map<int, String>> loadCategoryNames() async {
//     final rows = await db.query('categories', columns: ['id', 'name']);
//     final map = <int, String>{};
//     for (final r in rows) {
//       final id = r['id'] is int ? r['id'] as int : int.parse(r['id'].toString());
//       final name = r['name']?.toString() ?? 'Không phân loại';
//       map[id] = name;
//     }
//     return map;
//   }
// }
  // Temporary fake data for testing
await Future.delayed(const Duration(milliseconds: 100));
    return {
      1: 'Di chuyển',
      2: 'Ăn uống',
      3: 'Thu nhập',
    };
  }
}