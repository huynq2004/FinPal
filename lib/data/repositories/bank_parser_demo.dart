/// Demo file showing bank-specific SMS parsing examples
/// S4-A1: Mở rộng SmsParser cho nhiều ngân hàng
///
/// This file demonstrates how different Vietnamese banks send SMS notifications
/// and how our parser handles each format.

import '../../domain/models/raw_sms.dart';
import 'bank_parsers.dart';

void main() {
  print('=== BANK SMS PARSER DEMO ===\n');

  // 1. Vietcombank
  print('1. VIETCOMBANK');
  const vcbSms = 'TK VCB9999 -100,000 VND luc 10/01/2024 10:30:45. So du 5,000,000 VND';
  print('SMS: $vcbSms');
  final vcbRaw = RawSms(
    address: 'VCB',
    body: vcbSms,
    date: DateTime.now(),
    id: 1,
  );
  final vcbParser = VietcombankParser();
  var result = vcbParser.parse(vcbRaw);
  printResult(result);

  // 2. Techcombank  
  print('\n2. TECHCOMBANK');
  const tcbSms = 'GD: -500,000VND TK9999 luc 10:30 11/01/2024 tai GRAB So du: 10,500,000VND';
  print('SMS: $tcbSms');
  final tcbRaw = RawSms(
    address: 'TECHCOMBANK',
    body: tcbSms,
    date: DateTime.now(),
    id: 2,
  );
  final tcbParser = TechcombankParser();
  result = tcbParser.parse(tcbRaw);
  printResult(result);

  // 3. MBBank
  print('\n3. MBBANK');
  const mbSms = 'TK 9999 GD -150,000 VND tai: HIGHLANDS COFFEE. So du: 3,850,000 VND luc 09:15 12/01/2024';
  print('SMS: $mbSms');
  final mbRaw = RawSms(
    address: 'MBBANK',
    body: mbSms,
    date: DateTime.now(),
    id: 3,
  );
  final mbParser = MBBankParser();
  result = mbParser.parse(mbRaw);
  printResult(result);

  // 4. ACB
  print('\n4. ACB');
  const acbSms = 'ACB: TK 9999 -75,000 VND. GD thanh toan tai THE COFFEE HOUSE. SD: 2,925,000 VND. 13/01/2024 08:45';
  print('SMS: $acbSms');
  final acbRaw = RawSms(
    address: 'ACB',
    body: acbSms,
    date: DateTime.now(),
    id: 4,
  );
  final acbParser = ACBParser();
  result = acbParser.parse(acbRaw);
  printResult(result);

  // 5. BIDV
  print('\n5. BIDV');
  const bidvSms = 'BIDV: TK 9999 -250,000VND luc 11:20 14/01/2024. ND: Thanh toan GRAB. So du: 7,750,000VND';
  print('SMS: $bidvSms');
  final bidvRaw = RawSms(
    address: 'BIDV',
    body: bidvSms,
    date: DateTime.now(),
    id: 5,
  );
  final bidvParser = BIDVParser();
  result = bidvParser.parse(bidvRaw);
  printResult(result);

  // 6. Vietinbank
  print('\n6. VIETINBANK');
  const vtbSms = 'VietinBank: TK 9999 -120,000 VND tai SHOPEE vao 15/01/2024 16:30. So du: 4,880,000 VND';
  print('SMS: $vtbSms');
  final vtbRaw = RawSms(
    address: 'VIETINBANK',
    body: vtbSms,
    date: DateTime.now(),
    id: 6,
  );
  final vtbParser = VietinbankParser();
  result = vtbParser.parse(vtbRaw);
  printResult(result);

  // 7. VPBank
  print('\n7. VPBANK');
  const vpbSms = 'VPBank: TK 9999 -80,000VND. Thanh toan tai CIRCLE K luc 10:15 16/01/2024. So du: 3,920,000VND';
  print('SMS: $vpbSms');
  final vpbRaw = RawSms(
    address: 'VPBANK',
    body: vpbSms,
    date: DateTime.now(),
    id: 7,
  );
  final vpbParser = VPBankParser();
  result = vpbParser.parse(vpbRaw);
  printResult(result);

  // 8. Generic fallback - unknown bank format
  print('\n8. GENERIC PARSER (Fallback)');
  const genericSms = 'Tai khoan cua quy khach -50,000 VND. Noi dung: Mua sam online';
  print('SMS: $genericSms');
  final genericRaw = RawSms(
    address: 'UNKNOWN',
    body: genericSms,
    date: DateTime.now(),
    id: 8,
  );
  final genericParser = VietcombankParser();
  result = genericParser.parse(genericRaw);
  printResult(result);

  print('\n=== DEMO COMPLETED ===');
  print('\nKey Features:');
  print('✓ Bank-specific parsers for 15 Vietnamese banks');
  print('✓ Automatic bank detection via sender ID matching');
  print('✓ Fallback to generic parser for unknown formats');
  print('✓ Auto-categorization using CategoryEngine');
  print('✓ Proper handling of Vietnamese number formats (100,000 VND)');
}

void printResult(result) {
  if (result != null) {
    print('✅ Parsed successfully:');
    print('   Amount: ${result.amount.toStringAsFixed(0)} VND');
    print('   Type: ${result.type}');
    print('   Bank: ${result.bank}');
    print('   Content: ${result.content}');
    print('   DateTime: ${result.dateTime}');
  } else {
    print('❌ Failed to parse');
  }
}
