import '../../domain/models/raw_sms.dart';
import '../../domain/models/parsed_sms.dart';
import 'category_engine.dart';
import 'bank_parser_base.dart';
import 'bank_parsers.dart';

/// Class xử lý parse SMS ngân hàng thành dữ liệu có cấu trúc
/// Sử dụng bank-specific parsers để hỗ trợ nhiều định dạng SMS
class SmsParser {
  final CategoryEngine _categoryEngine = CategoryEngine();
  
  /// Danh sách các bank parsers
  final List<BankSmsParser> _bankParsers = [
    VietcombankParser(),
    TechcombankParser(),
    MBBankParser(),
    ACBParser(),
    BIDVParser(),
    VietinbankParser(),
    VPBankParser(),
    SacombankParser(),
    HDBankParser(),
    TPBankParser(),
    SeABankParser(),
    AgribankParser(),
    SHBParser(),
    VIBParser(),
    OCBParser(),
  ];
  
  /// Parse một SMS thành ParsedSms
  /// Trả về null nếu không thể parse (SMS không đúng format ngân hàng)
  ParsedSms? parse(RawSms sms) {
    try {
      print('🔄 [Parser] Đang parse SMS từ: ${sms.address}');
      
      // Tìm parser phù hợp với bank
      BankSmsParser? selectedParser;
      for (final parser in _bankParsers) {
        if (parser.canParse(sms.address)) {
          selectedParser = parser;
          print('✅ [Parser] Sử dụng ${parser.bankName}Parser');
          break;
        }
      }
      
      // Nếu không tìm thấy parser cụ thể, dùng generic parser
      if (selectedParser == null) {
        print('⚠️ [Parser] Không tìm thấy parser cụ thể, dùng generic parser');
        return _parseGeneric(sms);
      }
      
      // Parse bằng bank-specific parser
      final parsed = selectedParser.parse(sms);
      
      if (parsed == null) {
        print('❌ [Parser] ${selectedParser.bankName}Parser không parse được');
        return null;
      }
      
      // Bổ sung categoryId và categoryName
      final categoryId = _categoryEngine.classify(parsed.content);
      final categoryName = _categoryEngine.getCategoryNameById(categoryId);
      
      final enrichedParsed = ParsedSms(
        amount: parsed.amount,
        type: parsed.type,
        bank: parsed.bank,
        dateTime: parsed.dateTime,
        content: parsed.content,
        rawText: parsed.rawText,
        categoryId: categoryId,
        categoryName: categoryName,
      );
      
      print('✅ [Parser] Parse thành công: $enrichedParsed');
      return enrichedParsed;
      
    } catch (e) {
      print('❌ [Parser] Lỗi khi parse: $e');
      return null;
    }
  }
  
  /// Generic parser cho các SMS không match bank cụ thể
  ParsedSms? _parseGeneric(RawSms sms) {
    try {
      final body = sms.body;
      final address = sms.address;
      
      // Bước 1: Tìm số tiền
      final amount = _extractAmount(body);
      if (amount == null) {
        print('❌ [GenericParser] Không tìm thấy số tiền');
        return null;
      }
      
      // Bước 2: Xác định loại giao dịch (thu/chi)
      final type = _extractTransactionType(body);
      
      // Bước 3: Lấy tên ngân hàng từ address
      final bank = _extractBank(address);
      
      // Bước 4: Tìm thời gian giao dịch
      final dateTime = _extractDateTime(body) ?? sms.date;
      
      // Bước 5: Trích xuất nội dung giao dịch
      final content = _extractContent(body);
      
      // Bước 6: Phân loại category
      final categoryId = _categoryEngine.classify(content);
      final categoryName = _categoryEngine.getCategoryNameById(categoryId);
      
      final parsed = ParsedSms(
        amount: amount,
        type: type,
        bank: bank,
        dateTime: dateTime,
        content: content,
        rawText: body,
        categoryId: categoryId,
        categoryName: categoryName,
      );
      
      print('✅ [GenericParser] Parse thành công: $parsed');
      return parsed;
      
    } catch (e) {
      print('❌ [GenericParser] Lỗi khi parse: $e');
      return null;
    }
  }
  
  /// Trích xuất số tiền từ SMS
  /// Format: -55,000VND hoặc +100.000 VND hoặc 1,200,000VND
  double? _extractAmount(String text) {
    // Pattern: số (có thể có dấu - hoặc +), có thể có dấu phẩy/chấm ngăn cách, theo sau là VND
    final patterns = [
      RegExp(r'[-+]?\s*(\d{1,3}(?:[,\.]\d{3})*(?:[,\.]\d+)?)\s*VND', caseSensitive: false),
      RegExp(r'[-+]?\s*(\d+(?:[,\.]\d{3})*)\s*d', caseSensitive: false), // "55,000d"
      RegExp(r'So tien[:\s]+[-+]?\s*(\d{1,3}(?:[,\.]\d{3})*)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String amountStr = match.group(1) ?? '';
        // Loại bỏ dấu phẩy và chấm phân cách hàng nghìn
        amountStr = amountStr.replaceAll(',', '').replaceAll('.', '');
        
        final amount = double.tryParse(amountStr);
        if (amount != null && amount > 0) {
          return amount;
        }
      }
    }
    
    return null;
  }
  
  /// Xác định loại giao dịch (thu hay chi)
  TransactionType _extractTransactionType(String text) {
    final lowerText = text.toLowerCase();
    
    // Từ khóa chi tiêu
    final expenseKeywords = [
      'rut tien',
      'thanh toan',
      'chuyen tien',
      'chuyen khoan',
      'mua hang',
      'giam',
    ];
    
    // Từ khóa thu nhập
    final incomeKeywords = [
      'nap tien',
      'chuyen den',
      'nhan tien',
      'hoan tien',
      'tang',
    ];
    
    // Kiểm tra dấu - hoặc + ở đầu số tiền
    if (text.contains(RegExp(r'-\s*\d'))) {
      return TransactionType.expense;
    }
    if (text.contains(RegExp(r'\+\s*\d'))) {
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
    
    // Mặc định: chi tiêu (vì đa số SMS là thông báo chi)
    return TransactionType.expense;
  }
  
  /// Lấy tên ngân hàng từ address
  String _extractBank(String address) {
    final upperAddress = address.toUpperCase();
    
    // Danh sách tên ngân hàng
    final banks = {
      'VCB': 'Vietcombank',
      'VIETCOMBANK': 'Vietcombank',
      'TECHCOMBANK': 'Techcombank',
      'TCB': 'Techcombank',
      'ACB': 'ACB',
      'BIDV': 'BIDV',
      'VIETINBANK': 'Vietinbank',
      'VPBANK': 'VPBank',
      'MBBANK': 'MBBank',
      'MB': 'MBBank',
      'SACOMBANK': 'Sacombank',
      'HDBANK': 'HDBank',
      'OCB': 'OCB',
      'TPBANK': 'TPBank',
      'SEABANK': 'SeABank',
      'AGRIBANK': 'Agribank',
      'SHB': 'SHB',
      'VIB': 'VIB',
    };
    
    for (final entry in banks.entries) {
      if (upperAddress.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Nếu không tìm thấy, trả về address gốc
    return address;
  }
  
  /// Trích xuất thời gian giao dịch từ SMS
  /// Format: dd/MM/yyyy HH:mm hoặc dd-MM-yyyy HH:mm
  DateTime? _extractDateTime(String text) {
    // Pattern: dd/MM/yyyy HH:mm hoặc dd-MM-yyyy HH:mm
    final patterns = [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})\s+(\d{1,2}):(\d{2})'),
      RegExp(r'luc\s+(\d{1,2})[/-](\d{1,2})[/-](\d{4})\s+(\d{1,2}):(\d{2})', caseSensitive: false),
      RegExp(r'vao\s+(\d{1,2})[/-](\d{1,2})[/-](\d{4})\s+(\d{1,2}):(\d{2})', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          final day = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          final year = int.parse(match.group(3)!);
          final hour = int.parse(match.group(4)!);
          final minute = int.parse(match.group(5)!);
          
          return DateTime(year, month, day, hour, minute);
        } catch (e) {
          print('⚠️ [Parser] Lỗi parse thời gian: $e');
        }
      }
    }
    
    return null;
  }
  
  /// Trích xuất nội dung giao dịch (merchant, purpose)
  /// VD: "GRAB", "SHOPEE", "THE COFFEE HOUSE"
  String _extractContent(String text) {
    // Pattern: ND: hoặc Noi dung: hoặc Content:
    final contentPatterns = [
      RegExp(r'ND:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'Noi dung:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'Content:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'Tai:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'tai\s+([A-Z\s]{3,})', caseSensitive: false), // "tai GRAB" or "tai THE COFFEE HOUSE"
    ];
    
    for (final pattern in contentPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String content = match.group(1)?.trim() ?? '';
        // Loại bỏ các ký tự đặc biệt cuối cùng
        content = content.replaceAll(RegExp(r'[.;,]+$'), '');
        if (content.isNotEmpty && content.length < 100) {
          return content;
        }
      }
    }
    
    // Nếu không tìm thấy pattern cụ thể, tìm các từ viết hoa liền nhau
    final upperWordsMatch = RegExp(r'[A-Z]{2,}(?:\s+[A-Z]{2,})*').firstMatch(text);
    if (upperWordsMatch != null) {
      final content = upperWordsMatch.group(0)?.trim() ?? '';
      if (content.length >= 3 && content.length < 50) {
        return content;
      }
    }
    
    // Fallback: lấy 50 ký tự đầu của SMS
    return text.length > 50 ? text.substring(0, 50) : text;
  }
  
  /// Parse nhiều SMS cùng lúc
  List<ParsedSms> parseMultiple(List<RawSms> smsList) {
    final results = <ParsedSms>[];
    
    print('\n🔄 [Parser] Bắt đầu parse ${smsList.length} SMS...');
    
    for (final sms in smsList) {
      final parsed = parse(sms);
      if (parsed != null) {
        results.add(parsed);
      }
    }
    
    print('✅ [Parser] Hoàn thành: ${results.length}/${smsList.length} SMS parse thành công');
    print('❌ [Parser] Thất bại: ${smsList.length - results.length} SMS\n');
    
    return results;
  }
}
