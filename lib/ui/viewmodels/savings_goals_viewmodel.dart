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

  Future<void> loadGoals() async {
    // ✅ Sprint 1: fake data qua repository
    _goals = await _repository.getFakeGoals();
    notifyListeners();
  }

  /// Tạo mới một mục tiêu tiết kiệm (tạm thời chỉ lưu trên RAM cho Sprint 1).
  ///
  /// Trong các sprint sau có thể gọi xuống [_repository] để lưu xuống DB thật.
  void addGoal({
    required String name,
    required int targetAmount,
    int initialSaved = 0,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    // Tạo id tạm thời dựa trên length hiện tại.
    final newId = (_goals.isEmpty ? 0 : _goals.last.id ?? 0) + 1;

    final goal = SavingGoal(
      id: newId,
      name: name,
      targetAmount: targetAmount,
      currentSaved: initialSaved,
      createdAt: createdAt ?? DateTime.now(),
      deadline: deadline ?? DateTime.now().add(const Duration(days: 90)),
    );

    _goals = [..._goals, goal];
    notifyListeners();
  }

  double progressOf(SavingGoal goal) {
    return goal.currentSaved / goal.targetAmount;
  }

  /// Cập nhật một mục tiêu hiện có theo `id`.
  void updateGoal(SavingGoal updated) {
    if (updated.id == null) return;
    _goals = _goals.map((g) => g.id == updated.id ? updated : g).toList();
    notifyListeners();
  }

  /// Xoá một mục tiêu theo `id`.
  Future<void> deleteGoal(int id) async {
    // Best-effort xóa dưới DB thật (nếu đang dùng DB)
    try {
      await _repository.deleteGoal(id);
    } catch (_) {
      // Sprint 1: có thể chưa dùng DB, bỏ qua lỗi.
    }

    // Xoá trên bộ nhớ
    _goals = _goals.where((g) => g.id != id).toList();
    notifyListeners();
  }
}
