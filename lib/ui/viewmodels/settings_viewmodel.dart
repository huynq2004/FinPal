import 'package:flutter/material.dart';
import '../../data/repositories/smart_scan_config.dart';

/// ViewModel cho màn hình Settings
/// Quản lý các thiết lập ứng dụng, đặc biệt là Smart Scan
class SettingsViewModel extends ChangeNotifier {
  final SmartScanConfig _config;
  
  bool _isSmartScanEnabled = true;
  
  SettingsViewModel(this._config) {
    _loadSettings();
  }
  
  /// Getter cho trạng thái Smart Scan
  bool get isSmartScanEnabled => _isSmartScanEnabled;
  
  /// Load settings từ SharedPreferences
  Future<void> _loadSettings() async {
    _isSmartScanEnabled = _config.isSmartScanEnabled;
    notifyListeners();
  }
  
  /// Bật/tắt Smart Scan
  Future<void> setSmartScanEnabled(bool enabled) async {
    _isSmartScanEnabled = enabled;
    notifyListeners();
    
    await _config.setSmartScanEnabled(enabled);
    
    if (enabled) {
      print('✅ [Settings] Smart Scan đã được BẬT');
    } else {
      print('❌ [Settings] Smart Scan đã được TẮT');
    }
  }
  
  /// Reset tất cả settings
  Future<void> resetSettings() async {
    await _config.reset();
    await _loadSettings();
    print('🔄 [Settings] Đã reset tất cả cài đặt');
  }
}
