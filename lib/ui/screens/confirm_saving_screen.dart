// lib/ui/screens/confirm_saving_screen.dart

import 'package:flutter/material.dart';
import 'package:finpal/domain/models/saving_goal.dart';

class ConfirmSavingScreen extends StatefulWidget {
  final SavingGoal goal;

  const ConfirmSavingScreen({super.key, required this.goal});

  @override
  State<ConfirmSavingScreen> createState() => _ConfirmSavingScreenState();
}

class _ConfirmSavingScreenState extends State<ConfirmSavingScreen> {
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

  void _handleConfirm() {
    final inputAmount = int.tryParse(_amountController.text) ?? 0;
    if (inputAmount <= 0) return;

    // TODO: Save to backend/database
    Navigator.pop(context, {'amount': inputAmount, 'isWeekly': _isWeekly});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã xác nhận tiết kiệm ${_formatCurrency(inputAmount)}đ/${_isWeekly ? "tuần" : "tháng"}!',
        ),
        backgroundColor: const Color(0xFF2ECC71),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestedAmount = _isWeekly
        ? _getSuggestedWeekly()
        : _getSuggestedMonthly();
    final inputAmount = int.tryParse(_amountController.text) ?? 0;
    final comparisonStatus = _getComparisonStatus(inputAmount, suggestedAmount);
    final comparisonColor = _getComparisonColor(inputAmount, suggestedAmount);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          color: const Color(0xFF0F172A),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Xác nhận tiết kiệm',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card - Mục tiêu
            Container(
              width: double.infinity,
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
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mục tiêu tiết kiệm',
                              style: TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.goal.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                            '${_formatCurrency(widget.goal.targetAmount)}đ',
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
                            '${_formatCurrency(widget.goal.currentSaved)}đ',
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

            // Chọn chu kỳ
            const Text(
              'Chu kỳ tiết kiệm',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            // Toggle tuần/tháng
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isWeekly = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: _isWeekly
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF3E8AFF),
                                    Color(0xFF325DFF),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Theo tuần',
                          style: TextStyle(
                            color: _isWeekly
                                ? Colors.white
                                : const Color(0xFF64748B),
                            fontWeight: _isWeekly
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isWeekly = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: !_isWeekly
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF3E8AFF),
                                    Color(0xFF325DFF),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Theo tháng',
                          style: TextStyle(
                            color: !_isWeekly
                                ? Colors.white
                                : const Color(0xFF64748B),
                            fontWeight: !_isWeekly
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Gợi ý từ FinPal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3E8AFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gợi ý từ FinPal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3E8AFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatCurrency(suggestedAmount)}đ/${_isWeekly ? "tuần" : "tháng"}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF3E8AFF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Input số tiền
            const Text(
              'Số tiền bạn sẽ tiết kiệm',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontWeight: FontWeight.w400,
                  ),
                  suffixText: 'đ',
                  suffixStyle: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (val) => setState(() {}),
              ),
            ),

            const SizedBox(height: 16),

            // So sánh với gợi ý
            if (inputAmount > 0)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: comparisonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: comparisonColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: comparisonColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        inputAmount >= suggestedAmount
                            ? Icons.check_circle
                            : Icons.info,
                        color: comparisonColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        comparisonStatus,
                        style: TextStyle(
                          color: comparisonColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: inputAmount > 0
                  ? const Color(0xFF2ECC71)
                  : const Color(0xFFE5E7EB),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: inputAmount > 0 ? 4 : 0,
              shadowColor: inputAmount > 0
                  ? const Color(0x262ECC71)
                  : Colors.transparent,
            ),
            onPressed: inputAmount > 0 ? _handleConfirm : null,
            child: Text(
              'Xác nhận tiết kiệm',
              style: TextStyle(
                color: inputAmount > 0 ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
