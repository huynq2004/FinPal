import 'package:flutter/foundation.dart';
import '../../domain/models/transaction.dart';

class TransactionHistoryViewModel extends ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  Future<void> loadFakeData() async {
    _transactions
      ..clear()
      ..addAll([
        Transaction(
          id: 1,
          amount: 55000,
          type: 'expense',
          categoryName: 'Di chuyển',
          bank: 'VCB',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          note: 'GRAB',
        ),
        Transaction(
          id: 2,
          amount: 120000,
          type: 'expense',
          categoryName: 'Ăn uống',
          bank: 'TCB',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          note: 'THE COFFEE HOUSE',
        ),
        Transaction(
          id: 3,
          amount: 5000000,
          type: 'income',
          categoryName: 'Thu nhập',
          bank: 'ACB',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          note: 'Salary',
        ),
      ]);

    notifyListeners();
  }

  // Sprint sau: khi có TransactionRepository thì thêm
  // Future<void> loadFromDb(int year, int month) async { ... }
}
