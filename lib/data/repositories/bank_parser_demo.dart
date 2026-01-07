/// Demo file showing bank-specific SMS parsing examples
/// S4-A1: Mở rộng SmsParser cho nhiều ngân hàng
///
/// This file demonstrates how different Vietnamese banks send SMS notifications
/// and how our parser handles each format.

import 'package:finpal/data/repositories/sms_parser.dart';

void main() async {
  final parser = SmsParser();

  print('=== BANK SMS PARSER DEMO ===\n');

  // 1. Vietcombank
  print('1. VIETCOMBANK');
  const vcbSms = 'TK VCB9999 -100,000 VND luc 10/01/2024 10:30:45. So du 5,000,000 VND';
  print('SMS: $vcbSms');
  var result = await parser.parse(vcbSms);
  printResult(result);

  // 2. Techcombank  
  print('\n2. TECHCOMBANK');
  const tcbSms = 'GD: +500,000VND TK9999 luc 10:30 11/01/2024 tai GRAB So du: 10,500,000VND';
  print('SMS: $tcbSms');
  result = await parser.parse(tcbSms);
  printResult(result);

  // 3. MBBank
  print('\n3. MBBANK');
  const mbSms = 'TK 9999 GD -150,000 VND tai: HIGHLANDS COFFEE. So du: 3,850,000 VND luc 09:15 12/01/2024';
  print('SMS: $mbSms');
  result = await parser.parse(mbSms);
  printResult(result);

  // 4. ACB
  print('\n4. ACB');
  const acbSms = 'ACB: TK 9999 -75,000 VND. GD thanh toan tai THE COFFEE HOUSE. SD: 2,925,000 VND. 13/01/2024 08:45';
  print('SMS: $acbSms');
  result = await parser.parse(acbSms);
  printResult(result);

  // 5. BIDV
  print('\n5. BIDV');
  const bidvSms = 'BIDV: TK 9999 -250,000VND luc 11:20 14/01/2024. ND: Thanh toan GRAB. So du: 7,750,000VND';
  print('SMS: $bidvSms');
  result = await parser.parse(bidvSms);
  printResult(result);

  // 6. Vietinbank
  print('\n6. VIETINBANK');
  const vtbSms = 'VietinBank: TK 9999 -120,000 VND tai SHOPEE vao 15/01/2024 16:30. So du: 4,880,000 VND';
  print('SMS: $vtbSms');
  result = await parser.parse(vtbSms);
  printResult(result);

  // 7. VPBank
  print('\n7. VPBANK');
  const vpbSms = 'VPBank: TK 9999 -80,000VND. Thanh toan tai CIRCLE K luc 10:15 16/01/2024. So du: 3,920,000VND';
  print('SMS: $vpbSms');
  result = await parser.parse(vpbSms);
  printResult(result);

  // 8. Generic fallback - unknown bank format
  print('\n8. GENERIC PARSER (Fallback)');
  const genericSms = 'Tai khoan cua quy khach -50,000 VND. Noi dung: Mua sam online';
  print('SMS: $genericSms');
  result = await parser.parse(genericSms);
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
    print('✓ Parsed successfully:');
    print('  - Amount: ${result.amount} VND');
    print('  - Type: ${result.transactionType}');
    print('  - Bank: ${result.bank}');
    print('  - Category: ${result.categoryName ?? "Chưa phân loại"}');
    if (result.content != null && result.content!.isNotEmpty) {
      print('  - Content: ${result.content}');
    }
  } else {
    print('✗ Failed to parse');
  }
}
