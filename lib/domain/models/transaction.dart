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

  Transaction copyWith({
    int? id,
    int? amount,
    String? type,
    String? categoryName,
    String? bank,
    DateTime? createdAt,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryName: categoryName ?? this.categoryName,
      bank: bank ?? this.bank,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      amount: map['amount'] as int,
      type: map['type'] as String,
      categoryName: map['categoryName'] ?? map['category'] ?? '',
      bank: map['bank'] as String?,
      createdAt: DateTime.parse(map['created_at'] ?? map['createdAt'] ?? map['date_time']),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': categoryName,
      'bank': bank,
      'created_at': createdAt.toIso8601String(),
      'note': note,
    };
  }
}
