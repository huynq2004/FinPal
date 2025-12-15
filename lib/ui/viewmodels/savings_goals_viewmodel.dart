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
    if (name.contains('tai nghe') || name.contains('tai nghe mới')) return 250000;
    if (name.contains('đà lạt') || name.contains('đà nẵng')) return 300000;
    if (name.contains('laptop')) return 500000;
    return 200000;
  }

  Future<void> loadGoals() async {
    // ✅ Sprint 1: fake data qua repository
    _goals = await _repository.getFakeGoals();
    notifyListeners();
  }

  double progressOf(SavingGoal goal) {
    return goal.currentSaved / goal.targetAmount;
  }
}
