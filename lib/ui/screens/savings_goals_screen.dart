// lib/ui/screens/savings_goals_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finpal/ui/viewmodels/savings_goals_viewmodel.dart';
import 'package:finpal/domain/models/saving_goal.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  String _formatCurrency(int value) {
    // đơn giản: 1500000 -> "1,500,000 đ"
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final reverseIndex = str.length - i - 1;
      buffer.write(str[reverseIndex]);

      if ((i + 1) % 3 == 0 && i + 1 != str.length) {
        buffer.write(',');
      }
    }
    final formatted = buffer.toString().split('').reversed.join('');
    return '$formatted đ';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SavingsGoalsViewModel(),
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
                final goal = vm.goals[index];
                final progress = vm.calculateProgress(goal);

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mục tiêu: ${_formatCurrency(goal.targetAmount)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Đã tiết kiệm: ${_formatCurrency(goal.currentSaved)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall,
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
