class SavingGoal {
  final int? id;
  final String name;
  final int targetAmount; // mục tiêu: VND
  final int currentSaved; // đã tiết kiệm: VND
  final DateTime deadline; // hạn đạt mục tiêu
  final DateTime createdAt; // ngày tạo hũ

  const SavingGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentSaved,
    required this.deadline,
    required this.createdAt,
  });

  SavingGoal copyWith({
    int? id,
    String? name,
    int? targetAmount,
    int? currentSaved,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentSaved: currentSaved ?? this.currentSaved,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SavingGoal.fromMap(Map<String, dynamic> map) {
    return SavingGoal(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetAmount: map['target_amount'] as int,
      currentSaved: map['current_saved'] as int,
      deadline: DateTime.parse(map['deadline'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_saved': currentSaved,
      'deadline': deadline.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
