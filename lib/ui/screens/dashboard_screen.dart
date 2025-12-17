import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/pie_chart.dart';
import '../widgets/transaction_tile.dart';
import 'settings_screen.dart';
import 'transaction_history_screen.dart';
import 'manual_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      context.read<DashboardViewModel>().loadSummary(now.year, now.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('vi');
    String money(int v) => '${fmt.format(v)}đ';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                /// ================= HEADER =================
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'FinPal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.history, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const TransactionHistoryScreen()),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const SettingsScreen()),
                                  );
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// Summary Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  vm.monthLabel(DateTime.now().year,
                                      DateTime.now().month),
                                  style: const TextStyle(
                                      color: Color(0xFF64748B)),
                                ),
                                const Text(
                                  'Đổi tháng',
                                  style:
                                      TextStyle(color: Color(0xFF3E8AFF)),
                                )
                              ],
                            ),
                            const SizedBox(height: 14),

                            _summaryRow(
                              'Tổng thu nhập',
                              money(vm.totalIncome),
                              Colors.green,
                            ),
                            const SizedBox(height: 10),
                            _summaryRow(
                              'Tổng chi tiêu',
                              money(vm.totalExpense),
                              Colors.red,
                            ),
                            const Divider(height: 24),
                            _summaryRow(
                              'Còn lại',
                              money(vm.balance),
                              Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ================= PHÂN LOẠI =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phân loại chi tiêu',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),

                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 160,
                              child: vm.categories.isEmpty
                                  ? const SizedBox()
                                  : PieChart(data: vm.categories, size: 160),
                            ),
                          ),

                          const SizedBox(height: 12),

                          ...vm.categories.map((c) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                        color: c.color,
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(c.name)),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '${(c.percent * 100).toStringAsFixed(0)}%',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          color: Color(0xFF64748B)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      money(c.amount),
                                      textAlign: TextAlign.right,
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
                ),

                /// ================= GIAO DỊCH GẦN ĐÂY =================
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Giao dịch gần đây',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const TransactionHistoryScreen()),
                          );
                        },
                        icon: const Text('Xem thêm'),
                        label: const Icon(Icons.arrow_forward_ios, size: 14),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                      child: Column(
                      children: vm.recentTransactions
                        .take(3)
                        .map((tx) => TransactionTile(tx: tx))
                        .toList(),
                      ),
                  ),
                ),

                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
      /// ================= FAB =================
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManualTransactionScreen()),
          );

          // If a new transaction was saved, refresh the summary
          if (result == true && mounted) {
            final now = DateTime.now();
            context.read<DashboardViewModel>().loadSummary(now.year, now.month);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  
  Widget _summaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}
