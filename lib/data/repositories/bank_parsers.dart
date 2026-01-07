import '../../domain/models/raw_sms.dart';
import '../../domain/models/parsed_sms.dart';
import 'bank_parser_base.dart';

/// Parser cho Vietcombank (VCB)
/// Format SMS: "TK 1234567890 -55,000VND 29/12/2024 10:30. ND: GRAB. So du: 1,500,000VND"
class VietcombankParser extends BaseBankParser {
  @override
  String get bankName => 'Vietcombank';
  
  @override
  List<String> get senderIds => ['VCB', 'VIETCOMBANK'];
  
  @override
  double? extractAmount(String text) {
    // VCB format: "TK xxx -55,000VND" hoặc "GD: -55,000"
    final patterns = [
      RegExp(r'TK\s+\d+\s+([-+]?\d{1,3}(?:[,\.]\d{3})*)\s*VND', caseSensitive: false),
      RegExp(r'GD:\s*([-+]?\d{1,3}(?:[,\.]\d{3})*)\s*VND', caseSensitive: false),
      ...super.extractAmount(text) != null ? [] : [
        RegExp(r'([-+]?\d{1,3}(?:[,\.]\d{3})*)\s*VND', caseSensitive: false),
      ],
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
    
    return super.extractAmount(text);
  }
}

/// Parser cho Techcombank (TCB)
/// Format SMS: "TK 9876543210 GD: -120,500VND luc 29/12/2024 14:20. ND: SHOPEE"
class TechcombankParser extends BaseBankParser {
  @override
  String get bankName => 'Techcombank';
  
  @override
  List<String> get senderIds => ['TECHCOMBANK', 'TCB'];
  
  @override
  double? extractAmount(String text) {
    // Techcombank format: "GD: -120,500VND"
    final patterns = [
      RegExp(r'GD:\s*([-+]?\d{1,3}(?:[,\.]\d{3})*)\s*VND', caseSensitive: false),
      RegExp(r'So tien GD:\s*([-+]?\d{1,3}(?:[,\.]\d{3})*)', caseSensitive: false),
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
    
    return super.extractAmount(text);
  }
}

/// Parser cho MBBank (MB)
/// Format SMS: "TK 1111222233 -75,000VND 29/12/2024 16:45. Tai: HIGHLANDS COFFEE"
class MBBankParser extends BaseBankParser {
  @override
  String get bankName => 'MBBank';
  
  @override
  List<String> get senderIds => ['MBBANK', 'MB'];
  
  @override
  String extractContent(String text) {
    // MBBank thường dùng "Tai:" thay vì "ND:"
    final patterns = [
      RegExp(r'Tai:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'ND:\s*([^\n\r.]+)', caseSensitive: false),
      RegExp(r'Noi dung:\s*([^\n\r.]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String content = match.group(1)?.trim() ?? '';
        content = content.replaceAll(RegExp(r'[.;,]+$'), '');
        if (content.isNotEmpty && content.length < 100) {
          return content;
        }
      }
    }
    
    return super.extractContent(text);
  }
}

/// Parser cho ACB
/// Format SMS: "TK 5555666677 -89,000VND 30/12/2024 09:15. ND: THE COFFEE HOUSE"
class ACBParser extends BaseBankParser {
  @override
  String get bankName => 'ACB';
  
  @override
  List<String> get senderIds => ['ACB'];
}

/// Parser cho BIDV
/// Format SMS: "TK 7777888899 -150,000VND 30/12/2024 12:30. ND: GRAB FOOD ORDER"
class BIDVParser extends BaseBankParser {
  @override
  String get bankName => 'BIDV';
  
  @override
  List<String> get senderIds => ['BIDV'];
}

/// Parser cho Vietinbank
class VietinbankParser extends BaseBankParser {
  @override
  String get bankName => 'Vietinbank';
  
  @override
  List<String> get senderIds => ['VIETINBANK', 'VTB'];
}

/// Parser cho VPBank
class VPBankParser extends BaseBankParser {
  @override
  String get bankName => 'VPBank';
  
  @override
  List<String> get senderIds => ['VPBANK', 'VPB'];
}

/// Parser cho Sacombank
class SacombankParser extends BaseBankParser {
  @override
  String get bankName => 'Sacombank';
  
  @override
  List<String> get senderIds => ['SACOMBANK', 'STB'];
}

/// Parser cho HDBank
class HDBankParser extends BaseBankParser {
  @override
  String get bankName => 'HDBank';
  
  @override
  List<String> get senderIds => ['HDBANK', 'HDB'];
}

/// Parser cho TPBank
class TPBankParser extends BaseBankParser {
  @override
  String get bankName => 'TPBank';
  
  @override
  List<String> get senderIds => ['TPBANK', 'TPB'];
}

/// Parser cho SeABank
class SeABankParser extends BaseBankParser {
  @override
  String get bankName => 'SeABank';
  
  @override
  List<String> get senderIds => ['SEABANK', 'SEA'];
}

/// Parser cho Agribank
class AgribankParser extends BaseBankParser {
  @override
  String get bankName => 'Agribank';
  
  @override
  List<String> get senderIds => ['AGRIBANK', 'ARB'];
}

/// Parser cho SHB
class SHBParser extends BaseBankParser {
  @override
  String get bankName => 'SHB';
  
  @override
  List<String> get senderIds => ['SHB'];
}

/// Parser cho VIB
class VIBParser extends BaseBankParser {
  @override
  String get bankName => 'VIB';
  
  @override
  List<String> get senderIds => ['VIB'];
}

/// Parser cho OCB
class OCBParser extends BaseBankParser {
  @override
  String get bankName => 'OCB';
  
  @override
  List<String> get senderIds => ['OCB'];
}
