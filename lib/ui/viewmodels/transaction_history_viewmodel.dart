import 'package:flutter/foundation.dart';
import '../../domain/models/transaction.dart';

class TransactionHistoryViewModel extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  // tạm dùng fake data
  Future<void> loadFakeData() async {
    _transactions = [
      Transaction(
        id: 1,
        amount: 55000,
        type: 'expense',
        categoryName: 'Di chuyển',
        bank: 'VCB',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Transaction(
        id: 2,
        amount: 120000,
        type: 'expense',
        categoryName: 'Ăn uống',
        bank: 'TCB',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: 3,
        amount: 5000000,
        type: 'income',
        categoryName: 'Lương',
        bank: 'VCB',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    notifyListeners();
  }

  // sau này dùng hàm này nếu đã có repository
  Future<void> loadTransactionsForMonth(int year, int month) async {
    // TODO: gọi TransactionRepository.getTransactionsByMonth(...)
    // _transactions = await _transactionRepository.getTransactionsByMonth(year, month);
    // notifyListeners();
  }
}
