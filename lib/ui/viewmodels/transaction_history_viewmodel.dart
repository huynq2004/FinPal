import 'package:flutter/foundation.dart';

import '../../domain/models/transaction.dart';

class TransactionHistoryViewModel extends ChangeNotifier {
  List<Transaction> transactions = [];

  TransactionHistoryViewModel() {
    loadFakeData();
  }

  void loadFakeData() {
    // dữ liệu fake cho lịch sử giao dịch
    transactions = [
      Transaction(
        id: 1,
        amount: 55000,
        type: 'expense',
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Transaction(
        id: 2,
        amount: 120000,
        type: 'expense',
        categoryName: 'Ăn uống',
        bank: 'TCB',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Transaction(
        id: 3,
        amount: 3000000,
        type: 'income',
        categoryName: 'Lương',
        bank: 'ACB',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    notifyListeners();
  }
}
