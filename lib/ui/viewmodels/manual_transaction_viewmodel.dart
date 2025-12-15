import 'package:flutter/material.dart';

import 'package:finpal/domain/models/transaction.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/db/database_provider.dart';
import 'package:intl/intl.dart';

class ManualTransactionViewModel extends ChangeNotifier {
    String? errorMessage;
    Future<void> saveTransaction() async {
      try {
        errorMessage = null;
        final repo = TransactionRepository(DatabaseProvider.instance);
        final transaction = Transaction(
          amount: amount,
          type: type == 'Chi tiêu' ? 'expense' : 'income',
          categoryName: category,
          bank: source,
          createdAt: DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ),
          note: note.isNotEmpty ? note : null,
        );
        await repo.insertTransaction(transaction);
      } catch (e) {
        errorMessage = e.toString();
        rethrow;
      }
    }
  int amount = 0;
  String type = 'Chi tiêu';
  String category = 'Ăn uống';
  String source = 'Vietcombank';
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  String description = '';
  String note = '';

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
  String get formattedTime => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
