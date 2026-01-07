import '../../domain/models/raw_sms.dart';
import '../../domain/models/parsed_sms.dart';

/// Interface/Abstract class cho bank-specific parser
abstract class BankSmsParser {
  /// Tên ngân hàng
  String get bankName;
  
  /// Danh sách các address/sender ID mà ngân hàng này sử dụng
  List<String> get senderIds;
  
  /// Kiểm tra xem SMS có phải từ ngân hàng này không
  bool canParse(RawSms rawSms) {
    final upperAddress = rawSms.address.toUpperCase();
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
  bool canParse(RawSms rawSms) {
    final upperAddress = rawSms.address.toUpperCase();
    return senderIds.any((id) => upperAddress.contains(id.toUpperCase()));
  }
  
  @override
  ParsedSms? parse(RawSms sms) {
    try {
      final amount = extractAmount(sms.body);
      if (amount == null || amount <= 0) {
        return null;
      }
      
      final transactionType = extractTransactionType(sms.body);
      final dateTime = extractDateTime(sms.body) ?? sms.date ?? DateTime.now();
      final content = extractContent(sms.body);
      
      return ParsedSms(
        amount: amount,
        type: transactionType,
        bank: bankName,
        dateTime: dateTime,
        content: content,
        rawText: sms.body,
      );
    } catch (e) {
      print('❌ [${bankName}Parser] Error: $e');
      return null;
    }
  }
  
  /// Default implementation cho extractAmount
  @override
  double? extractAmount(String text) {
    final pattern = RegExp(
      r'([-+]?\d{1,3}(?:[,\.]\d{3})*)\s*VND',
      caseSensitive: false,
    );
    
    final match = pattern.firstMatch(text);
    if (match != null) {
      String amountStr = match.group(1) ?? '';
      amountStr = amountStr.replaceAll(RegExp(r'[-+]'), '');
      amountStr = amountStr.replaceAll(',', '').replaceAll('.', '');
      final amount = double.tryParse(amountStr);
      if (amount != null && amount > 0) {
        return amount;
      }
    }
    
    return null;
  }
  
  /// Default implementation cho extractTransactionType
  @override
  TransactionType extractTransactionType(String text) {
    final lowerText = text.toLowerCase();
    
    final expenseKeywords = [
      'thanh toan', 'rut tien', 'chi tien', 'mua', 'giao dich',
      'tai', 'so tien', 'gd:', 'chuyen tien di',
    ];
    
    final incomeKeywords = [
      'nap tien', 'gui tien', 'nhan', 'luong', 'thuong',
      'hoan tien', 'refund', 'chuyen tien den',
    ];
    
    // Kiểm tra dấu âm (chi tiêu)
    if (text.contains(RegExp(r'-\s*\d')) || text.contains(RegExp(r'GD:\s*-'))) {
      return TransactionType.expense;
    }
    
    // Kiểm tra dấu dương (thu nhập)
    if (text.contains(RegExp(r'\+\s*\d')) || text.contains(RegExp(r'GD:\s*\+'))) {
      return TransactionType.income;
    }
    
    // Kiểm tra từ khóa chi tiêu
    for (final keyword in expenseKeywords) {
      if (lowerText.contains(keyword)) {
        return TransactionType.expense;
      }
    }
    
    // Kiểm tra từ khóa thu nhập
    for (final keyword in incomeKeywords) {
      if (lowerText.contains(keyword)) {
        return TransactionType.income;
      }
    }
    
    // Mặc định: chi tiêu
    return TransactionType.expense;
  }
  
  /// Default implementation cho extractDateTime
  @override
  DateTime? extractDateTime(String text) {
    final patterns = [
      // dd/MM/yyyy HH:mm:ss
      RegExp(r'(\d{1,2})/(\d{1,2})/(\d{4})\s+(\d{1,2}):(\d{2}):(\d{2})', caseSensitive: false),
      // dd/MM/yyyy HH:mm
      RegExp(r'(\d{1,2})/(\d{1,2})/(\d{4})\s+(\d{1,2}):(\d{2})', caseSensitive: false),
      // HH:mm dd/MM/yyyy
      RegExp(r'(\d{1,2}):(\d{2})\s+(\d{1,2})/(\d{1,2})/(\d{4})', caseSensitive: false),
      // dd/MM/yyyy
      RegExp(r'(\d{1,2})/(\d{1,2})/(\d{4})', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          int day, month, year, hour = 0, minute = 0;
          
          // Xác định format dựa trên số nhóm
          if (match.groupCount == 6) {
            // dd/MM/yyyy HH:mm:ss
            day = int.parse(match.group(1) ?? '1');
            month = int.parse(match.group(2) ?? '1');
            year = int.parse(match.group(3) ?? '2024');
            hour = int.parse(match.group(4) ?? '0');
            minute = int.parse(match.group(5) ?? '0');
          } else if (match.groupCount == 5) {
            // dd/MM/yyyy HH:mm hoặc HH:mm dd/MM/yyyy
            if (match.group(1)!.length <= 2 && int.parse(match.group(1)!) <= 31) {
              // dd/MM/yyyy HH:mm
              day = int.parse(match.group(1) ?? '1');
              month = int.parse(match.group(2) ?? '1');
              year = int.parse(match.group(3) ?? '2024');
              hour = int.parse(match.group(4) ?? '0');
              minute = int.parse(match.group(5) ?? '0');
            } else {
              // HH:mm dd/MM/yyyy
              hour = int.parse(match.group(1) ?? '0');
              minute = int.parse(match.group(2) ?? '0');
              day = int.parse(match.group(3) ?? '1');
              month = int.parse(match.group(4) ?? '1');
              year = int.parse(match.group(5) ?? '2024');
            }
          } else if (match.groupCount == 3) {
            // dd/MM/yyyy
            day = int.parse(match.group(1) ?? '1');
            month = int.parse(match.group(2) ?? '1');
            year = int.parse(match.group(3) ?? '2024');
          } else {
            continue;
          }
          
          return DateTime(year, month, day, hour, minute);
        } catch (e) {
          continue;
        }
      }
    }
    
    return null;
  }
  
  /// Default implementation cho extractContent
  @override
  String extractContent(String text) {
    final contentPatterns = [
      RegExp(r'ND:\s*([^\n\r.;]+)', caseSensitive: false),
      RegExp(r'Noi dung:\s*([^\n\r.;]+)', caseSensitive: false),
      RegExp(r'Tai:\s*([^\n\r.;]+)', caseSensitive: false),
      RegExp(r'tai\s+([A-Z][A-Z\s]+?)(?:[.;,]|\s+[A-Z]{2,})', caseSensitive: false),
    ];
    
    for (final pattern in contentPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String content = match.group(1)?.trim() ?? '';
        content = content.replaceAll(RegExp(r'[.;,]+$'), '').trim();
        if (content.isNotEmpty && content.length < 100) {
          return content;
        }
      }
    }
    
    // Tìm các từ viết hoa liên tiếp (thường là merchant name)
    final uppercasePattern = RegExp(r'\b([A-Z]{2,}(?:\s+[A-Z]+)*)\b');
    final matches = uppercasePattern.allMatches(text);
    
    for (final match in matches) {
      final content = match.group(1) ?? '';
      if (content.length > 2 && content.length < 50 && 
          !content.contains(RegExp(r'(TK|VND|GD|ND|SD|SO|DU)')) &&
          !content.contains(RegExp(r'\d'))) {
        return content;
      }
    }
    
    return 'Giao dịch';
  }
}
