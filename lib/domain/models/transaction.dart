class Transaction {
  final int id;
  final int amount; // dùng int cho đơn giản
  final String type; // 'income' hoặc 'expense'
  final String categoryName;
  final String? bank;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryName,
    this.bank,
    required this.createdAt,
  });
}
