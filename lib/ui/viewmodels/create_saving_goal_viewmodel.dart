import 'package:flutter/material.dart';
import 'package:finpal/domain/models/saving_goal.dart';

enum SavingFrequency { weekly, monthly }

class CreateSavingGoalViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  DateTime deadline = DateTime.now().add(const Duration(days: 90));
  SavingFrequency frequency = SavingFrequency.weekly;
  String category = 'Khác';

  void setDeadline(DateTime d) {
    deadline = d;
    notifyListeners();
  }

  void setFrequency(SavingFrequency f) {
    frequency = f;
    notifyListeners();
  }

  void setCategory(String c) {
    category = c;
    notifyListeners();
  }

  int get targetAmount {
    final raw = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }

  /// Basic validation
  bool validate() {
    return nameController.text.trim().isNotEmpty && targetAmount > 0;
  }

  /// Build a SavingGoal object (id left null so repository/viewmodel assigns it)
  SavingGoal buildGoal() {
    return SavingGoal(
      id: null,
      name: nameController.text.trim(),
      targetAmount: targetAmount,
      currentSaved: 0,
      deadline: deadline,
      createdAt: DateTime.now(),
    );
  }

  void disposeControllers() {
    nameController.dispose();
    amountController.dispose();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }
}
