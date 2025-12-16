class Transaction {
  final int? id; // null nếu fake, có id khi lấy từ DB
  final int amount;
  final String type; // 'income' | 'expense'
  final int? categoryId; // ID của category trong DB
  final String categoryName; // Tên category để hiển thị
  final String? bank;
  final DateTime createdAt;
  final String? note;
  final String source; // Nguồn giao dịch (manual, sms, etc.)

  const Transaction({
    this.id,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.categoryName,
    this.bank,
    required this.createdAt,
    this.note,
    required this.source,
  });

  Transaction copyWith({
    int? id,
    int? amount,
    String? type,
    int? categoryId,
    String? categoryName,
    String? bank,
    DateTime? createdAt,
    String? note,
    String? source,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      bank: bank ?? this.bank,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      source: source ?? this.source,
    );
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      amount: map['amount'] as int,
      type: map['type'] as String,
      categoryId: map['category_id'] as int?,
      categoryName: map['categoryName'] ?? map['category'] ?? '',
      bank: map['bank'] as String?,
      createdAt: DateTime.parse(map['created_at'] ?? map['createdAt'] ?? map['date_time']),
      note: map['note'] as String?,
      source: map['source'] as String? ?? 'manual',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'bank': bank,
      'created_at': createdAt.toIso8601String(),
      'note': note,
      'source': source,
    };
  }
}
