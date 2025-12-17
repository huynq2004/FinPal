import 'package:flutter/material.dart';

import 'package:finpal/domain/models/transaction.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/repositories/categories_repository.dart';
import 'package:finpal/data/db/database_provider.dart';
import 'package:intl/intl.dart';

class ManualTransactionViewModel extends ChangeNotifier {
  int amount = 0;
  String type = 'Chi tiêu';
  String category = 'Ăn uống';
  String source = 'Vietcombank';
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  String description = ''; 
  String note = '';
  String? errorMessage;
  bool isLoading = false;
  List<String> categories = [];
  bool categoriesLoading = false;

  void setAmount(int value) {
    amount = value;
    notifyListeners();
  }

  void setType(String value) {
    type = value;
    notifyListeners();
  }

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  void setSource(String value) {
    source = value;
    notifyListeners();
  }

  void setDate(DateTime value) {
    date = value;
    notifyListeners();
  }

  void setTime(TimeOfDay value) {
    time = value;
    notifyListeners();
  }

  void setDescription(String value) {
    description = value;
    notifyListeners();
  }

  void setNote(String value) {
    note = value;
    notifyListeners();
  }

  // Validation methods - Single source of truth
  String? validateAmount() {
    if (amount <= 0) return 'Số tiền phải > 0';
    return null;
  }

  String? validateDescription() {
    if (description.isEmpty) return 'Nhập nội dung';
    return null;
  }

  /// Load categories from the local database. If none exist, seed defaults.
  Future<void> loadCategories() async {
    try {
      categoriesLoading = true;
      notifyListeners();

      final db = await DatabaseProvider.instance.database;
      final repo = CategoriesRepository(db);
      var rows = await repo.getAllCategories();

      if (rows.isEmpty) {
        // Seed default categories then reload
        await DatabaseProvider.instance.seedCategories(db);
        rows = await repo.getAllCategories();
      }

      categories = rows
          .map((r) => r['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();

      // If current category is not in list, set to first available
      if (categories.isNotEmpty && !categories.contains(category)) {
        category = categories.first;
      }
    } catch (e) {
      // ignore errors for now; keep existing defaults
    } finally {
      categoriesLoading = false;
      notifyListeners();
    }
  }

  DateTime get fullDateTime => DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);
  
  String get formattedTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<bool> saveTransaction() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Safety check - validate again using existing methods (defense in depth)
      final amountError = validateAmount();
      if (amountError != null) {
        errorMessage = amountError;
        isLoading = false;
        notifyListeners();
        return false;
      }

      final descError = validateDescription();
      if (descError != null) {
        errorMessage = descError;
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Lookup category ID from category name
      final db = await DatabaseProvider.instance.database;
      final categoriesRepo = CategoriesRepository(db);
      final categoryId = await categoriesRepo.getCategoryIdByName(category);

      final repo = TransactionRepository(DatabaseProvider.instance);
      final transaction = Transaction(
        amount: amount,
        type: type == 'Chi tiêu' ? 'expense' : 'income',
        categoryId: categoryId,
        categoryName: category,
        bank: source,
        createdAt: fullDateTime,
        note: note.isNotEmpty ? note : null,
        source: 'manual',
      );

      await repo.insertTransaction(transaction);
      
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Lỗi: ${e.toString()}';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    amount = 0;
    type = 'Chi tiêu';
    category = 'Ăn uống';
    source = 'Vietcombank';
    date = DateTime.now();
    time = TimeOfDay.now();
    description = ''; // Add this
    note = '';
    errorMessage = null;
    notifyListeners();
  }
}
