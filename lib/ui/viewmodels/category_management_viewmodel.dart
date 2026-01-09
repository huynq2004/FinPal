// lib/ui/viewmodels/category_management_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:finpal/domain/models/category.dart';
import 'package:finpal/data/repositories/categories_repository.dart';

class CategoryManagementViewModel extends ChangeNotifier {
  final CategoriesRepository _repository;
  bool _isLoading = false;
  String? _errorMessage;

  CategoryManagementViewModel(this._repository);
  CategoryType _selectedType = CategoryType.expense;
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  CategoryType get selectedType => _selectedType;
  List<Category> get categories => _selectedType == CategoryType.expense
      ? _expenseCategories
      : _incomeCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load expense categories
      final expenseData = await _repository.getCategoriesByType('expense');
      _expenseCategories = [];
      for (final data in expenseData) {
        final id = data['id']?.toString() ?? '';
        final transactionCount = await _repository.getTransactionCount(int.parse(id));
        _expenseCategories.add(
          Category(
            id: id,
            name: data['name']?.toString() ?? '',
            emoji: _getEmojiFromIcon(data['icon']?.toString()),
            backgroundColor: _getBackgroundColor(data['color']?.toString()),
            type: CategoryType.expense,
            isDefault: _isDefaultCategory(data['name']?.toString() ?? ''),
            transactionCount: transactionCount,
          ),
        );
      }

      // Load income categories
      final incomeData = await _repository.getCategoriesByType('income');
      _incomeCategories = [];
      for (final data in incomeData) {
        final id = data['id']?.toString() ?? '';
        final transactionCount = await _repository.getTransactionCount(int.parse(id));
        _incomeCategories.add(
          Category(
            id: id,
            name: data['name']?.toString() ?? '',
            emoji: _getEmojiFromIcon(data['icon']?.toString()),
            backgroundColor: _getBackgroundColor(data['color']?.toString()),
            type: CategoryType.income,
            isDefault: _isDefaultCategory(data['name']?.toString() ?? ''),
            transactionCount: transactionCount,
          ),
        );
      }
    } catch (e) {
      _errorMessage = 'Không thể tải danh mục: $e';
      print('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods
  String _getEmojiFromIcon(String? icon) {
    if (icon == null) return '📦';
    final emojiMap = {
      'restaurant': '🍜',
      'directions_car': '🚗',
      'shopping_cart': '🛍️',
      'receipt_long': '📄',
      'attach_money': '💰',
      'sports_esports': '🎮',
      'local_hospital': '⚕️',
      'school': '📚',
      'local_cafe': '🧋',
      'card_giftcard': '🎁',
      'trending_up': '📈',
    };
    return emojiMap[icon] ?? '📦';
  }

  String _getBackgroundColor(String? color) {
    if (color == null) return 'rgba(200,200,200,0.13)';
    // Convert hex to rgba
    if (color.startsWith('#') && color.length == 7) {
      final r = int.parse(color.substring(1, 3), radix: 16);
      final g = int.parse(color.substring(3, 5), radix: 16);
      final b = int.parse(color.substring(5, 7), radix: 16);
      return 'rgba($r,$g,$b,0.13)';
    }
    return 'rgba(200,200,200,0.13)';
  }

  bool _isDefaultCategory(String name) {
    final defaultNames = ['Ăn uống', 'Di chuyển', 'Mua sắm', 'Hóa đơn', 'Thu nhập'];
    return defaultNames.contains(name);
  }

  void setSelectedType(CategoryType type) {
    _selectedType = type;
    notifyListeners();
  }

  Future<bool> addCategory(Category category) async {
    try {
      _isLoading = true;
      notifyListeners();

      final icon = _getIconFromEmoji(category.emoji);
      final color = _getColorFromBackground(category.backgroundColor);

      await _repository.addCategory(
        name: category.name,
        type: category.type == CategoryType.expense ? 'expense' : 'income',
        icon: icon,
        color: color,
      );

      // Reload categories
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Không thể thêm danh mục: $e';
      print('Error adding category: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      _isLoading = true;
      notifyListeners();

      final icon = _getIconFromEmoji(category.emoji);
      final color = _getColorFromBackground(category.backgroundColor);

      await _repository.updateCategory(
        id: int.parse(category.id),
        name: category.name,
        icon: icon,
        color: color,
      );

      // Reload categories
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Không thể cập nhật danh mục: $e';
      print('Error updating category: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final id = int.parse(categoryId);
      
      // Check if category is in use
      final inUse = await _repository.isCategoryInUse(id);
      if (inUse) {
        _errorMessage = 'Không thể xóa danh mục đang được sử dụng';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _repository.deleteCategory(id);

      // Reload categories
      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = 'Không thể xóa danh mục: $e';
      print('Error deleting category: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _getIconFromEmoji(String emoji) {
    final iconMap = {
      '🍜': 'restaurant',
      '🚗': 'directions_car',
      '🛍️': 'shopping_cart',
      '📄': 'receipt_long',
      '💰': 'attach_money',
      '🎮': 'sports_esports',
      '⚕️': 'local_hospital',
      '📚': 'school',
      '🧋': 'local_cafe',
      '🎁': 'card_giftcard',
      '📈': 'trending_up',
    };
    return iconMap[emoji] ?? 'category';
  }

  String _getColorFromBackground(String bgColor) {
    // Extract RGB from rgba string
    final regex = RegExp(r'rgba\((\d+),(\d+),(\d+)');
    final match = regex.firstMatch(bgColor);
    if (match != null) {
      final r = int.parse(match.group(1)!);
      final g = int.parse(match.group(2)!);
      final b = int.parse(match.group(3)!);
      return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
    }
    return '#CCCCCC';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
