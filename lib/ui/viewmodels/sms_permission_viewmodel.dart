import 'package:flutter/foundation.dart';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsPermissionViewModel extends ChangeNotifier {
  final Telephony telephony = Telephony.instance;
  
  bool _isLoading = false;
  bool _hasRequestedPermission = false;
  bool _isPermissionGranted = false;
  String? _permissionStatus;

  bool get isLoading => _isLoading;
  bool get hasRequestedPermission => _hasRequestedPermission;
  bool get isPermissionGranted => _isPermissionGranted;
  String? get permissionStatus => _permissionStatus;

  // SharedPreferences keys
  static const String _keyHasRequestedPermission = 'sms_permission_requested';
  static const String _keyIsPermissionGranted = 'sms_permission_granted';

  SmsPermissionViewModel() {
    _loadPermissionState();
  }

  /// Load permission state from SharedPreferences
  Future<void> _loadPermissionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasRequestedPermission = prefs.getBool(_keyHasRequestedPermission) ?? false;
      
      // Check REAL permission status from system, not just SharedPreferences
      PermissionStatus realStatus = await Permission.sms.status;
      _isPermissionGranted = realStatus.isGranted;
      _permissionStatus = _isPermissionGranted ? 'Đã cấp quyền' : 'Chưa cấp quyền';
      
      // Update SharedPreferences with real status
      await prefs.setBool(_keyIsPermissionGranted, _isPermissionGranted);
      
      notifyListeners();
      
      if (kDebugMode) {
        print('📱 SMS Permission State Loaded:');
        print('   - Has Requested: $_hasRequestedPermission');
        print('   - Real System Status: $realStatus');
        print('   - Is Granted: $_isPermissionGranted');
        print('   - Status: $_permissionStatus');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading permission state: $e');
      }
    }
  }

  /// Save permission state to SharedPreferences
  Future<void> _savePermissionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasRequestedPermission, _hasRequestedPermission);
      await prefs.setBool(_keyIsPermissionGranted, _isPermissionGranted);
      
      if (kDebugMode) {
        print('💾 SMS Permission State Saved:');
        print('   - Has Requested: $_hasRequestedPermission');
        print('   - Is Granted: $_isPermissionGranted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving permission state: $e');
      }
    }
  }

  /// Check current SMS permission status (without requesting)
  Future<void> checkPermissionStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

       // Check REAL permission status from system, don't trigger dialog
      PermissionStatus realStatus = await Permission.sms.status;
      _isPermissionGranted = realStatus.isGranted;
      _permissionStatus = _isPermissionGranted ? 'Đã cấp quyền' : 'Chưa cấp quyền';

      // Optionally keep SharedPreferences in sync with real status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsPermissionGranted, _isPermissionGranted);

      if (kDebugMode) {
        print('🔍 Permission Status Check:');
        print('   - Real System Status: $realStatus');
        print('   - Granted: $_isPermissionGranted');
        print('   - Status: $_permissionStatus');
      }
    } catch (e) {
      _permissionStatus = 'Lỗi kiểm tra quyền';
      if (kDebugMode) {
        print('❌ Error checking permission status: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request SMS permissions from the user
  Future<void> requestSmsPermission() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (kDebugMode) {
        print('📲 Requesting SMS permissions from system...');
      }

      // Check current status first
      PermissionStatus currentStatus = await Permission.sms.status;
      
      // If permanently denied, need to open settings
      if (currentStatus.isPermanentlyDenied) {
        _permissionStatus = 'Bị từ chối vĩnh viễn - Đang mở Cài đặt...';
        notifyListeners();
        
        if (kDebugMode) {
          print('⚠️ Permission permanently denied - Opening settings');
        }
        
        // Open app settings so user can enable permission manually
        await openAppSettings();
        
        _permissionStatus = 'Vui lòng bật quyền SMS trong Cài đặt';
        _isPermissionGranted = false;
        await _savePermissionState();
        return;
      }

      // Request permission (shows Android dialog)
      final PermissionStatus status = await Permission.sms.request();

      _hasRequestedPermission = true;
      _isPermissionGranted = status.isGranted;
      
      if (status.isPermanentlyDenied) {
        _permissionStatus = 'Bị từ chối vĩnh viễn - Vui lòng vào Cài đặt';
      } else {
        _permissionStatus = _isPermissionGranted 
            ? 'Đã cấp quyền' 
            : 'Người dùng từ chối';
      }

      // Save the REAL result to SharedPreferences
      await _savePermissionState();

      if (kDebugMode) {
        print('✅ SMS Permission Request Result:');
        print('   - Status: $status');
        print('   - Granted: $_isPermissionGranted');
        print('   - Permission Status: $_permissionStatus');
        print('   - Saved to SharedPreferences');
      }
    } catch (e) {
      _permissionStatus = 'Lỗi yêu cầu quyền';
      if (kDebugMode) {
        print('❌ Error requesting SMS permission: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset permission state (useful for testing)
  Future<void> resetPermissionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHasRequestedPermission);
      await prefs.remove(_keyIsPermissionGranted);
      
      _hasRequestedPermission = false;
      _isPermissionGranted = false;
      _permissionStatus = null;
      
      notifyListeners();
      
      if (kDebugMode) {
        print('🔄 Permission state reset');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resetting permission state: $e');
      }
    }
  }
}
