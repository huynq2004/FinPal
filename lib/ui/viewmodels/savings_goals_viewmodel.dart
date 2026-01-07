import 'package:flutter/foundation.dart';
import 'package:finpal/domain/models/saving_goal.dart';
import 'package:finpal/data/repositories/saving_goal_repository.dart';

class SavingsGoalsViewModel extends ChangeNotifier {
  final SavingGoalRepository _repository;

  SavingsGoalsViewModel(this._repository);

  List<SavingGoal> _goals = [];
  List<SavingGoal> get goals => _goals;

  int get totalGoals => _goals.length;

  int get totalSaved => _goals.fold(0, (s, g) => s + g.currentSaved);

  /// For demo purposes return a suggested weekly saving for a goal.
  int suggestionFor(SavingGoal goal) {
    final name = goal.name.toLowerCase();
    if (name.contains('tai nghe') || name.contains('tai nghe mới'))
      return 250000;
    if (name.contains('đà lạt') || name.contains('đà nẵng')) return 300000;
    if (name.contains('laptop')) return 500000;
    return 200000;
  }

  /// Tính gợi ý tiết kiệm hàng tuần dựa trên mục tiêu còn lại và deadline
  int calculateSuggestedWeekly(SavingGoal goal) {
    final needed = goal.targetAmount - goal.currentSaved;
    if (needed <= 0) return 0;

    final now = DateTime.now();
    final daysRemaining = goal.deadline.difference(now).inDays;
    if (daysRemaining <= 0)
      return needed; // Deadline đã hết, phải tiết kiệm hết ngay

    final weeksRemaining = (daysRemaining / 7).ceil().clamp(1, 999999);
    return (needed / weeksRemaining).ceil();
  }

  Future<void> loadGoals() async {
    // ✅ Load from real database
    _goals = await _repository.getAllGoals();
    notifyListeners();
  }

  /// Tạo mới một mục tiêu tiết kiệm và lưu vào database
  Future<void> addGoal({
    required String name,
    required int targetAmount,
    int initialSaved = 0,
    DateTime? deadline,
    DateTime? createdAt,
  }) async {
    final goal = SavingGoal(
      id: null, // Database sẽ tự tạo ID
      name: name,
      targetAmount: targetAmount,
      currentSaved: initialSaved,
      createdAt: createdAt ?? DateTime.now(),
      deadline: deadline ?? DateTime.now().add(const Duration(days: 90)),
    );

    // Lưu vào database
    final goalId = await _repository.createGoal(goal);

    // Lấy lại goal với ID mới
    final createdGoal = await _repository.getGoalById(goalId);

    if (createdGoal != null) {
      _goals = [..._goals, createdGoal];
      notifyListeners();
    }
  }

  double progressOf(SavingGoal goal) {
    return goal.currentSaved / goal.targetAmount;
  }

  /// Cập nhật một mục tiêu hiện có theo `id` và lưu vào database
  Future<void> updateGoal(SavingGoal updated) async {
    if (updated.id == null) return;

    // Cập nhật database
    await _repository.updateGoal(updated);

    // Cập nhật local state
    _goals = _goals.map((g) => g.id == updated.id ? updated : g).toList();
    notifyListeners();
  }

  /// Xoá một mục tiêu theo `id` và xóa khỏi database
  Future<void> deleteGoal(int id) async {
    // Xóa khỏi database
    await _repository.deleteGoal(id);

    // Xoá trên bộ nhớ local
    _goals = _goals.where((g) => g.id != id).toList();
    notifyListeners();
  }

  /// Thêm tiền vào hũ tiết kiệm
  Future<void> addSavings(int goalId, int amount) async {
    await _repository.addSavingsToGoal(goalId, amount);

    // Reload goal để cập nhật currentSaved
    final updatedGoal = await _repository.getGoalById(goalId);
    if (updatedGoal != null) {
      _goals = _goals.map((g) => g.id == goalId ? updatedGoal : g).toList();
      notifyListeners();
    }
  }

  /// Rút tiền từ hũ tiết kiệm
  Future<void> withdrawSavings(int goalId, int amount, {String? note}) async {
    await _repository.withdrawFromGoal(goalId, amount, note: note);

    // Reload goal để cập nhật currentSaved
    final updatedGoal = await _repository.getGoalById(goalId);
    if (updatedGoal != null) {
      _goals = _goals.map((g) => g.id == goalId ? updatedGoal : g).toList();
      notifyListeners();
    }
  }
}
