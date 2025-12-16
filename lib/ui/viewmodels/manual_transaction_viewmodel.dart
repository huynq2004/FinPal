import 'package:flutter/material.dart';

import 'package:finpal/domain/models/transaction.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/db/database_provider.dart';
import 'package:intl/intl.dart';

class ManualTransactionViewModel extends ChangeNotifier {
  int amount = 0;
  String type = 'Chi tiêu';
  String category = 'Ăn uống';
  String source = 'Vietcombank';
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  String description = ''; // Add this field
  String note = '';
  String? errorMessage;
  bool isLoading = false;

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

      // Validate
      if (amount <= 0) {
        errorMessage = 'Vui lòng nhập số tiền hợp lệ';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Add description validation if needed
      if (description.isEmpty) {
        errorMessage = 'Vui lòng nhập nội dung';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final repo = TransactionRepository(DatabaseProvider.instance);
      final transaction = Transaction(
        amount: amount,
        type: type == 'Chi tiêu' ? 'expense' : 'income',
        categoryName: category,
        bank: source,
        createdAt: fullDateTime,
        note: note.isNotEmpty ? note : null,
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
