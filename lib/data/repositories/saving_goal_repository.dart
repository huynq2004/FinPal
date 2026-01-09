import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/domain/models/saving_goal.dart';
import 'package:finpal/domain/models/saving_history.dart';

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

  // ========================
  // CRUD OPERATIONS
  // ========================

  /// Tạo mới saving goal
  Future<int> createGoal(SavingGoal goal) async {
    final db = await _dbProvider.database;
    final data = goal.toMap();
    data.remove('id'); // Auto increment
    return await db.insert('saving_goals', data);
  }

  /// Cập nhật saving goal
  Future<int> updateGoal(SavingGoal goal) async {
    final db = await _dbProvider.database;
    return await db.update(
      'saving_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  /// Thêm tiền vào hũ tiết kiệm
  Future<int> addSavingsToGoal(int goalId, int amount) async {
    final db = await _dbProvider.database;

    // Lấy thông tin goal hiện tại
    final goalData = await db.query(
      'saving_goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );

    if (goalData.isEmpty) {
      throw Exception('Goal with id $goalId not found');
    }

    final goal = SavingGoal.fromMap(goalData.first);
    final newAmount = goal.currentSaved + amount;

    // Tạo history record
    final history = SavingHistory(
      goalId: goalId,
      amount: amount,
      type: 'add',
      note: null,
      createdAt: DateTime.now(),
    );

    // Lưu history
    await _addHistory(history);

    // Cập nhật số tiền đã tiết kiệm
    return await db.update(
      'saving_goals',
      {'current_saved': newAmount},
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  /// Lấy goal theo ID
  Future<SavingGoal?> getGoalById(int id) async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'saving_goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return SavingGoal.fromMap(result.first);
  }

  // ========================
  // BUSINESS LOGIC
  // ========================

  /// Lấy danh sách goals sắp xếp theo % hoàn thành
  Future<List<SavingGoal>> getGoalsByProgress() async {
    final goals = await getAllGoals();

    // Sắp xếp theo % hoàn thành (cao → thấp)
    goals.sort((a, b) {
      final progressA = (a.currentSaved / a.targetAmount) * 100;
      final progressB = (b.currentSaved / b.targetAmount) * 100;
      return progressB.compareTo(progressA);
    });

    return goals;
  }

  /// Lấy danh sách goals sắp hết hạn (cảnh báo)
  /// [daysThreshold] số ngày tính từ hôm nay
  Future<List<SavingGoal>> getGoalsNearDeadline(int daysThreshold) async {
    final goals = await getAllGoals();
    final now = DateTime.now();
    final thresholdDate = now.add(Duration(days: daysThreshold));

    // Lọc các goals có deadline trong khoảng threshold và chưa hoàn thành
    final nearDeadlineGoals = goals.where((goal) {
      final isNearDeadline =
          goal.deadline.isBefore(thresholdDate) ||
          goal.deadline.isAtSameMomentAs(thresholdDate);
      final isNotCompleted = goal.currentSaved < goal.targetAmount;
      return isNearDeadline && isNotCompleted;
    }).toList();

    // Sắp xếp theo deadline (gần nhất trước)
    nearDeadlineGoals.sort((a, b) => a.deadline.compareTo(b.deadline));

    return nearDeadlineGoals;
  }

  /// Tính % hoàn thành của goal
  double getProgressPercentage(SavingGoal goal) {
    if (goal.targetAmount == 0) return 0.0;
    return (goal.currentSaved / goal.targetAmount) * 100;
  }

  // ========================
  // SAVINGS HISTORY TRACKING
  // ========================

  /// Lưu history record (private helper)
  Future<int> _addHistory(SavingHistory history) async {
    final db = await _dbProvider.database;
    final data = history.toMap();
    data.remove('id'); // Auto increment
    return await db.insert('saving_history', data);
  }

  /// Lấy lịch sử tiết kiệm của một goal
  Future<List<SavingHistory>> getHistoryByGoalId(int goalId) async {
    final db = await _dbProvider.database;
    final result = await db.query(
      'saving_history',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'created_at DESC',
    );

    return result.map((e) => SavingHistory.fromMap(e)).toList();
  }

  /// Rút tiền từ hũ tiết kiệm
  Future<int> withdrawFromGoal(int goalId, int amount, {String? note}) async {
    final db = await _dbProvider.database;

    // Lấy thông tin goal hiện tại
    final goalData = await db.query(
      'saving_goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );

    if (goalData.isEmpty) {
      throw Exception('Goal with id $goalId not found');
    }

    final goal = SavingGoal.fromMap(goalData.first);

    if (goal.currentSaved < amount) {
      throw Exception(
        'Insufficient savings. Current: ${goal.currentSaved}, Requested: $amount',
      );
    }

    final newAmount = goal.currentSaved - amount;

    // Tạo history record (số âm)
    final history = SavingHistory(
      goalId: goalId,
      amount: -amount,
      type: 'withdraw',
      note: note,
      createdAt: DateTime.now(),
    );

    // Lưu history
    await _addHistory(history);

    // Cập nhật số tiền đã tiết kiệm
    return await db.update(
      'saving_goals',
      {'current_saved': newAmount},
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  /// Xóa tất cả history của một goal (khi xóa goal)
  Future<int> deleteHistoryByGoalId(int goalId) async {
    final db = await _dbProvider.database;
    return await db.delete(
      'saving_history',
      where: 'goal_id = ?',
      whereArgs: [goalId],
    );
  }
}
