// lib/ui/screens/edit_saving_goal_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finpal/domain/models/saving_goal.dart';
import 'package:finpal/ui/viewmodels/savings_goals_viewmodel.dart';

class EditSavingGoalScreen extends StatefulWidget {
  final SavingGoal goal;
  const EditSavingGoalScreen({super.key, required this.goal});

  @override
  State<EditSavingGoalScreen> createState() => _EditSavingGoalScreenState();
}

class _EditSavingGoalScreenState extends State<EditSavingGoalScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late DateTime _deadline;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _amountController = TextEditingController(
      text: widget.goal.targetAmount.toString(),
    );
    _deadline = widget.goal.deadline;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

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

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline.isBefore(DateTime.now())
          ? DateTime.now()
          : _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _save() {
    final name = _nameController.text.trim();
    final target = int.tryParse(_amountController.text.trim()) ?? 0;

    if (name.isEmpty || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên và số tiền hợp lệ.')),
      );
      return;
    }

    final updated = widget.goal.copyWith(
      name: name,
      targetAmount: target,
      deadline: _deadline,
    );

    context.read<SavingsGoalsViewModel>().updateGoal(updated);
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Chỉnh sửa mục tiêu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x263E8AFF),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.savings_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.goal.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mục tiêu',
                          style: TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(widget.goal.targetAmount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Đã tiết kiệm',
                          style: TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(widget.goal.currentSaved),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Tên mục tiêu',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Nhập tên mục tiêu',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Số tiền cần đạt',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
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

          const Text('Thời hạn', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDeadline,
            child: Container(
              height: 57,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: const Color(0xFF3E8AFF),
                foregroundColor: Colors.white,
              ),
              onPressed: _save,
              child: const Text('Lưu thay đổi'),
            ),
          ),
        ],
      ),
    );
  }
}
