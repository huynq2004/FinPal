import 'package:flutter/foundation.dart';
import 'package:finpal/domain/models/saving_goal.dart';
import 'package:finpal/data/repositories/saving_goal_repository.dart';

class SavingsGoalsViewModel extends ChangeNotifier {
  final SavingGoalRepository _repository;

  SavingsGoalsViewModel(this._repository);

  List<SavingGoal> _goals = [];
  List<SavingGoal> get goals => _goals;

  Future<void> loadGoals() async {
    // ✅ Sprint 1: fake data qua repository
    _goals = await _repository.getFakeGoals();
    notifyListeners();
  }

  double progressOf(SavingGoal goal) {
    return goal.currentSaved / goal.targetAmount;
  }
}
