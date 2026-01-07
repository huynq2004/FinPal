/// Demo for SmartScan State Management and Error Handling
/// 
/// This file demonstrates the enhanced error handling and state management
/// features implemented in S3-A2

import 'package:flutter/material.dart';

/// Example usage of SmartScanState enum
void demonstrateStateManagement() {
  print('═══════════════════════════════════════════════');
  print('📱 DEMO: SmartScan State Management & Error Handling');
  print('═══════════════════════════════════════════════\n');

  print('🔹 AVAILABLE STATES:\n');
  
  // State 1: Idle
  print('1. idle - Trạng thái ban đầu, chưa bắt đầu quét');
  
  // State 2: Checking Permission
  print('2. checkingPermission - Đang kiểm tra quyền SMS');
  
  // State 3: Permission Denied
  print('3. permissionDenied - Người dùng từ chối quyền');
  print('   → Hiển thị thông báo yêu cầu cấp quyền');
  
  // State 4: Scanning
  print('4. scanning - Đang quét hộp thư SMS');
  print('   → Hiển thị progress indicator');
  
  // State 5: Filtering
  print('5. filtering - Đang lọc SMS ngân hàng');
  print('   → Hiển thị trạng thái đang xử lý');
  
  // State 6: Parsing
  print('6. parsing - Đang phân tích dữ liệu SMS');
  print('   → Hiển thị progress đang parse');
  
  // State 7: Success
  print('7. success - Hoàn thành thành công');
  print('   → Hiển thị kết quả và thống kê');
  print('   → Nếu có SMS không parse được → hiển thị cảnh báo');
  
  // State 8: Error
  print('8. error - Có lỗi xảy ra');
  print('   → Hiển thị thông báo lỗi chi tiết');
  print('   → App không bị crash');
  
  print('\n═══════════════════════════════════════════════\n');
  
  print('🔹 STATE FLOW - SUCCESS SCENARIO:\n');
  print('idle → checkingPermission → scanning → filtering → parsing → success');
  
  print('\n🔹 STATE FLOW - PERMISSION DENIED:\n');
  print('idle → checkingPermission → permissionDenied');
  
  print('\n🔹 STATE FLOW - ERROR SCENARIO:\n');
  print('idle → (bất kỳ state nào) → error');
  
  print('\n═══════════════════════════════════════════════\n');
}

/// Example of parse error tracking
void demonstrateErrorTracking() {
  print('🔹 ERROR TRACKING FEATURES:\n');
  
  print('1. ParseError Model:');
  print('   - Lưu trữ RawSms gốc');
  print('   - Lưu lý do lỗi cụ thể');
  print('   - Không làm crash app');
  
  print('\n2. Error Statistics:');
  print('   - totalSmsScanned: Tổng số SMS đã quét');
  print('   - successfullyParsed: Số SMS parse thành công');
  print('   - failedToParse: Số SMS không parse được');
  print('   - parseSuccessRate: Tỷ lệ thành công (%)');
  
  print('\n3. Error Logging:');
  print('   - Log chi tiết SMS không parse được');
  print('   - Hiển thị lý do lỗi');
  print('   - Giới hạn hiển thị (max 5 mẫu)');
  
  print('\n4. User-Friendly Messages:');
  print('   - "Quét thành công 45 giao dịch"');
  print('   - "Quét thành công 45 giao dịch\\n5 SMS không phân tích được"');
  print('   - "Không tìm thấy SMS ngân hàng nào"');
  print('   - "Cần cấp quyền đọc SMS để sử dụng tính năng này"');
  
  print('\n═══════════════════════════════════════════════\n');
}

/// Example of status colors
void demonstrateStatusColors() {
  print('🔹 STATUS COLORS (for UI feedback):\n');
  
  final colorMap = {
    'idle': 'Colors.grey',
    'checkingPermission': 'Colors.blue',
    'scanning': 'Colors.blue',
    'filtering': 'Colors.blue',
    'parsing': 'Colors.blue',
    'permissionDenied': 'Colors.orange',
    'success (no errors)': 'Colors.green',
    'success (with parse errors)': 'Colors.orange',
    'error': 'Colors.red',
  };
  
  colorMap.forEach((state, color) {
    print('   $state → $color');
  });
  
  print('\n═══════════════════════════════════════════════\n');
}

/// Example parse error reasons
void demonstrateErrorReasons() {
  print('🔹 COMMON PARSE ERROR REASONS:\n');
  
  final reasons = [
    '1. "Không đúng format SMS ngân hàng hoặc thiếu thông tin"',
    '   → SMS không chứa đủ thông tin cần thiết',
    '',
    '2. "Lỗi parse: Exception"',
    '   → Có lỗi exception khi parse (try-catch)',
    '',
    '3. Các lý do khác:',
    '   - Thiếu số tiền',
    '   - Thiếu thời gian giao dịch',
    '   - Format ngày tháng không hợp lệ',
    '   - Nội dung SMS quá ngắn',
  ];
  
  for (final reason in reasons) {
    print('   $reason');
  }
  
  print('\n═══════════════════════════════════════════════\n');
}

/// Example of preventing app crashes
void demonstrateCrashPrevention() {
  print('🔹 CRASH PREVENTION MECHANISMS:\n');
  
  print('1. Try-Catch trong scanInbox():');
  print('   - Bắt mọi exception từ Telephony plugin');
  print('   - Chuyển sang state.error');
  print('   - Hiển thị thông báo lỗi cho user');
  print('   - App vẫn hoạt động bình thường');
  
  print('\n2. Try-Catch trong _parseSmsList():');
  print('   - Bắt lỗi từng SMS riêng biệt');
  print('   - Thêm vào parseErrors list');
  print('   - Tiếp tục parse SMS tiếp theo');
  print('   - Không dừng toàn bộ quá trình');
  
  print('\n3. Safe Parser Return:');
  print('   - SmsParser.parse() trả về null khi không parse được');
  print('   - Không throw exception');
  print('   - ViewModel xử lý null một cách graceful');
  
  print('\n4. State Machine:');
  print('   - Luôn ở một trạng thái hợp lệ');
  print('   - Không có trạng thái "undefined"');
  print('   - UI render dựa trên state rõ ràng');
  
  print('\n5. Finally Block:');
  print('   - Luôn gọi notifyListeners()');
  print('   - UI luôn được update');
  print('   - Không bị treo');
  
  print('\n═══════════════════════════════════════════════\n');
}

/// Example integration with UI
void demonstrateUIIntegration() {
  print('🔹 UI INTEGRATION EXAMPLES:\n');
  
  print('1. Progress Indicator:');
  print('   if (viewModel.isScanning) {');
  print('     return CircularProgressIndicator();');
  print('   }');
  
  print('\n2. Status Message:');
  print('   Text(');
  print('     viewModel.getScanResultMessage(),');
  print('     style: TextStyle(color: viewModel.getStatusColor()),');
  print('   )');
  
  print('\n3. Error Display:');
  print('   if (viewModel.parseErrors.isNotEmpty) {');
  print('     showWarningDialog(');
  print('       "\${viewModel.parseErrors.length} SMS không phân tích được"');
  print('     );');
  print('   }');
  
  print('\n4. Statistics Display:');
  print('   Text("Tổng số: \${viewModel.totalSmsScanned}");');
  print('   Text("Thành công: \${viewModel.successfullyParsed}");');
  print('   Text("Thất bại: \${viewModel.failedToParse}");');
  print('   Text("Tỷ lệ: \${viewModel.parseSuccessRate.toStringAsFixed(1)}%");');
  
  print('\n5. State-Based Rendering:');
  print('   switch (viewModel.state) {');
  print('     case SmartScanState.idle:');
  print('       return IdleView();');
  print('     case SmartScanState.scanning:');
  print('       return ScanningView();');
  print('     case SmartScanState.success:');
  print('       return ResultsView();');
  print('     case SmartScanState.error:');
  print('       return ErrorView();');
  print('     // ...other states');
  print('   }');
  
  print('\n═══════════════════════════════════════════════\n');
}

void main() {
  demonstrateStateManagement();
  demonstrateErrorTracking();
  demonstrateStatusColors();
  demonstrateErrorReasons();
  demonstrateCrashPrevention();
  demonstrateUIIntegration();
  
  print('✅ Demo completed!');
  print('═══════════════════════════════════════════════\n');
}
