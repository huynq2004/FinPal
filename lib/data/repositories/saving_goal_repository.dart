import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/domain/models/saving_goal.dart';

class SavingGoalRepository {
  final _dbProvider = DatabaseProvider.instance;

  Future<List<SavingGoal>> getAllGoals() async {
    final db = await _dbProvider.database;

    final result = await db.query('saving_goals');

    return result.map((e) => SavingGoal.fromMap(e)).toList();
  }

  // ✅ Hàm fake data cho Sprint 1 (rất quan trọng)
  Future<List<SavingGoal>> getFakeGoals() async {
    return [
      SavingGoal(
        id: 1,
        name: 'Mua tai nghe mới',
        targetAmount: 3000000,
        currentSaved: 1200000,
        deadline: DateTime.now().add(const Duration(days: 60)),
        createdAt: DateTime.now(),
      ),
      SavingGoal(
        id: 2,
        name: 'Du lịch Đà Lạt',
        targetAmount: 5000000,
        currentSaved: 3500000,
        deadline: DateTime.now().add(const Duration(days: 45)),
        createdAt: DateTime.now(),
      ),
      SavingGoal(
        id: 3,
        name: 'Laptop mới',
        targetAmount: 20000000,
        currentSaved: 5000000,
        deadline: DateTime.now().add(const Duration(days: 120)),
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<int> deleteGoal(int id) async {
    final db = await _dbProvider.database;
    return db.delete('saving_goals', where: 'id = ?', whereArgs: [id]);
  }
}
