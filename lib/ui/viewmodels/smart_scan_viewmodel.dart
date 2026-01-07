import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/models/raw_sms.dart';

/// ViewModel cho màn hình Smart Scan
/// Quản lý việc đọc và lọc SMS ngân hàng
class SmartScanViewModel extends ChangeNotifier {
  final Telephony _telephony = Telephony.instance;
  
  // State
  bool _isScanning = false;
  bool _hasPermission = false;
  List<RawSms> _rawSmsList = [];
  String? _errorMessage;
  
  // Getters
  bool get isScanning => _isScanning;
  bool get hasPermission => _hasPermission;
  List<RawSms> get rawSmsList => _rawSmsList;
  String? get errorMessage => _errorMessage;
  
  // Danh sách số điện thoại/tên ngân hàng cần lọc
  static const List<String> _bankAddresses = [
    'VCB',
    'TECHCOMBANK',
    'ACB',
    'BIDV',
    'Vietinbank',
    'VPBank',
    'MBBank',
    'Sacombank',
    'HDBank',
    'OCB',
    'TPBank',
    'SeABank',
    'Agribank',
    'SHB',
    'VIB',
    'LienVietPostBank',
    'BacABank',
    'PVcomBank',
    'NCB',
    'MSB',
  ];
  
  // Từ khóa cần tìm trong nội dung SMS
  static const List<String> _bankKeywords = [
    'TK',
    'so du',
    'VND',
    'bien dong',
    'giao dich',
    'rut tien',
    'nap tien',
    'chuyen khoan',
    'thanh toan',
  ];

  /// Hàm chính: Quét hộp thư SMS và lọc tin nhắn ngân hàng
  Future<void> scanInbox() async {
    try {
      _isScanning = true;
      _errorMessage = null;
      notifyListeners();
      
      print('🔍 [SmartScan] Bắt đầu quét SMS...');
      
      // Bước 1: Kiểm tra quyền SMS
      final hasPermission = await _checkSmsPermission();
      if (!hasPermission) {
        _errorMessage = 'Không có quyền đọc SMS. Vui lòng cấp quyền trong Cài đặt.';
        print('❌ [SmartScan] Không có quyền SMS');
        _isScanning = false;
        notifyListeners();
        return;
      }
      
      print('✅ [SmartScan] Đã có quyền SMS');
      
      // Bước 2: Đọc tất cả SMS từ inbox
      final messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE, SmsColumn.ID],
      );
      
      print('📨 [SmartScan] Tổng số SMS đọc được: ${messages.length}');
      
      // Bước 3: Lọc SMS ngân hàng
      final filteredMessages = _filterBankSms(messages);
      
      print('🏦 [SmartScan] Số SMS ngân hàng sau khi lọc: ${filteredMessages.length}');
      
      // Bước 4: Chuyển đổi sang RawSms và lưu vào state
      _rawSmsList = filteredMessages.map((sms) => RawSms(
        address: sms.address ?? '',
        body: sms.body ?? '',
        date: DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0),
        id: sms.id ?? 0,
      )).toList();
      
      // Sắp xếp theo thời gian giảm dần (mới nhất trước)
      _rawSmsList.sort((a, b) => b.date.compareTo(a.date));
      
      print('✅ [SmartScan] Hoàn thành quét SMS');
      _logSampleMessages();
      
    } catch (e) {
      _errorMessage = 'Lỗi khi quét SMS: $e';
      print('❌ [SmartScan] Lỗi: $e');
      _rawSmsList = [];
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
  
  /// Kiểm tra quyền đọc SMS
  Future<bool> _checkSmsPermission() async {
    try {
      // Kiểm tra quyền hiện tại
      final status = await Permission.sms.status;
      
      if (status.isGranted) {
        _hasPermission = true;
        return true;
      }
      
      // Nếu chưa có quyền, yêu cầu quyền
      final result = await Permission.sms.request();
      _hasPermission = result.isGranted;
      
      return _hasPermission;
    } catch (e) {
      print('❌ [SmartScan] Lỗi khi kiểm tra quyền: $e');
      _hasPermission = false;
      return false;
    }
  }
  
  /// Lọc các tin nhắn ngân hàng từ danh sách SMS
  List<dynamic> _filterBankSms(List<dynamic> messages) {
    if (messages.isEmpty) {
      print('⚠️ [SmartScan] Hộp thư SMS rỗng');
      return [];
    }
    
    return messages.where((sms) {
      final address = (sms.address ?? '').toUpperCase();
      final body = (sms.body ?? '').toLowerCase();
      
      // Điều kiện 1: address thuộc danh sách ngân hàng
      final isFromBank = _bankAddresses.any((bank) => 
        address.contains(bank.toUpperCase())
      );
      
      // Điều kiện 2: body chứa từ khóa ngân hàng
      final hasKeyword = _bankKeywords.any((keyword) => 
        body.contains(keyword.toLowerCase())
      );
      
      // Thỏa mãn một trong hai điều kiện
      return isFromBank || hasKeyword;
    }).toList();
  }
  
  /// Log một vài tin nhắn mẫu để kiểm tra
  void _logSampleMessages() {
    if (_rawSmsList.isEmpty) {
      print('⚠️ [SmartScan] Không có SMS nào để hiển thị');
      return;
    }
    
    print('\n📋 [SmartScan] Mẫu tin nhắn (tối đa 3):');
    final sampleCount = _rawSmsList.length > 3 ? 3 : _rawSmsList.length;
    
    for (int i = 0; i < sampleCount; i++) {
      final sms = _rawSmsList[i];
      print('   ${i + 1}. From: ${sms.address}');
      print('      Date: ${sms.date}');
      print('      Body: ${sms.body.substring(0, sms.body.length > 80 ? 80 : sms.body.length)}...');
      print('');
    }
  }
  
  /// Reset state
  void reset() {
    _rawSmsList = [];
    _errorMessage = null;
    _isScanning = false;
    notifyListeners();
  }
}
