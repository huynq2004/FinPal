import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finpal/ui/viewmodels/create_saving_goal_viewmodel.dart';
import 'package:finpal/domain/models/saving_goal.dart';
import 'package:finpal/ui/viewmodels/savings_goals_viewmodel.dart';

class CreateSavingGoalScreen extends StatelessWidget {
  const CreateSavingGoalScreen({super.key});

  String _formatCurrency(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final reverseIndex = str.length - i - 1;
      buffer.write(str[reverseIndex]);
      if ((i + 1) % 3 == 0 && i + 1 != str.length) buffer.write(',');
    }
    return '${buffer.toString().split('').reversed.join()} đ';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateSavingGoalViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tạo mục tiêu mới'),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer2<CreateSavingGoalViewModel, SavingsGoalsViewModel>(
            builder: (context, vm, savingsVm, child) {
              final suggestion = vm.targetAmount > 0
                  ? (vm.targetAmount /
                            (vm.deadline.difference(DateTime.now()).inDays / 7)
                                .clamp(1, 999))
                        .ceil()
                  : (vm.nameController.text.isNotEmpty
                        ? savingsVm.suggestionFor(
                            SavingGoal(
                              id: null,
                              name: vm.nameController.text,
                              targetAmount: 0,
                              currentSaved: 0,
                              deadline: vm.deadline,
                              createdAt: DateTime.now(),
                            ),
                          )
                        : 0);

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Name
                  const Text(
                    'Tên mục tiêu',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: vm.nameController,
                    decoration: InputDecoration(
                      hintText: 'Mua tai nghe mới',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  const Text(
                    'Số tiền cần đạt',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: vm.amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '3000000',
                      suffixText: '₫',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Deadline
                  const Text(
                    'Thời hạn',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: vm.deadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (picked != null) vm.setDeadline(picked);
                    },
                    child: Container(
                      height: 57,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        color: Colors.white,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${vm.deadline.day}/${vm.deadline.month}/${vm.deadline.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Frequency
                  const Text(
                    'Tần suất góp',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                vm.setFrequency(SavingFrequency.weekly),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: vm.frequency == SavingFrequency.weekly
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Theo tuần',
                                style: TextStyle(
                                  color: vm.frequency == SavingFrequency.weekly
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                vm.setFrequency(SavingFrequency.monthly),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: vm.frequency == SavingFrequency.monthly
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Theo tháng',
                                style: TextStyle(
                                  color: vm.frequency == SavingFrequency.monthly
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // AI suggestion box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3E8FF)),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFAF5FF), Color(0xFFF1F6FF)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.smart_toy,
                              color: Color(0xFF0F172A),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Gợi ý từ AI',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Gợi ý:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatCurrency(suggestion),
                                    style: const TextStyle(
                                      color: Color(0xFF3E8AFF),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'mỗi tuần',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Dựa trên thời hạn và số dư hiện tại của bạn',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  const Text(
                    'Danh mục (tùy chọn)',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: vm.category,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Du lịch',
                        child: Text('Du lịch'),
                      ),
                      DropdownMenuItem(
                        value: 'Mua sắm',
                        child: Text('Mua sắm'),
                      ),
                      DropdownMenuItem(
                        value: 'Giáo dục',
                        child: Text('Giáo dục'),
                      ),
                      DropdownMenuItem(
                        value: 'Sức khỏe',
                        child: Text('Sức khỏe'),
                      ),
                      DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                    ],
                    onChanged: (val) => vm.setCategory(val ?? 'Khác'),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: const Color(0xFF3E8AFF),
                    ),
                    onPressed: () {
                      if (!vm.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Vui lòng điền tên và số tiền hợp lệ.',
                            ),
                          ),
                        );
                        return;
                      }

                      final newGoal = vm.buildGoal();

                      // Return the created goal to caller; caller (list screen) will append it to list via viewmodel
                      Navigator.of(context).pop(newGoal);
                    },
                    child: const Text(
                      'Tạo mục tiêu',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Color(0xFF64748B)),
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
}
