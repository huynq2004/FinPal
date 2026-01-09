import 'package:shared_preferences/shared_preferences.dart';

/// Service quản lý cấu hình Smart Scan
/// Lưu trữ các thiết lập liên quan đến tính năng Smart Scan (quét SMS tự động)
class SmartScanConfig {
  static const String _keySmartScanEnabled = 'smart_scan_enabled';
  
  final SharedPreferences _prefs;
  
  SmartScanConfig(this._prefs);
  
  /// Factory method để khởi tạo service
  static Future<SmartScanConfig> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SmartScanConfig(prefs);
  }
  
  /// Kiểm tra xem Smart Scan có được bật không
  /// Mặc định là true (bật) khi lần đầu sử dụng
  bool get isSmartScanEnabled {
    return _prefs.getBool(_keySmartScanEnabled) ?? true;
  }
  
  /// Bật/tắt Smart Scan
  Future<void> setSmartScanEnabled(bool enabled) async {
    await _prefs.setBool(_keySmartScanEnabled, enabled);
    print('⚙️ [SmartScanConfig] Smart Scan ${enabled ? "BẬT" : "TẮT"}');
  }
  
  /// Reset về cấu hình mặc định
  Future<void> reset() async {
    await _prefs.remove(_keySmartScanEnabled);
    print('⚙️ [SmartScanConfig] Reset cấu hình về mặc định');
  }
}
