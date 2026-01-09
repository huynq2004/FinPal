// lib/ui/screens/category_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finpal/ui/viewmodels/category_management_viewmodel.dart';
import 'package:finpal/domain/models/category.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  Color _parseBackgroundColor(String rgba) {
    // Parse rgba string like "rgba(255,107,107,0.13)" to Color
    final values = rgba
        .replaceAll('rgba(', '')
        .replaceAll(')', '')
        .split(',')
        .map((s) => s.trim())
        .toList();

    if (values.length == 4) {
      return Color.fromRGBO(
        int.parse(values[0]),
        int.parse(values[1]),
        int.parse(values[2]),
        double.parse(values[3]),
      );
    }
    return Colors.grey.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = CategoryManagementViewModel();
        vm.loadCategories();
        return vm;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Consumer<CategoryManagementViewModel>(
            builder: (context, vm, child) {
              return Column(
                children: [
                  // Header
                  _buildHeader(context),

                  // Tab selector
                  _buildTabs(context, vm),

                  // Add category button
                  _buildAddButton(context),

                  // Category list
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        children: [
                          _buildListHeader(vm),
                          const SizedBox(height: 8),
                          _buildCategoryList(context, vm),
                          const SizedBox(height: 16),
                          _buildInfoBanner(),
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF3F4F6),
            width: 1.2,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF0F172A),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Quản lý danh mục',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Tùy chỉnh danh mục cho giao dịch',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, CategoryManagementViewModel vm) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF3F4F6),
            width: 1.2,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Chi tiêu',
              icon: Icons.trending_down,
              isSelected: vm.selectedType == CategoryType.expense,
              onTap: () => vm.setSelectedType(CategoryType.expense),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              label: 'Thu nhập',
              icon: Icons.trending_up,
              isSelected: vm.selectedType == CategoryType.income,
              onTap: () => vm.setSelectedType(CategoryType.income),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF5A5F) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to add category screen
        },
        child: Container(
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Thêm danh mục mới',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader(CategoryManagementViewModel vm) {
    final categoryCount = vm.categories.length;
    final typeLabel = vm.selectedType == CategoryType.expense
        ? 'chi tiêu'
        : 'thu nhập';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Danh mục $typeLabel',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        Text(
          '$categoryCount danh mục',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            height: 1.43,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    CategoryManagementViewModel vm,
  ) {
    return Column(
      children: vm.categories
          .map((category) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildCategoryCard(context, category),
              ))
          .toList(),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _parseBackgroundColor(category.backgroundColor),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                category.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Category info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    if (category.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Mặc định',
                          style: TextStyle(
                            color: Color(0xFF3E8AFF),
                            fontSize: 12,
                            height: 1.33,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.transactionCount} giao dịch',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),

          // Edit button
          GestureDetector(
            onTap: () {
              // TODO: Navigate to edit category screen
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFEFF6FF),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFF3E8FF),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3E8AFF),
                  Color(0xFF325DFF),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🤖',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI học từ cách bạn phân loại',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mỗi khi bạn sửa danh mục của một giao dịch, AI sẽ học và phân loại chính xác hơn trong tương lai.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ví dụ: Nếu bạn sửa "GRAB" từ "Di chuyển" sang "Ăn uống", AI sẽ nhớ rằng GRAB của bạn thường là GrabFood.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
