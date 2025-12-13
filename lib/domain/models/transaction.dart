class Transaction {
  final int? id; // null nếu fake, có id khi lấy từ DB
  final int amount;
  final String type; // 'income' | 'expense'
  final String categoryName;
  final String? bank;
  final DateTime createdAt;
  final String? note;

  const Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryName,
    this.bank,
    required this.createdAt,
    this.note,
  });
}
