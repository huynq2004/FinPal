// lib/ui/screens/ai_insight_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finpal/domain/models/ai_insight.dart';
import 'package:finpal/domain/models/transaction.dart' as app_models;

class AiInsightDetailScreen extends StatelessWidget {
  final AiInsight insight;
  final List<app_models.Transaction> recentTransactions;

  const AiInsightDetailScreen({
    super.key,
    required this.insight,
    this.recentTransactions = const [],
  });

  Color _getTypeColor() {
    switch (insight.type) {
      case InsightType.warning:
        return const Color(0xFFFF5A5F);
      case InsightType.suggestion:
        return const Color(0xFF3E8AFF);
      case InsightType.info:
        return const Color(0xFF2ECC71);
    }
  }

  IconData _getTypeIcon() {
    switch (insight.type) {
      case InsightType.warning:
        return Icons.warning_amber_rounded;
      case InsightType.suggestion:
        return Icons.lightbulb_outline;
      case InsightType.info:
        return Icons.info_outline;
    }
  }

  String _getHeaderTitle() {
    switch (insight.type) {
      case InsightType.warning:
        return 'Chi tiết cảnh báo';
      case InsightType.suggestion:
        return 'Chi tiết gợi ý';
      case InsightType.info:
        return 'Chi tiết thông tin';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor();
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient
              _buildHeader(color, currencyFormat),

              const SizedBox(height: 24),

              // Stats card
              if (insight.spentAmount != null && insight.limitAmount != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildStatsCard(color, currencyFormat),
                ),

              const SizedBox(height: 24),

              // Saving tips section
              if (insight.savingTips != null && insight.savingTips!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSavingTipsSection(currencyFormat),
                ),

              const SizedBox(height: 24),

              // Recent transactions
              if (recentTransactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildRecentTransactions(currencyFormat),
                ),

              const SizedBox(height: 24),

              // Adjust limit button
              if (insight.limitAmount != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildAdjustLimitButton(),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, NumberFormat currencyFormat) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            Color.lerp(color, Colors.black, 0.15)!,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          // Back button and title
          Row(
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _getHeaderTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTypeIcon(),
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            insight.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Category
          Text(
            'Danh mục: ${insight.categoryName}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.43,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Color color, NumberFormat currencyFormat) {
    final percentage = insight.usagePercentage;
    final remaining = insight.remainingAmount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          // Spent vs Limit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đã chi',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(insight.spentAmount),
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Hạn mức',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(insight.limitAmount),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 12,
                  width: double.infinity,
                  color: const Color(0xFFF3F4F6),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (percentage / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFD93D),
                            Color(0xFFFF5A5F),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(1)}% đã sử dụng',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      height: 1.43,
                    ),
                  ),
                  Text(
                    'Còn ${currencyFormat.format(remaining)}',
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Divider
          const Divider(
            color: Color(0xFFF3F4F6),
            height: 1,
            thickness: 1.2,
          ),

          const SizedBox(height: 17),

          // Stats rows
          _buildStatRow(
            icon: Icons.calendar_today_outlined,
            label: 'Số ngày còn lại',
            value: '${insight.daysRemaining} ngày',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: null,
            label: 'Chi tiêu trung bình/ngày',
            value: currencyFormat.format(insight.avgDailySpending),
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: null,
            label: 'Nên chi tối đa/ngày',
            value: currencyFormat.format(insight.maxDailySpending),
            valueColor: const Color(0xFF2ECC71),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    IconData? icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.43,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingTipsSection(NumberFormat currencyFormat) {
    final tips = insight.savingTips!;
    final totalSavings = tips.fold<double>(
      0,
      (sum, tip) => sum + tip.savingsAmount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gợi ý tiết kiệm',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Tips cards
        ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTipCard(tip, currencyFormat),
            )),

        const SizedBox(height: 4),

        // Total savings banner
        Container(
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFDCFCE7),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0FDF4),
                Color(0xFFECFDF5),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng tiết kiệm nếu áp dụng',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currencyFormat.format(totalSavings)}/tháng',
                    style: const TextStyle(
                      color: Color(0xFF2ECC71),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.monetization_on_outlined,
                color: Color(0xFF2ECC71),
                size: 32,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(SavingTip tip, NumberFormat currencyFormat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF2ECC71),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiết kiệm: ${currencyFormat.format(tip.savingsAmount)}/tháng',
                      style: const TextStyle(
                        color: Color(0xFF2ECC71),
                        fontSize: 14,
                        height: 1.43,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Apply tip
                      },
                      child: const Text(
                        'Áp dụng',
                        style: TextStyle(
                          color: Color(0xFF3E8AFF),
                          fontSize: 14,
                          height: 1.43,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(NumberFormat currencyFormat) {
    final DateFormat dateFormat = DateFormat('HH:mm', 'vi_VN');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Giao dịch gần đây',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to all transactions
              },
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  color: Color(0xFF3E8AFF),
                  fontSize: 14,
                  height: 1.43,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: -1,
              ),
            ],
          ),
          child: Column(
            children: recentTransactions
                .take(5)
                .map((transaction) => _buildTransactionItem(
                      transaction,
                      currencyFormat,
                      dateFormat,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    app_models.Transaction transaction,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    String getRelativeDate() {
      final now = DateTime.now();
      final txDate = transaction.createdAt;
      final diff = now.difference(txDate).inDays;

      if (diff == 0) {
        return 'Hôm nay, ${dateFormat.format(txDate)}';
      } else if (diff == 1) {
        return 'Hôm qua, ${dateFormat.format(txDate)}';
      } else {
        return '$diff ngày trước, ${dateFormat.format(txDate)}';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF3F4F6),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note ?? transaction.categoryName,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getRelativeDate(),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '-${currencyFormat.format(transaction.amount)}',
            style: const TextStyle(
              color: Color(0xFFFF5A5F),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustLimitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3E8AFF),
            Color(0xFF325DFF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to budget adjustment
          },
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Text(
              'Điều chỉnh hạn mức',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
