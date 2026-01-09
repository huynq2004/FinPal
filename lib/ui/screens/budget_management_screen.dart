import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/budget_management_viewmodel.dart';
import 'budget_form_screen.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  State<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  static const _bg = Color(0xFFF5F7FA);
  static const _primary = Color(0xFF3E8AFF);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    // Load budgets khi màn hình khởi tạo
    Future.microtask(() {
      context.read<BudgetManagementViewModel>().loadBudgets();
    });
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}₫';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetManagementViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý hạn mức',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Đặt giới hạn chi tiêu cho từng danh mục',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
            toolbarHeight: 100,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Budget Card with Gradient
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
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
                              blurRadius: 15,
                              spreadRadius: -3,
                              offset: Offset(0, 10),
                              color: Color(0x1A000000),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tổng hạn mức tháng này',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xCCFFFFFF),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatCurrency(viewModel.totalLimit),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Progress section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Đã chi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xCCFFFFFF),
                                  ),
                                ),
                                Text(
                                  _formatCurrency(viewModel.totalSpent),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: viewModel.totalLimit > 0
                                    ? (viewModel.totalSpent / viewModel.totalLimit).clamp(0, 1)
                                    : 0,
                                backgroundColor: const Color(0x33FFFFFF),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Còn lại',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xCCFFFFFF),
                                  ),
                                ),
                                Text(
                                  _formatCurrency(viewModel.totalRemaining),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Section Header with Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hạn mức theo danh mục',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const BudgetFormScreen(),
                                ),
                              );
                              if (result == true) {
                                // Reload budgets sau khi thêm mới
                                if (mounted) {
                                  context.read<BudgetManagementViewModel>().loadBudgets();
                                }
                              }
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.add, size: 16, color: _primary),
                                SizedBox(width: 4),
                                Text(
                                  'Thêm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Budget Categories List from ViewModel
                      if (viewModel.budgetItems.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'Chưa có hạn mức nào.\nNhấn "Thêm" để tạo hạn mức mới.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: _textSecondary),
                            ),
                          ),
                        )
                      else
                        ...viewModel.budgetItems.map((budgetItem) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 3,
                                    spreadRadius: 0,
                                    offset: Offset(0, 1),
                                    color: Color(0x1A000000),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Emoji Icon
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: budgetItem.bgColor,
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Center(
                                          child: Text(
                                            budgetItem.emoji,
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Category Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              budgetItem.categoryName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${_formatCurrency(budgetItem.spent)} / ${_formatCurrency(budgetItem.limit)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: _textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Edit Button
                                      IconButton(
                                        onPressed: () async {
                                          final result = await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => BudgetFormScreen(
                                                budgetId: budgetItem.budgetId,
                                                categoryId: budgetItem.categoryId,
                                                categoryName: budgetItem.categoryName,
                                                currentLimit: budgetItem.limit,
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            // Reload budgets sau khi chỉnh sửa
                                            if (mounted) {
                                              context.read<BudgetManagementViewModel>().loadBudgets();
                                            }
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Progress Bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: LinearProgressIndicator(
                                      value: (budgetItem.spent / budgetItem.limit).clamp(0, 1),
                                      backgroundColor: const Color(0xFFF3F4F6),
                                      valueColor: AlwaysStoppedAnimation<Color>(budgetItem.color),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${budgetItem.percentage.round()}% đã sử dụng',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),

                      // Smart Alert Info Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.info_outline, color: _primary, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cảnh báo thông minh',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'FinPal sẽ tự động gửi thông báo khi bạn sử dụng 70% hạn mức của mỗi danh mục.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
