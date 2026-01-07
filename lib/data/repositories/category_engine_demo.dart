import 'package:finpal/data/repositories/category_engine.dart';
import 'package:finpal/data/repositories/sms_parser.dart';
import 'package:finpal/domain/models/raw_sms.dart';

/// Demo file để showcase CategoryEngine functionality
void main() {
  print('═══════════════════════════════════════════════');
  print('📱 DEMO: CategoryEngine - Rule-based Classification');
  print('═══════════════════════════════════════════════\n');

  final engine = CategoryEngine();
  final parser = SmsParser();

  // Demo 1: Test keywords trực tiếp
  print('🔹 DEMO 1: Phân loại keywords trực tiếp\n');
  
  final testCases = [
    'GRAB',
    'SHOPEE',
    'HIGHLANDS COFFEE',
    'THE COFFEE HOUSE',
    'GRAB FOOD',
    'LAZADA',
    'Phúc Long',
    'UNKNOWN COMPANY',
  ];

  for (final content in testCases) {
    final categoryId = engine.classify(content);
    final categoryName = engine.getCategoryNameById(categoryId);
    print('📍 "$content" → [$categoryId] $categoryName');
  }

  print('\n═══════════════════════════════════════════════\n');

  // Demo 2: Parse SMS thực tế
  print('🔹 DEMO 2: Parse SMS thực tế với CategoryEngine\n');

  final demoSms = [
    RawSms(
      address: 'VCB',
      body: 'TK 1234567890 -55,000VND 29/12/2024 10:30. ND: GRAB 28Dec. So du: 1,500,000VND',
      date: DateTime(2024, 12, 29, 10, 30),
      id: 1,
    ),
    RawSms(
      address: 'TECHCOMBANK',
      body: 'TK 9876543210 -120,500VND 29/12/2024 14:20. ND: SHOPEE ORDER 123456. So du: 800,000VND',
      date: DateTime(2024, 12, 29, 14, 20),
      id: 2,
    ),
    RawSms(
      address: 'MB',
      body: 'TK 1111222233 -75,000VND 29/12/2024 16:45. Tai: HIGHLANDS COFFEE CN HN. So du: 2,000,000VND',
      date: DateTime(2024, 12, 29, 16, 45),
      id: 3,
    ),
    RawSms(
      address: 'ACB',
      body: 'TK 5555666677 -89,000VND 30/12/2024 09:15. ND: THE COFFEE HOUSE. So du: 1,200,000VND',
      date: DateTime(2024, 12, 30, 9, 15),
      id: 4,
    ),
    RawSms(
      address: 'BIDV',
      body: 'TK 7777888899 -150,000VND 30/12/2024 12:30. ND: GRAB FOOD ORDER. So du: 900,000VND',
      date: DateTime(2024, 12, 30, 12, 30),
      id: 5,
    ),
  ];

  final parsedResults = parser.parseMultiple(demoSms);

  print('\n📊 Kết quả parse:\n');
  for (final parsed in parsedResults) {
    print('   💰 ${parsed.amount.toStringAsFixed(0)} VND');
    print('   🏪 Content: ${parsed.content}');
    print('   📁 Category: [${parsed.categoryId}] ${parsed.categoryName}');
    print('   🏦 Bank: ${parsed.bank}');
    print('   📅 Date: ${parsed.dateTime}');
    print('   ─────────────────────────────────────────');
  }

  print('\n═══════════════════════════════════════════════');
  print('✅ Demo completed!');
  print('═══════════════════════════════════════════════\n');
}
