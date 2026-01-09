// lib/ui/viewmodels/category_management_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:finpal/domain/models/category.dart';

class CategoryManagementViewModel extends ChangeNotifier {
  CategoryType _selectedType = CategoryType.expense;
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  CategoryType get selectedType => _selectedType;
  List<Category> get categories => _selectedType == CategoryType.expense
      ? _expenseCategories
      : _incomeCategories;

  void loadCategories() {
    // Sample expense categories
    _expenseCategories = [
      const Category(
        id: '1',
        name: 'Ăn uống',
        emoji: '🍜',
        backgroundColor: 'rgba(255,107,107,0.13)',
        type: CategoryType.expense,
        isDefault: true,
        transactionCount: 45,
      ),
      const Category(
        id: '2',
        name: 'Mua sắm',
        emoji: '🛍️',
        backgroundColor: 'rgba(78,205,196,0.13)',
        type: CategoryType.expense,
        isDefault: true,
        transactionCount: 23,
      ),
      const Category(
        id: '3',
        name: 'Di chuyển',
        emoji: '🚗',
        backgroundColor: 'rgba(255,217,61,0.13)',
        type: CategoryType.expense,
        isDefault: true,
        transactionCount: 38,
      ),
      const Category(
        id: '4',
        name: 'Giải trí',
        emoji: '🎮',
        backgroundColor: 'rgba(149,225,211,0.13)',
        type: CategoryType.expense,
        isDefault: true,
        transactionCount: 12,
      ),
      const Category(
        id: '5',
        name: 'Hóa đơn',
        emoji: '📄',
        backgroundColor: 'rgba(199,206,234,0.13)',
        type: CategoryType.expense,
        isDefault: true,
        transactionCount: 8,
      ),
      const Category(
        id: '6',
        name: 'Y tế',
        emoji: '⚕️',
        backgroundColor: 'rgba(255,154,162,0.13)',
        type: CategoryType.expense,
        isDefault: true,
        transactionCount: 5,
      ),
      const Category(
        id: '7',
        name: 'Giáo dục',
        emoji: '📚',
        backgroundColor: 'rgba(255,183,178,0.13)',
        type: CategoryType.expense,
        isDefault: true,
        transactionCount: 3,
      ),
      const Category(
        id: '8',
        name: 'Trà sữa',
        emoji: '🧋',
        backgroundColor: 'rgba(255,218,193,0.13)',
        type: CategoryType.expense,
        isDefault: false,
        transactionCount: 18,
      ),
    ];

    // Sample income categories
    _incomeCategories = [
      const Category(
        id: '101',
        name: 'Lương',
        emoji: '💰',
        backgroundColor: 'rgba(46,204,113,0.13)',
        type: CategoryType.income,
        isDefault: true,
        transactionCount: 12,
      ),
      const Category(
        id: '102',
        name: 'Thưởng',
        emoji: '🎁',
        backgroundColor: 'rgba(52,152,219,0.13)',
        type: CategoryType.income,
        isDefault: true,
        transactionCount: 5,
      ),
      const Category(
        id: '103',
        name: 'Đầu tư',
        emoji: '📈',
        backgroundColor: 'rgba(155,89,182,0.13)',
        type: CategoryType.income,
        isDefault: true,
        transactionCount: 8,
      ),
    ];

    notifyListeners();
  }

  void setSelectedType(CategoryType type) {
    _selectedType = type;
    notifyListeners();
  }

  void addCategory(Category category) {
    if (category.type == CategoryType.expense) {
      _expenseCategories.add(category);
    } else {
      _incomeCategories.add(category);
    }
    notifyListeners();
  }

  void updateCategory(Category category) {
    final list = category.type == CategoryType.expense
        ? _expenseCategories
        : _incomeCategories;

    final index = list.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      if (category.type == CategoryType.expense) {
        _expenseCategories[index] = category;
      } else {
        _incomeCategories[index] = category;
      }
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _expenseCategories.removeWhere((c) => c.id == id);
    _incomeCategories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
