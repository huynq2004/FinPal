// lib/ui/screens/savings_goals_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finpal/ui/viewmodels/savings_goals_viewmodel.dart';
import 'package:finpal/domain/models/saving_goal.dart';
import 'package:finpal/data/repositories/saving_goal_repository.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  String _formatCurrency(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final reverseIndex = str.length - i - 1;
      buffer.write(str[reverseIndex]);
      if ((i + 1) % 3 == 0 && i + 1 != str.length) {
        buffer.write(',');
      }
    }
    return '${buffer.toString().split('').reversed.join()} đ';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = SavingsGoalsViewModel(SavingGoalRepository());
        vm.loadGoals(); // ✅ load qua repository
        return vm;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Hũ tiết kiệm')),
        body: Consumer<SavingsGoalsViewModel>(
          builder: (context, vm, child) {
            if (vm.goals.isEmpty) {
              return const Center(child: Text('Chưa có hũ tiết kiệm nào.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.goals.length,
              itemBuilder: (context, index) {
                final SavingGoal goal = vm.goals[index];
                final progress = vm.progressOf(goal);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Mục tiêu: ${_formatCurrency(goal.targetAmount)}'),
                        Text(
                          'Đã tiết kiệm: ${_formatCurrency(goal.currentSaved)}',
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: progress, minHeight: 8),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
