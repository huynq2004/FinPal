class Budget {
  final int? id;
  final int categoryId;
  final int limitAmount; // đơn vị: VND
  final int month; // 1..12
  final int year; // ví dụ: 2025

  const Budget({
    this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  Budget copyWith({
    int? id,
    int? categoryId,
    int? limitAmount,
    int? month,
    int? year,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      limitAmount: map['limit_amount'] as int,
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'limit_amount': limitAmount,
      'month': month,
      'year': year,
    };
  }
}
