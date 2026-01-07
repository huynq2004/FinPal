import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../viewmodels/monthly_report_viewmodel.dart';

class MonthlyReportScreen extends StatefulWidget {
  final int? year;
  final int? month;

  const MonthlyReportScreen({super.key, this.year, this.month});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = widget.year ?? now.year;
    selectedMonth = widget.month ?? now.month;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonthlyReportViewModel>().loadReport(
        selectedYear,
        selectedMonth,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Báo cáo tháng',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<MonthlyReportViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final fmt = NumberFormat.decimalPattern('vi');
          String money(int v) => '${fmt.format(v)}đ';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Month Selector
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vm.monthLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () {
                                if (selectedMonth == 1) {
                                  selectedYear--;
                                  selectedMonth = 12;
                                } else {
                                  selectedMonth--;
                                }
                                vm.loadReport(selectedYear, selectedMonth);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () {
                                final now = DateTime.now();
                                if (selectedYear == now.year &&
                                    selectedMonth == now.month) {
                                  return;
                                }
                                if (selectedMonth == 12) {
                                  selectedYear++;
                                  selectedMonth = 1;
                                } else {
                                  selectedMonth++;
                                }
                                vm.loadReport(selectedYear, selectedMonth);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Summary Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Thu nhập',
                          amount: money(vm.currentIncome),
                          color: Colors.green,
                          change: vm.getIncomeChangePercent(),
                          icon: Icons.arrow_downward,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Chi tiêu',
                          amount: money(vm.currentExpense),
                          color: Colors.red,
                          change: vm.getExpenseChangePercent(),
                          icon: Icons.arrow_upward,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Balance Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Số dư tháng này',
                          style: TextStyle(
                            color: Color(0xE6FFFFFF),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          money(vm.currentBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vm.currentBalance >= 0
                              ? 'Bạn đang dư tiền'
                              : 'Bạn đang thiếu tiền',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Month Comparison
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'So sánh với tháng trước',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ComparisonRow(
                          label: 'Tháng này',
                          month: vm.monthLabel,
                          income: money(vm.currentIncome),
                          expense: money(vm.currentExpense),
                        ),
                        const SizedBox(height: 12),
                        _ComparisonRow(
                          label: 'Tháng trước',
                          month: vm.prevMonthLabel,
                          income: money(vm.prevIncome),
                          expense: money(vm.prevExpense),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Top Categories
                if (vm.categoryExpenses.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF000000).withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Các mục chi tiêu hàng đầu',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...vm.getTopCategories(3).asMap().entries.map((e) {
                            final index = e.key;
                            final entry = e.value;
                            final percent = vm.currentExpense > 0
                                ? ((entry.value / vm.currentExpense) * 100)
                                : 0.0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${index + 1}. ${entry.key}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        money(entry.value),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percent / 100,
                                      minHeight: 6,
                                      backgroundColor: const Color(0xFFF3F4F6),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getCategoryColor(index),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${percent.toStringAsFixed(1)}% tổng chi tiêu',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Suggestions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFCD34D),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gợi ý cho bạn',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...vm.suggestions.map((suggestion) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              suggestion,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF78350F),
                                height: 1.5,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(int index) {
    const colors = [Color(0xFF3E8AFF), Color(0xFF10B981), Color(0xFFF59E0B)];
    return colors[index % colors.length];
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final String change;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.change,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            change,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String month;
  final String income;
  final String expense;

  const _ComparisonRow({
    required this.label,
    required this.month,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 2),
              Text(
                month,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thu nhập',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              Text(
                income,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Chi tiêu',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              Text(
                expense,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
