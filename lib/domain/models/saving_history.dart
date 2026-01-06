class SavingHistory {
  final int? id;
  final int goalId;
  final int amount; // Số tiền thêm vào (dương) hoặc rút ra (âm)
  final String type; // 'add' hoặc 'withdraw'
  final String? note; // Ghi chú
  final DateTime createdAt;

  const SavingHistory({
    this.id,
    required this.goalId,
    required this.amount,
    required this.type,
    this.note,
    required this.createdAt,
  });

  SavingHistory copyWith({
    int? id,
    int? goalId,
    int? amount,
    String? type,
    String? note,
    DateTime? createdAt,
  }) {
    return SavingHistory(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SavingHistory.fromMap(Map<String, dynamic> map) {
    return SavingHistory(
      id: map['id'] as int?,
      goalId: map['goal_id'] as int,
      amount: map['amount'] as int,
      type: map['type'] as String,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'amount': amount,
      'type': type,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
