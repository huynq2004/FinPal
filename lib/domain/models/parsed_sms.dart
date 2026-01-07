/// Loại giao dịch
enum TransactionType {
  income,  // Thu nhập (+ / nap tien / chuyen den)
  expense, // Chi tiêu (- / rut tien / thanh toan)
}

/// Model đại diện cho một SMS đã được parse thành công
class ParsedSms {
  final double amount;           // Số tiền (VND)
  final TransactionType type;    // Loại giao dịch (thu/chi)
  final String bank;             // Tên ngân hàng (VCB, TECHCOMBANK...)
  final DateTime dateTime;       // Thời gian giao dịch
  final String content;          // Nội dung giao dịch (GRAB, SHOPEE...)
  final String rawText;          // Toàn bộ nội dung SMS gốc
  final int? categoryId;         // ID của category (được gán bởi CategoryEngine)
  final String? categoryName;    // Tên category (Di chuyển, Mua sắm, Ăn uống...)

  ParsedSms({
    required this.amount,
    required this.type,
    required this.bank,
    required this.dateTime,
    required this.content,
    required this.rawText,
    this.categoryId,
    this.categoryName,
  });

  @override
  String toString() {
    final typeStr = type == TransactionType.income ? '+' : '-';
    return 'ParsedSms($typeStr${amount.toStringAsFixed(0)} VND, bank: $bank, date: $dateTime, content: $content, category: $categoryName)';
  }

  /// Chuyển đổi sang Map (để lưu DB sau này)
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'bank': bank,
      'dateTime': dateTime.toIso8601String(),
      'content': content,
      'rawText': rawText,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}
