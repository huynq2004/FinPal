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
        name: 'Mua laptop mới',
        targetAmount: 15000000,
        currentSaved: 3000000,
        deadline: DateTime.now().add(const Duration(days: 120)),
        createdAt: DateTime.now(),
      ),
      SavingGoal(
        id: 2,
        name: 'Du lịch Đà Nẵng',
        targetAmount: 8000000,
        currentSaved: 2000000,
        deadline: DateTime.now().add(const Duration(days: 90)),
        createdAt: DateTime.now(),
      ),
    ];
  }
}
