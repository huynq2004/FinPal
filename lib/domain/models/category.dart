// lib/domain/models/category.dart

enum CategoryType {
  expense,
  income,
}

class Category {
  final String id;
  final String name;
  final String emoji;
  final String backgroundColor; // RGB color in hex format
  final CategoryType type;
  final bool isDefault;
  final int transactionCount;

  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.backgroundColor,
    required this.type,
    required this.isDefault,
    required this.transactionCount,
  });

  Category copyWith({
    String? id,
    String? name,
    String? emoji,
    String? backgroundColor,
    CategoryType? type,
    bool? isDefault,
    int? transactionCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }
}
