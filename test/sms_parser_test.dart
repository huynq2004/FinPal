import 'package:flutter_test/flutter_test.dart';
import 'package:finpal/domain/models/raw_sms.dart';
import 'package:finpal/domain/models/parsed_sms.dart';
import 'package:finpal/data/repositories/sms_parser.dart';

void main() {
  group('SmsParser Tests', () {
    late SmsParser parser;

    setUp(() {
      parser = SmsParser();
    });

    test('Parse Vietcombank expense SMS correctly', () {
      final rawSms = RawSms(
        address: 'VCB',
        body: 'Bien dong so du TK 001234567: -55,000VND luc 07/01/2026 09:30. ND: GRAB. So du: 1,500,000VND',
        date: DateTime.now(),
        id: 1,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(55000.0));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.bank, equals('Vietcombank'));
      expect(parsed.content, contains('GRAB'));
    });

    test('Parse Techcombank income SMS correctly', () {
      final rawSms = RawSms(
        address: 'TECHCOMBANK',
        body: 'TK 1905012345678 nhan tien +2,000,000VND vao 07/01/2026 14:20. ND: Chuyen tien luong thang 1',
        date: DateTime.now(),
        id: 2,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(2000000.0));
      expect(parsed.type, equals(TransactionType.income));
      expect(parsed.bank, equals('Techcombank'));
    });

    test('Parse ACB expense SMS correctly', () {
      final rawSms = RawSms(
        address: 'ACB',
        body: 'TK 123456 giao dich -120,000 VND tai THE COFFEE HOUSE luc 07/01/2026 08:15',
        date: DateTime.now(),
        id: 3,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(120000.0));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.bank, equals('ACB'));
      expect(parsed.content.toUpperCase(), contains('COFFEE'));
    });

    test('Parse MBBank SHOPEE transaction', () {
      final rawSms = RawSms(
        address: 'MBBANK',
        body: 'TK 9876543210 thanh toan -350,000VND tai SHOPEE luc 06/01/2026 20:45. So du: 5,200,000VND',
        date: DateTime.now(),
        id: 4,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(350000.0));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.bank, equals('MBBank'));
      expect(parsed.content.toUpperCase(), contains('SHOPEE'));
    });

    test('Parse VPBank with dot separator', () {
      final rawSms = RawSms(
        address: 'VPBANK',
        body: 'So tien: -1.500.000VND. Thoi gian: 07/01/2026 11:00. Noi dung: Thanh toan hoa don',
        date: DateTime.now(),
        id: 5,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(1500000.0));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.bank, equals('VPBank'));
    });

    test('Return null for non-bank SMS', () {
      final rawSms = RawSms(
        address: 'FRIEND',
        body: 'Hello, how are you doing today?',
        date: DateTime.now(),
        id: 6,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNull);
    });

    test('Return null for SMS without amount', () {
      final rawSms = RawSms(
        address: 'VCB',
        body: 'Thong bao: Tai khoan cua quy khach da duoc kich hoat thanh cong.',
        date: DateTime.now(),
        id: 7,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNull);
    });

    test('Parse multiple SMS at once', () {
      final smsList = [
        RawSms(
          address: 'VCB',
          body: 'TK 001: -50,000VND luc 07/01/2026 09:00. ND: GRAB',
          date: DateTime.now(),
          id: 1,
        ),
        RawSms(
          address: 'ACB',
          body: 'TK 002: -100,000VND luc 07/01/2026 10:00. ND: SHOPEE',
          date: DateTime.now(),
          id: 2,
        ),
        RawSms(
          address: 'FRIEND',
          body: 'Hello world',
          date: DateTime.now(),
          id: 3,
        ),
      ];

      final results = parser.parseMultiple(smsList);

      expect(results.length, equals(2)); // Chỉ 2 SMS hợp lệ được parse
      expect(results[0].amount, equals(50000.0));
      expect(results[1].amount, equals(100000.0));
    });

    test('Parse BIDV transaction with Vietnamese text', () {
      final rawSms = RawSms(
        address: 'BIDV',
        body: 'TK *1234 giao dich thanh toan -85.000d tai CIRCLE K vao luc 07/01/2026 16:30',
        date: DateTime.now(),
        id: 8,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(85000.0));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.bank, equals('BIDV'));
    });

    test('Correctly identify income transaction', () {
      final rawSms = RawSms(
        address: 'VCB',
        body: 'TK 001 nhan tien +500,000VND luc 07/01/2026 12:00. ND: Hoan tien',
        date: DateTime.now(),
        id: 9,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.type, equals(TransactionType.income));
      expect(parsed.amount, equals(500000.0));
    });

    test('Parse CGV entertainment transaction', () {
      final rawSms = RawSms(
        address: 'TECHCOMBANK',
        body: 'TK 190: -150,000VND tai CGV CINEMA luc 06/01/2026 19:00. So du: 800,000VND',
        date: DateTime.now(),
        id: 10,
      );

      final parsed = parser.parse(rawSms);

      expect(parsed, isNotNull);
      expect(parsed!.amount, equals(150000.0));
      expect(parsed.type, equals(TransactionType.expense));
      expect(parsed.content.toUpperCase(), contains('CGV'));
    });
  });
}
