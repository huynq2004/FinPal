import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/models/raw_sms.dart';
import '../../domain/models/parsed_sms.dart';
import '../../data/repositories/sms_parser.dart';
import '../../data/repositories/smart_scan_config.dart';

/// Enum state cho quá trình Smart Scan
enum SmartScanState {
  idle,              // Chưa bắt đầu quét
  disabled,          // Smart Scan đang bị tắt
  checkingPermission, // Đang kiểm tra quyền SMS
  permissionDenied,   // Người dùng từ chối quyền
  scanning,           // Đang quét SMS từ inbox
  filtering,          // Đang lọc SMS ngân hàng
  parsing,            // Đang parse SMS
  success,            // Hoàn thành thành công
  error,              // Có lỗi xảy ra
}

/// Model cho thông tin lỗi parse
class ParseError {
  final RawSms rawSms;
  final String reason;
  
  ParseError({required this.rawSms, required this.reason});
}

/// ViewModel cho màn hình Smart Scan
/// Quản lý việc đọc và lọc SMS ngân hàng với error handling
class SmartScanViewModel extends ChangeNotifier {
  final Telephony _telephony = Telephony.instance;
  final SmsParser _parser = SmsParser();
  final SmartScanConfig _config;
  
  SmartScanViewModel(this._config);
  
  // State
  SmartScanState _state = SmartScanState.idle;
  bool _hasPermission = false;
  List<RawSms> _rawSmsList = [];
  List<ParsedSms> _parsedSmsList = [];
  List<ParseError> _parseErrors = [];
  String? _errorMessage;
  
  // Getters
  SmartScanState get state => _state;
  bool get isScanning => _state == SmartScanState.scanning || 
                         _state == SmartScanState.filtering || 
                         _state == SmartScanState.parsing;
  bool get isDisabled => _state == SmartScanState.disabled;
  bool get hasPermission => _hasPermission;
  List<RawSms> get rawSmsList => _rawSmsList;
  List<ParsedSms> get parsedSmsList => _parsedSmsList;
  List<ParseError> get parseErrors => _parseErrors;
  String? get errorMessage => _errorMessage;
  
  /// Thống kê
  int get totalSmsScanned => _rawSmsList.length;
  int get successfullyParsed => _parsedSmsList.length;
  int get failedToParse => _parseErrors.length;
  double get parseSuccessRate => _rawSmsList.isEmpty 
      ? 0.0 
      : (_parsedSmsList.length / _rawSmsList.length * 100);
  
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
      // Bước 0: Kiểm tra xem Smart Scan có được bật không
      if (!_config.isSmartScanEnabled) {
        _state = SmartScanState.disabled;
        _errorMessage = 'Smart Scan đang tắt. Vui lòng bật trong Cài đặt.';
        print('⚠️ [SmartScan] Smart Scan đang tắt - không thể quét');
        notifyListeners();
        return;
      }
      
      _state = SmartScanState.checkingPermission;
      _errorMessage = null;
      _parseErrors.clear();
      notifyListeners();
      
      print('🔍 [SmartScan] Bắt đầu quét SMS...');
      
      // Bước 1: Kiểm tra quyền SMS
      _state = SmartScanState.checkingPermission;
      notifyListeners();
      
      final hasPermission = await _checkSmsPermission();
      if (!hasPermission) {
        _state = SmartScanState.permissionDenied;
        _errorMessage = 'Không có quyền đọc SMS. Vui lòng cấp quyền trong Cài đặt.';
        print('❌ [SmartScan] Không có quyền SMS');
        notifyListeners();
        return;
      }
      
      print('✅ [SmartScan] Đã có quyền SMS');
      
      // Bước 2: Đọc tất cả SMS từ inbox
      _state = SmartScanState.scanning;
      notifyListeners();
      
      final messages = await _telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE, SmsColumn.ID],
      );
      
      print('📨 [SmartScan] Tổng số SMS đọc được: ${messages.length}');
      
      // Bước 3: Lọc SMS ngân hàng
      _state = SmartScanState.filtering;
      notifyListeners();
      
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
      
      // Bước 5: Parse SMS sang ParsedSms với error tracking
      _state = SmartScanState.parsing;
      notifyListeners();
      
      print('\n🔄 [SmartScan] Bắt đầu parse SMS...');
      _parseSmsList();
      
      print('✅ [SmartScan] Parse hoàn tất: ${_parsedSmsList.length} SMS thành công');
      _logParsedSamples();
      
      // Hoàn thành thành công
      _state = SmartScanState.success;
      
      // Thông báo nếu có SMS không parse được
      if (_parseErrors.isNotEmpty) {
        print('⚠️ [SmartScan] Có ${_parseErrors.length} SMS không parse được');
        _logParseErrors();
      }
      
    } catch (e, stackTrace) {
      _state = SmartScanState.error;
      _errorMessage = 'Lỗi khi quét SMS: $e';
      print('❌ [SmartScan] Lỗi: $e');
      print('Stack trace: $stackTrace');
      _rawSmsList = [];
      _parsedSmsList = [];
    } finally {
      notifyListeners();
    }
  }
  
  /// Parse danh sách SMS và track errors
  void _parseSmsList() {
    _parsedSmsList.clear();
    _parseErrors.clear();
    
    for (final rawSms in _rawSmsList) {
      try {
        final parsed = _parser.parse(rawSms);
        
        if (parsed != null) {
          _parsedSmsList.add(parsed);
        } else {
          // SMS không parse được (không đúng format ngân hàng)
          _parseErrors.add(ParseError(
            rawSms: rawSms,
            reason: 'Không đúng format SMS ngân hàng hoặc thiếu thông tin',
          ));
        }
      } catch (e) {
        // Lỗi exception khi parse
        _parseErrors.add(ParseError(
          rawSms: rawSms,
          reason: 'Lỗi parse: $e',
        ));
        print('❌ [SmartScan] Lỗi parse SMS ID ${rawSms.id}: $e');
      }
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
    
    print('\n📋 [SmartScan] Mẫu tin nhắn RAW (tối đa 3):');
    final sampleCount = _rawSmsList.length > 3 ? 3 : _rawSmsList.length;
    
    for (int i = 0; i < sampleCount; i++) {
      final sms = _rawSmsList[i];
      print('   ${i + 1}. From: ${sms.address}');
      print('      Date: ${sms.date}');
      print('      Body: ${sms.body.substring(0, sms.body.length > 80 ? 80 : sms.body.length)}...');
      print('');
    }
  }
  
  /// Log các SMS đã parse thành công
  void _logParsedSamples() {
    if (_parsedSmsList.isEmpty) {
      print('⚠️ [SmartScan] Không có SMS nào được parse thành công');
      return;
    }
    
    print('\n📊 [SmartScan] Mẫu SMS đã parse (tối đa 5):');
    final sampleCount = _parsedSmsList.length > 5 ? 5 : _parsedSmsList.length;
    
    for (int i = 0; i < sampleCount; i++) {
      final parsed = _parsedSmsList[i];
      final typeIcon = parsed.type == TransactionType.income ? '📈' : '📉';
      print('   ${i + 1}. $typeIcon ${parsed.bank}: ${parsed.amount.toStringAsFixed(0)} VND');
      print('      Content: ${parsed.content}');
      print('      Date: ${parsed.dateTime}');
      print('');
    }
    
    // Thống kê
    final successRate = parseSuccessRate.toStringAsFixed(1);
    print('📊 [SmartScan] Tỷ lệ parse thành công: $successRate% (${_parsedSmsList.length}/${_rawSmsList.length})');
  }
  
  /// Log các SMS không parse được
  void _logParseErrors() {
    if (_parseErrors.isEmpty) return;
    
    print('\n⚠️ [SmartScan] Danh sách SMS không parse được:');
    final sampleCount = _parseErrors.length > 5 ? 5 : _parseErrors.length;
    
    for (int i = 0; i < sampleCount; i++) {
      final error = _parseErrors[i];
      print('   ${i + 1}. From: ${error.rawSms.address}');
      print('      Date: ${error.rawSms.date}');
      print('      Reason: ${error.reason}');
      print('      Body: ${error.rawSms.body.substring(0, error.rawSms.body.length > 60 ? 60 : error.rawSms.body.length)}...');
      print('');
    }
    
    if (_parseErrors.length > 5) {
      print('   ... và ${_parseErrors.length - 5} SMS khác');
    }
  }
  
  /// Lấy thông báo user-friendly về kết quả scan
  String getScanResultMessage() {
    switch (_state) {
      case SmartScanState.idle:
        return 'Nhấn nút quét để bắt đầu';
      case SmartScanState.disabled:
        return 'Smart Scan đang tắt. Vui lòng bật trong Cài đặt.';
      case SmartScanState.checkingPermission:
        return 'Đang kiểm tra quyền truy cập SMS...';
      case SmartScanState.permissionDenied:
        return 'Cần cấp quyền đọc SMS để sử dụng tính năng này';
      case SmartScanState.scanning:
        return 'Đang quét hộp thư SMS...';
      case SmartScanState.filtering:
        return 'Đang lọc SMS ngân hàng...';
      case SmartScanState.parsing:
        return 'Đang phân tích dữ liệu...';
      case SmartScanState.success:
        if (_parsedSmsList.isEmpty) {
          return 'Không tìm thấy SMS ngân hàng nào';
        } else if (_parseErrors.isEmpty) {
          return 'Quét thành công ${_parsedSmsList.length} giao dịch';
        } else {
          return 'Quét thành công ${_parsedSmsList.length} giao dịch\n'
                 '${_parseErrors.length} SMS không phân tích được';
        }
      case SmartScanState.error:
        return _errorMessage ?? 'Có lỗi xảy ra';
    }
  }
  
  /// Lấy màu cho status message
  Color getStatusColor() {
    switch (_state) {
      case SmartScanState.idle:
        return Colors.grey;
      case SmartScanState.disabled:
        return Colors.grey;
      case SmartScanState.checkingPermission:
      case SmartScanState.scanning:
      case SmartScanState.filtering:
      case SmartScanState.parsing:
        return Colors.blue;
      case SmartScanState.permissionDenied:
        return Colors.orange;
      case SmartScanState.success:
        return _parseErrors.isEmpty ? Colors.green : Colors.orange;
      case SmartScanState.error:
        return Colors.red;
    }
  }
  
  /// Reset state
  void reset() {
    _state = SmartScanState.idle;
    _rawSmsList = [];
    _parsedSmsList = [];
    _parseErrors = [];
    _errorMessage = null;
    notifyListeners();
  }
}
