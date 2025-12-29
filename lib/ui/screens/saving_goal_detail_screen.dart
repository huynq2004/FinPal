// lib/ui/screens/saving_goal_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:finpal/domain/models/saving_goal.dart';
import 'package:finpal/ui/screens/edit_saving_goal_screen.dart';
import 'package:finpal/ui/screens/confirm_saving_screen.dart';

class SavingGoalDetailScreen extends StatefulWidget {
  final SavingGoal goal;

  const SavingGoalDetailScreen({super.key, required this.goal});

  @override
  State<SavingGoalDetailScreen> createState() => _SavingGoalDetailScreenState();
}

class _SavingGoalDetailScreenState extends State<SavingGoalDetailScreen> {
  bool _isWeekly = true; // true = tuần, false = tháng
  final TextEditingController _amountController = TextEditingController();

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
    return '${buffer.toString().split('').reversed.join()}';
  }

  double _getProgress() {
    if (widget.goal.targetAmount == 0) return 0;
    return (widget.goal.currentSaved / widget.goal.targetAmount).clamp(
      0.0,
      1.0,
    );
  }

  int _getAmountNeeded() {
    return (widget.goal.targetAmount - widget.goal.currentSaved).clamp(
      0,
      widget.goal.targetAmount,
    );
  }

  int _getDaysRemaining() {
    final now = DateTime.now();
    final daysLeft = widget.goal.deadline.difference(now).inDays;
    return daysLeft.clamp(0, 9999);
  }

  int _getWeeksRemaining() {
    final days = _getDaysRemaining();
    return (days / 7).ceil().clamp(1, 9999);
  }

  int _getMonthsRemaining() {
    final now = DateTime.now();
    final months =
        (widget.goal.deadline.year - now.year) * 12 +
        (widget.goal.deadline.month - now.month);
    return months.clamp(1, 9999);
  }

  int _getSuggestedWeekly() {
    final needed = _getAmountNeeded();
    if (needed == 0) return 0;
    final weeks = _getWeeksRemaining();
    return (needed / weeks).ceil();
  }

  int _getSuggestedMonthly() {
    final needed = _getAmountNeeded();
    if (needed == 0) return 0;
    final months = _getMonthsRemaining();
    return (needed / months).ceil();
  }

  String _getComparisonStatus(int inputAmount, int suggestedAmount) {
    if (inputAmount > suggestedAmount) {
      return 'Tuyệt vời! Bạn tiết kiệm nhiều hơn mục tiêu 🎉';
    } else if (inputAmount == suggestedAmount) {
      return 'Hoàn hảo! Đúng bằng mục tiêu 👏';
    } else {
      final diff = suggestedAmount - inputAmount;
      return 'Bạn còn cần thêm ${_formatCurrency(diff)}đ để đạt mục tiêu';
    }
  }

  Color _getComparisonColor(int inputAmount, int suggestedAmount) {
    if (inputAmount >= suggestedAmount) {
      return const Color(0xFF2ECC71);
    }
    return const Color(0xFFFF6B6B);
  }

  void _showSavingConfirmDialog() {
    _amountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final suggestedAmount = _isWeekly
                ? _getSuggestedWeekly()
                : _getSuggestedMonthly();
            final inputAmount = int.tryParse(_amountController.text) ?? 0;
            final comparisonStatus = _getComparisonStatus(
              inputAmount,
              suggestedAmount,
            );
            final comparisonColor = _getComparisonColor(
              inputAmount,
              suggestedAmount,
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Xác nhận tiết kiệm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Toggle tuần/tháng
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => _isWeekly = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isWeekly
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _isWeekly
                                    ? [
                                        const BoxShadow(
                                          color: Color(0x0F000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Theo tuần',
                                style: TextStyle(
                                  color: _isWeekly
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF64748B),
                                  fontWeight: _isWeekly
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => _isWeekly = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isWeekly
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_isWeekly
                                    ? [
                                        const BoxShadow(
                                          color: Color(0x0F000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Theo tháng',
                                style: TextStyle(
                                  color: !_isWeekly
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF64748B),
                                  fontWeight: !_isWeekly
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Số tiền gợi ý
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF3E8AFF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Gợi ý: ${_formatCurrency(suggestedAmount)}đ/${_isWeekly ? "tuần" : "tháng"}',
                          style: const TextStyle(
                            color: Color(0xFF3E8AFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input số tiền
                  const Text(
                    'Số tiền bạn muốn tiết kiệm',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Nhập số tiền',
                      suffixText: 'đ',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    onChanged: (val) => setModalState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // So sánh
                  if (inputAmount > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: comparisonColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            inputAmount >= suggestedAmount
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            color: comparisonColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              comparisonStatus,
                              style: TextStyle(
                                color: comparisonColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Xác nhận button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: inputAmount > 0
                          ? () {
                              // TODO: Save confirmation to backend
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã xác nhận tiết kiệm ${_formatCurrency(inputAmount)}đ/${_isWeekly ? "tuần" : "tháng"}!',
                                  ),
                                  backgroundColor: const Color(0xFF2ECC71),
                                ),
                              );
                            }
                          : null,
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _getProgress();
    final amountNeeded = _getAmountNeeded();
    final suggestedWeekly = _getSuggestedWeekly();
    final percentLabel = (progress * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          color: const Color(0xFF0F172A),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Chi tiết mục tiêu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF0F172A)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 12),
                    Text('Chỉnh sửa'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Color(0xFFFF5A5F),
                    ),
                    SizedBox(width: 12),
                    Text('Xóa', style: TextStyle(color: Color(0xFFFF5A5F))),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'edit') {
                final updated = await Navigator.push<SavingGoal?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditSavingGoalScreen(goal: widget.goal),
                  ),
                );
                if (updated != null && mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavingGoalDetailScreen(goal: updated),
                    ),
                  );
                }
              } else if (value == 'delete') {
                // TODO: Confirm delete
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng xóa sẽ được cập nhật'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // === HERO CARD: Gradient xanh với thông tin mục tiêu ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    // Icon + Tên mục tiêu
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.savings_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.goal.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Mục tiêu
                    const Text(
                      'Mục tiêu:',
                      style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatCurrency(widget.goal.targetAmount)}đ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Progress bar
                    Row(
                      children: [
                        const Text(
                          'Đã tiết kiệm',
                          style: TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_formatCurrency(widget.goal.currentSaved)}đ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: constraints.maxWidth * progress,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phần trăm + Còn lại
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$percentLabel%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Còn lại: ${_formatCurrency(amountNeeded)}đ',
                          style: const TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chips: Thời hạn + Gợi ý FinPal
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          icon: Icons.calendar_today_outlined,
                          label: 'Thời hạn',
                          value: '${_getDaysRemaining()} ngày',
                        ),
                        _buildChip(
                          icon: Icons.lightbulb_outline,
                          label: 'Gợi ý FinPal',
                          value: '${_formatCurrency(suggestedWeekly)}đ/tuần',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // === GREEN CARD: Xác nhận tiết kiệm ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConfirmSavingScreen(goal: widget.goal),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x262ECC71),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xác nhận tiết kiệm',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tháng này bạn đã tiết kiệm bao nhiêu?',
                              style: TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // === WHITE CARD: Gợi ý từ FinPal ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF3E8AFF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Gợi ý từ FinPal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'FinPal khuyên bạn nên tiết kiệm ',
                          ),
                          TextSpan(
                            text: '${_formatCurrency(suggestedWeekly)}đ/tuần',
                            style: const TextStyle(
                              color: Color(0xFF3E8AFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' để đạt mục tiêu đúng hạn.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💡 Bạn có thể tiết kiệm nhiều hơn so với gợi ý - rất tốt!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '✅ Đặt mục tiêu nhỏ mỗi tuần/tháng sẽ dễ đạt hơn',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
