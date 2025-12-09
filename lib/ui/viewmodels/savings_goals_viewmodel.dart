// lib/ui/viewmodels/savings_goals_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:finpal/domain/models/saving_goal.dart';

class SavingsGoalsViewModel extends ChangeNotifier {
  List<SavingGoal> _goals = [];

  List<SavingGoal> get goals => _goals;

  SavingsGoalsViewModel() {
    _loadDummyGoals();
  }

  void _loadDummyGoals() {
    _goals = [
      SavingGoal(
        id: 1,
        name: 'Mua laptop mới',
        targetAmount: 15000000,
        currentSaved: 3000000,
        deadline: DateTime.now().add(const Duration(days: 120)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      SavingGoal(
        id: 2,
        name: 'Du lịch Đà Nẵng',
        targetAmount: 8000000,
        currentSaved: 2000000,
        deadline: DateTime.now().add(const Duration(days: 90)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      SavingGoal(
        id: 3,
        name: 'Quỹ khẩn cấp',
        targetAmount: 20000000,
        currentSaved: 5000000,
        deadline: DateTime.now().add(const Duration(days: 365)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    notifyListeners();
  }

  double calculateProgress(SavingGoal goal) {
    if (goal.targetAmount <= 0) return 0;
    final p = goal.currentSaved / goal.targetAmount;
    if (p < 0) return 0;
    if (p > 1) return 1;
    return p;
  }
}
