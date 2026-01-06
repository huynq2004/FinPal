// lib/ui/screens/savings_goals_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finpal/ui/viewmodels/savings_goals_viewmodel.dart';
import 'package:finpal/domain/models/saving_goal.dart';
import 'package:finpal/data/repositories/saving_goal_repository.dart';
import 'package:finpal/ui/screens/create_saving_goal_screen.dart';
import 'package:finpal/ui/screens/saving_goal_detail_screen.dart';

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
      create: (q_) {
        final vm = SavingsGoalsViewModel(SavingGoalRepository());
        vm.loadGoals(); // ✅ load qua repository
        return vm;
      },
      child: Scaffold(
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              onPressed: () => _openCreateGoalScreen(context),
              icon: const Icon(Icons.add),
              label: const Text('Tạo mục tiêu'),
            );
          },
        ),
        body: SafeArea(
          child: Consumer<SavingsGoalsViewModel>(
            builder: (context, vm, child) {
              if (vm.goals.isEmpty) {
                return const Center(child: Text('Chưa có hũ tiết kiệm nào.'));
              }

              return Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0x29FFFFFF),
                              child: Icon(
                                Icons.savings_outlined,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Mục tiêu tiết kiệm',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Đặt mục tiêu và theo dõi tiến độ tiết kiệm',
                          style: TextStyle(color: Color(0xE6FFFFFF)),
                        ),
                      ],
                    ),
                  ),

                  // Summary card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 6,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tổng mục tiêu',
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${vm.totalGoals}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Đã tiết kiệm',
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatCurrency(vm.totalSaved),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2ECC71),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Goals list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: vm.goals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final SavingGoal goal = vm.goals[index];
                        final progress = vm.progressOf(goal).clamp(0.0, 1.0);
                        final suggestion = vm.calculateSuggestedWeekly(goal);

                        return GestureDetector(
                          onTap: () async {
                            final vm = context.read<SavingsGoalsViewModel>();
                            final deleted = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: vm,
                                  child: SavingGoalDetailScreen(goal: goal),
                                ),
                              ),
                            );
                            if (deleted == true && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã xóa mục tiêu.'),
                                  backgroundColor: Color(0xFFFF5A5F),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            goal.name,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Mục tiêu: ${_formatCurrency(goal.targetAmount)}',
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatCurrency(goal.currentSaved),
                                          style: const TextStyle(
                                            color: Color(0xFF2ECC71),
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(progress * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Progress bar background
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width:
                                              constraints.maxWidth * progress,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF3E8AFF),
                                                Color(0xFF325DFF),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(999),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.trending_up,
                                        color: Color(0xFF3E8AFF),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Gợi ý: ${_formatCurrency(suggestion)} / tuần',
                                          style: const TextStyle(
                                            color: Color(0xFF3E8AFF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateGoalScreen(BuildContext context) async {
    final savingsVm = context.read<SavingsGoalsViewModel>();

    final result = await Navigator.of(context).push<SavingGoal?>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: savingsVm,
          child: const CreateSavingGoalScreen(),
        ),
      ),
    );

    if (result != null && context.mounted) {
      // Save to database via viewmodel
      await context.read<SavingsGoalsViewModel>().addGoal(
        name: result.name,
        targetAmount: result.targetAmount,
        initialSaved: result.currentSaved,
        deadline: result.deadline,
        createdAt: result.createdAt,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã tạo mục tiêu mới!'),
            backgroundColor: Color(0xFF2ECC71),
          ),
        );
      }
    }
  }
}
