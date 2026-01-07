import '../../domain/models/raw_sms.dart';
import '../../domain/models/parsed_sms.dart';

/// Interface/Abstract class cho bank-specific parser
abstract class BankSmsParser {
  /// Tên ngân hàng
  String get bankName;
  
  /// Danh sách các address/sender ID mà ngân hàng này sử dụng
  List<String> get senderIds;
  
  /// Kiểm tra xem SMS có phải từ ngân hàng này không
  bool canParse(String address) {
    final upperAddress = address.toUpperCase();
    return senderIds.any((id) => upperAddress.contains(id.toUpperCase()));
  }
  
  /// Parse SMS thành ParsedSms
  /// Trả về null nếu không parse được
  ParsedSms? parse(RawSms sms);
  
  /// Trích xuất số tiền từ SMS
  double? extractAmount(String text);
  
  /// Xác định loại giao dịch (thu/chi)
  TransactionType extractTransactionType(String text);
  
  /// Trích xuất thời gian giao dịch
  DateTime? extractDateTime(String text);
  
  /// Trích xuất nội dung giao dịch
  String extractContent(String text);
}

/// Base class với các phương thức chung cho tất cả banks
abstract class BaseBankParser implements BankSmsParser {
  @override
  ParsedSms? parse(RawSms sms) {
    try {
      print('🔄 [${bankName}Parser] Đang parse SMS từ: ${sms.address}');
      
      final body = sms.body;
      
      // Bước 1: Tìm số tiền
      final amount = extractAmount(body);
      if (amount == null) {
        print('❌ [${bankName}Parser] Không tìm thấy số tiền');
        return null;
      }
      
      // Bước 2: Xác định loại giao dịch
      final type = extractTransactionType(body);
      
      // Bước 3: Tìm thời gian giao dịch
      final dateTime = extractDateTime(body) ?? sms.date;
      
      // Bước 4: Trích xuất nội dung
      final content = extractContent(body);
      
      final parsed = ParsedSms(
        amount: amount,
        type: type,
        bank: bankName,
        dateTime: dateTime,
        content: content,
        rawText: body,
      );
      
      print('✅ [${bankName}Parser] Parse thành công: ${parsed.amount} VND');
      return parsed;
      
    } catch (e) {
      print('❌ [${bankName}Parser] Lỗi khi parse: $e');
      return null;
    }
  }
  
  /// Default implementation cho extractAmount
  @override
  double? extractAmount(String text) {
    final patterns = [
      RegExp(r'[-+]?\s*(\d{1,3}(?:[,\.]\d{3})*(?:[,\.]\d+)?)\s*VND', caseSensitive: false),
      RegExp(r'[-+]?\s*(\d+(?:[,\.]\d{3})*)\s*d', caseSensitive: false),
      RegExp(r'So tien[:\s]+[-+]?\s*(\d{1,3}(?:[,\.]\d{3})*)', caseSensitive: false),
      RegExp(r'GD[:\s]+[-+]?\s*(\d{1,3}(?:[,\.]\d{3})*)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String amountStr = match.group(1) ?? '';
        amountStr = amountStr.replaceAll(',', '').replaceAll('.', '');
        
        final amount = double.tryParse(amountStr);
        if (amount != null && amount > 0) {
          return amount;
        }
      }
    }
    
    return null;
  }
  
  /// Default implementation cho extractTransactionType
  @override
  TransactionType extractTransactionType(String text) {
    final lowerText = text.toLowerCase();
    
    final expenseKeywords = [
      'rut tien', 'thanh toan', 'chuyen tien', 'chuyen khoan',
      'mua hang', 'giam', 'tru', 'chi tieu', 'ghi no',
    ];
    
    final incomeKeywords = [
      'nap tien', 'chuyen den', 'nhan tien', 'hoan tien',
      'tang', 'cong', 'nhan', 'ghi co',
    ];
    
    // Kiểm tra dấu
    if (text.contains(RegExp(r'-\s*\d')) || text.contains(RegExp(r'GD:\s*-'))) {
      return TransactionType.expense;
    }
    if (text.contains(RegExp(r'\+\s*\d')) || text.contains(RegExp(r'GD:\s*\+'))) {
      return TransactionType.income;
    }
    
    // Kiểm tra từ khóa
    for (final keyword in expenseKeywords) {
      if (lowerText.contains(keyword)) {
        return TransactionType.expense;
      }
    }
    
    for (final keyword in incomeKeywords) {
      if (lowerText.contains(keyword)) {
        return TransactionType.income;
      }
    }
    
    return TransactionType.expense;
  }
  
  /// Default implementation cho extractDateTime
  @override
  DateTime? extractDateTime(String text) {
    final patterns = [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})\s+(\d{1,2}):(\d{2})'),
      RegExp(r'luc\s+(\d{1,2})[/-](\d{1,2})[/-](\d{4})\s+(\d{1,2}):(\d{2})', caseSensitive: false),
      RegExp(r'vao\s+(\d{1,2})[/-](\d{1,2})[/-](\d{4})\s+(\d{1,2}):(\d{2})', caseSensitive: false),
      RegExp(r'(\d{2})/(\d{2})/(\d{2})\s+(\d{2}):(\d{2})'), // dd/MM/yy HH:mm
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          final day = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          var year = int.parse(match.group(3)!);
          final hour = int.parse(match.group(4)!);
          final minute = int.parse(match.group(5)!);
          
          // Handle 2-digit year
          if (year < 100) {
            year += 2000;
          }
          
          return DateTime(year, month, day, hour, minute);
        } catch (e) {
          print('⚠️ [Parser] Lỗi parse thời gian: $e');
        }
      }
    }
    
    return null;
  }
  
  /// Default implementation cho extractContent
  @override
  String extractContent(String text) {
    final contentPatterns = [
      RegExp(r'ND:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'Noi dung:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'Content:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'Tai:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'Mo ta:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'tai\s+([A-Z\s]{3,})', caseSensitive: false),
    ];
    
    for (final pattern in contentPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String content = match.group(1)?.trim() ?? '';
        content = content.replaceAll(RegExp(r'[.;,]+$'), '');
        if (content.isNotEmpty && content.length < 100) {
          return content;
        }
      }
    }
    
    // Tìm các từ viết hoa
    final upperWordsMatch = RegExp(r'[A-Z]{2,}(?:\s+[A-Z]{2,})*').firstMatch(text);
    if (upperWordsMatch != null) {
      final content = upperWordsMatch.group(0)?.trim() ?? '';
      if (content.length >= 3 && content.length < 50) {
        return content;
      }
    }
    
    // Fallback
    return text.length > 50 ? text.substring(0, 50) : text;
  }
}
