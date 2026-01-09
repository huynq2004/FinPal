import 'package:flutter_test/flutter_test.dart';
import 'package:finpal/data/repositories/sms_parser.dart';
import 'package:finpal/domain/models/raw_sms.dart';
import 'package:finpal/domain/models/parsed_sms.dart';

void main() {
  group('SmsParser with CategoryEngine Integration Tests', () {
    late SmsParser parser;

    setUp(() {
      parser = SmsParser();
    });

    test('Parse SMS GRAB - phân loại Di chuyển', () {
      final rawSms = RawSms(
        address: 'VCB',
        body: 'TK 1234567890 -55,000VND 29/12/2024 10:30. ND: GRAB 28Dec. So du: 1,500,000VND',
        date: DateTime(2024, 12, 29, 10, 30),
        id: 1,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, 55000);
      expect(parsed.type, TransactionType.expense);
      expect(parsed.content.toLowerCase(), contains('grab'));
      expect(parsed.categoryId, 1); // Di chuyển
      expect(parsed.categoryName, 'Di chuyển');
    });

    test('Parse SMS SHOPEE - phân loại Mua sắm', () {
      final rawSms = RawSms(
        address: 'TECHCOMBANK',
        body: 'TK 9876543210 -120,500VND 29/12/2024 14:20. ND: SHOPEE ORDER 123456. So du: 800,000VND',
        date: DateTime(2024, 12, 29, 14, 20),
        id: 2,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, 120500);
      expect(parsed.type, TransactionType.expense);
      expect(parsed.content.toLowerCase(), contains('shopee'));
      expect(parsed.categoryId, 2); // Mua sắm
      expect(parsed.categoryName, 'Mua sắm');
    });

    test('Parse SMS HIGHLANDS - phân loại Ăn uống', () {
      final rawSms = RawSms(
        address: 'MB',
        body: 'TK 1111222233 -75,000VND 29/12/2024 16:45. Tai: HIGHLANDS COFFEE CN HN. So du: 2,000,000VND',
        date: DateTime(2024, 12, 29, 16, 45),
        id: 3,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, 75000);
      expect(parsed.type, TransactionType.expense);
      expect(parsed.content.toLowerCase(), contains('highlands'));
      expect(parsed.categoryId, 3); // Ăn uống
      expect(parsed.categoryName, 'Ăn uống');
    });

    test('Parse SMS THE COFFEE HOUSE - phân loại Ăn uống', () {
      final rawSms = RawSms(
        address: 'ACB',
        body: 'TK 5555666677 -89,000VND 30/12/2024 09:15. ND: THE COFFEE HOUSE. So du: 1,200,000VND',
        date: DateTime(2024, 12, 30, 9, 15),
        id: 4,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, 89000);
      expect(parsed.type, TransactionType.expense);
      expect(parsed.content.toLowerCase(), contains('coffee'));
      expect(parsed.categoryId, 3); // Ăn uống
      expect(parsed.categoryName, 'Ăn uống');
    });

    test('Parse SMS GRAB FOOD - phân loại Ăn uống (không phải Di chuyển)', () {
      final rawSms = RawSms(
        address: 'BIDV',
        body: 'TK 7777888899 -150,000VND 30/12/2024 12:30. ND: GRAB FOOD ORDER. So du: 900,000VND',
        date: DateTime(2024, 12, 30, 12, 30),
        id: 5,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, 150000);
      expect(parsed.type, TransactionType.expense);
      expect(parsed.content.toLowerCase(), contains('grab'));
      expect(parsed.categoryId, 3); // Ăn uống (vì "grab food" match trước "grab")
      expect(parsed.categoryName, 'Ăn uống');
    });

    test('Parse SMS không có keyword - phân loại Khác', () {
      final rawSms = RawSms(
        address: 'VIETINBANK',
        body: 'TK 3333444455 -200,000VND 30/12/2024 18:00. ND: UNKNOWN COMPANY ABC. So du: 500,000VND',
        date: DateTime(2024, 12, 30, 18, 0),
        id: 6,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, 200000);
      expect(parsed.type, TransactionType.expense);
      expect(parsed.categoryId, 99); // Khác
      expect(parsed.categoryName, 'Khác');
    });

    test('Parse nhiều SMS cùng lúc và verify category', () {
      final smsList = [
        RawSms(
          address: 'VCB',
          body: 'TK 1234 -50,000VND 01/01/2025. ND: GRAB',
          date: DateTime(2025, 1, 1),
          id: 1,
        ),
        RawSms(
          address: 'TCB',
          body: 'TK 5678 -100,000VND 01/01/2025. ND: LAZADA',
          date: DateTime(2025, 1, 1),
          id: 2,
        ),
        RawSms(
          address: 'MB',
          body: 'TK 9999 -80,000VND 01/01/2025. Tai: STARBUCKS',
          date: DateTime(2025, 1, 1),
          id: 3,
        ),
      ];

      final results = parser.parseMultiple(smsList);

      expect(results.length, 3);
      
      // GRAB → Di chuyển
      expect(results[0].categoryId, 1);
      expect(results[0].categoryName, 'Di chuyển');
      
      // LAZADA → Mua sắm
      expect(results[1].categoryId, 2);
      expect(results[1].categoryName, 'Mua sắm');
      
      // STARBUCKS → Ăn uống
      expect(results[2].categoryId, 3);
      expect(results[2].categoryName, 'Ăn uống');
    });

    test('Parse SMS với content có dấu tiếng Việt', () {
      final rawSms = RawSms(
        address: 'ACB',
        body: 'TK 1111 -45,000VND 02/01/2025. ND: Phúc Long Coffee',
        date: DateTime(2025, 1, 2),
        id: 7,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.categoryId, 3); // Ăn uống (normalize "Phúc Long" → "phuc long")
      expect(parsed.categoryName, 'Ăn uống');
    });
  });
}
