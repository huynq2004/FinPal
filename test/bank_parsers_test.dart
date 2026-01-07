import 'package:flutter_test/flutter_test.dart';
import 'package:finpal/data/repositories/bank_parsers.dart';
import 'package:finpal/data/repositories/bank_parser_base.dart';

void main() {
  group('VietcombankParser', () {
    final parser = VietcombankParser();

    test('can parse Vietcombank SMS', () {
      const sms = 'TK VCB9999 -100,000 VND luc 10/01/2024 10:30:45. So du 5,000,000 VND';
      expect(parser.canParse(sms), true);
    });

    test('cannot parse non-Vietcombank SMS', () {
      const sms = 'GD: +500,000VND TK9999 luc 10:30 11/01/2024';
      expect(parser.canParse(sms), false);
    });

    test('parses debit transaction correctly', () {
      const sms = 'TK VCB9999 -100,000 VND luc 10/01/2024 10:30:45. So du 5,000,000 VND';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 100000.0);
      expect(result.transactionType, 'Chi tiền');
      expect(result.bank, 'Vietcombank');
    });

    test('parses credit transaction correctly', () {
      const sms = 'TK VCB9999 +500,000 VND luc 10/01/2024 14:20:30. So du 5,500,000 VND';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 500000.0);
      expect(result.transactionType, 'Thu tiền');
      expect(result.bank, 'Vietcombank');
    });
  });

  group('TechcombankParser', () {
    final parser = TechcombankParser();

    test('can parse Techcombank SMS', () {
      const sms = 'GD: +500,000VND TK9999 luc 10:30 11/01/2024 tai GRAB So du: 10,500,000VND';
      expect(parser.canParse(sms), true);
    });

    test('cannot parse non-Techcombank SMS', () {
      const sms = 'TK VCB9999 -100,000 VND luc 10/01/2024 10:30:45';
      expect(parser.canParse(sms), false);
    });

    test('parses credit transaction correctly', () {
      const sms = 'GD: +500,000VND TK9999 luc 10:30 11/01/2024 tai GRAB So du: 10,500,000VND';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 500000.0);
      expect(result.transactionType, 'Thu tiền');
      expect(result.bank, 'Techcombank');
      expect(result.content, contains('GRAB'));
    });

    test('parses debit transaction correctly', () {
      const sms = 'GD: -200,000VND TK9999 luc 15:45 11/01/2024 tai SHOPEE So du: 10,300,000VND';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 200000.0);
      expect(result.transactionType, 'Chi tiền');
      expect(result.bank, 'Techcombank');
      expect(result.content, contains('SHOPEE'));
    });
  });

  group('MBBankParser', () {
    final parser = MBBankParser();

    test('can parse MBBank SMS', () {
      const sms = 'TK 9999 GD -150,000 VND tai: HIGHLANDS COFFEE. So du: 3,850,000 VND luc 09:15 12/01/2024';
      expect(parser.canParse(sms), true);
    });

    test('cannot parse non-MBBank SMS', () {
      const sms = 'GD: +500,000VND TK9999 luc 10:30 11/01/2024';
      expect(parser.canParse(sms), false);
    });

    test('parses debit transaction correctly', () {
      const sms = 'TK 9999 GD -150,000 VND tai: HIGHLANDS COFFEE. So du: 3,850,000 VND luc 09:15 12/01/2024';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 150000.0);
      expect(result.transactionType, 'Chi tiền');
      expect(result.bank, 'MBBank');
      expect(result.content, contains('HIGHLANDS COFFEE'));
    });

    test('parses credit transaction correctly', () {
      const sms = 'TK 9999 GD +1,000,000 VND tai: Chuyen tien tu John. So du: 4,850,000 VND luc 14:30 12/01/2024';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 1000000.0);
      expect(result.transactionType, 'Thu tiền');
      expect(result.bank, 'MBBank');
      expect(result.content, contains('Chuyen tien tu John'));
    });
  });

  group('ACBParser', () {
    final parser = ACBParser();

    test('can parse ACB SMS', () {
      const sms = 'ACB: TK 9999 -75,000 VND. GD thanh toan tai THE COFFEE HOUSE. SD: 2,925,000 VND. 13/01/2024 08:45';
      expect(parser.canParse(sms), true);
    });

    test('parses transaction correctly', () {
      const sms = 'ACB: TK 9999 -75,000 VND. GD thanh toan tai THE COFFEE HOUSE. SD: 2,925,000 VND. 13/01/2024 08:45';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 75000.0);
      expect(result.transactionType, 'Chi tiền');
      expect(result.bank, 'ACB');
    });
  });

  group('BIDVParser', () {
    final parser = BIDVParser();

    test('can parse BIDV SMS', () {
      const sms = 'BIDV: TK 9999 -250,000VND luc 11:20 14/01/2024. ND: Thanh toan GRAB. So du: 7,750,000VND';
      expect(parser.canParse(sms), true);
    });

    test('parses transaction correctly', () {
      const sms = 'BIDV: TK 9999 -250,000VND luc 11:20 14/01/2024. ND: Thanh toan GRAB. So du: 7,750,000VND';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 250000.0);
      expect(result.transactionType, 'Chi tiền');
      expect(result.bank, 'BIDV');
    });
  });

  group('VietinbankParser', () {
    final parser = VietinbankParser();

    test('can parse Vietinbank SMS', () {
      const sms = 'VietinBank: TK 9999 -120,000 VND tai SHOPEE vao 15/01/2024 16:30. So du: 4,880,000 VND';
      expect(parser.canParse(sms), true);
    });

    test('parses transaction correctly', () {
      const sms = 'VietinBank: TK 9999 -120,000 VND tai SHOPEE vao 15/01/2024 16:30. So du: 4,880,000 VND';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 120000.0);
      expect(result.transactionType, 'Chi tiền');
      expect(result.bank, 'Vietinbank');
    });
  });

  group('VPBankParser', () {
    final parser = VPBankParser();

    test('can parse VPBank SMS', () {
      const sms = 'VPBank: TK 9999 -80,000VND. Thanh toan tai CIRCLE K luc 10:15 16/01/2024. So du: 3,920,000VND';
      expect(parser.canParse(sms), true);
    });

    test('parses transaction correctly', () {
      const sms = 'VPBank: TK 9999 -80,000VND. Thanh toan tai CIRCLE K luc 10:15 16/01/2024. So du: 3,920,000VND';
      final result = parser.parse(sms);
      
      expect(result, isNotNull);
      expect(result!.amount, 80000.0);
      expect(result.transactionType, 'Chi tiền');
      expect(result.bank, 'VPBank');
    });
  });

  group('Generic Fallback', () {
    test('parsers with same base behavior', () {
      final parsers = [
        SacombankParser(),
        HDBankParser(),
        TPBankParser(),
        SeABankParser(),
        AgribankParser(),
        SHBParser(),
        VIBParser(),
        OCBParser(),
      ];

      for (var parser in parsers) {
        expect(parser is BaseBankParser, true);
        // Each should identify their own SMS formats
        expect(parser.bankName, isNotEmpty);
        expect(parser.senderIds, isNotEmpty);
      }
    });
  });
}
