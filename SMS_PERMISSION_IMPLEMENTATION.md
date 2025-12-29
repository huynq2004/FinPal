# SMS Permission Implementation - Test Guide

## ✅ Implementation Complete

### What has been implemented:

1. **Dependencies Added** ([pubspec.yaml](pubspec.yaml))
   - `another_telephony: ^0.4.1` - For SMS permission requests
   - `shared_preferences: ^2.2.2` - For storing permission state

2. **Android Permissions** ([AndroidManifest.xml](android/app/src/main/AndroidManifest.xml))
   - `READ_SMS` - Read SMS messages
   - `RECEIVE_SMS` - Receive new SMS
   - `SEND_SMS` - Send SMS (optional, for future features)

3. **SMS Permission Screen** ([sms_permission_screen.dart](lib/ui/screens/sms_permission_screen.dart))
   - Beautiful UI with icons and instructions
   - "Cho phép FinPal đọc SMS" button
   - Permission status display
   - Debug information panel
   - Check permission status button

4. **ViewModel with State Management** ([sms_permission_viewmodel.dart](lib/ui/viewmodels/sms_permission_viewmodel.dart))
   - `requestSmsPermission()` - Request permissions from user
   - `checkPermissionStatus()` - Check current permission state
   - Auto-saves to SharedPreferences:
     - `sms_permission_requested` - Whether permission was requested
     - `sms_permission_granted` - Whether permission was granted
   - Console logging for debugging

5. **Navigation** ([settings_screen.dart](lib/ui/screens/settings_screen.dart))
   - Added "Quản lý quyền SMS" button in settings
   - Navigates to SMS permission screen

## 🧪 How to Test

### Method 1: From Settings Screen
1. Run the app: `flutter run`
2. Navigate to Settings screen (from Dashboard → Settings button)
3. Tap "Quản lý quyền SMS"
4. Tap "Cho phép FinPal đọc SMS"
5. Android permission dialog should appear
6. Grant or deny permission
7. Check the status display and debug info

### Method 2: Direct Navigation (for testing)
Add this temporary code to test directly:

```dart
// In main.dart, change home to:
home: const SmsPermissionScreen(), // Test directly
```

### Expected Results:

✅ **When "Cho phép FinPal đọc SMS" is tapped:**
- Android system permission dialog appears
- User can choose "Allow" or "Deny"

✅ **After granting permission:**
- Status shows "Quyền đã được cấp" (green)
- Success snackbar appears
- State saved to SharedPreferences

✅ **After denying permission:**
- Status shows "Quyền chưa được cấp" (orange)
- Warning snackbar appears
- State saved to SharedPreferences

✅ **Debug Info Shows:**
- "Đã yêu cầu quyền: Có/Không"
- "Trạng thái: [current status]"
- "Được cấp: Có/Không"

✅ **Console Logs:**
```
📱 SMS Permission State Loaded:
   - Has Requested: true
   - Is Granted: true
   - Status: Đã cấp quyền

📲 Requesting SMS permissions...
✅ SMS Permission Request Result:
   - Granted: true
   - Status: Đã cấp quyền
   - Saved to SharedPreferences
```

## 📱 Android Testing

### Requirements:
- Android device or emulator
- API Level 23+ (Android 6.0+) for runtime permissions

### Verification Steps:
1. **Fresh Install Test:**
   - Uninstall app completely
   - Install and run again
   - Permission should not be granted yet
   - Request permission and verify

2. **Persistence Test:**
   - Grant permission
   - Close and reopen app
   - Navigate to permission screen
   - Status should show "Đã cấp quyền"

3. **Settings Integration Test:**
   - Go to Android Settings → Apps → FinPal → Permissions
   - Manually revoke SMS permission
   - Return to app
   - Tap "Kiểm tra trạng thái quyền"
   - Should show "Chưa cấp quyền"

## 🔍 Debugging

### Check SharedPreferences:
The app stores these keys:
- `sms_permission_requested`: bool
- `sms_permission_granted`: bool

### View Device Logs:
```bash
flutter logs | grep -E "(SMS|Permission|📱|📲|✅|❌)"
```

### Common Issues:

**Issue:** Permission dialog doesn't appear
- **Solution:** Check AndroidManifest.xml has permissions
- **Solution:** Ensure app targets API 23+

**Issue:** Permission always denied
- **Solution:** Check if permission was permanently denied in Android settings
- **Solution:** Uninstall and reinstall the app

## 📝 Files Modified/Created:

- ✅ [pubspec.yaml](pubspec.yaml) - Dependencies added
- ✅ [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) - Permissions added
- ✅ [sms_permission_screen.dart](lib/ui/screens/sms_permission_screen.dart) - NEW
- ✅ [sms_permission_viewmodel.dart](lib/ui/viewmodels/sms_permission_viewmodel.dart) - NEW
- ✅ [settings_screen.dart](lib/ui/screens/settings_screen.dart) - Navigation added

## ✨ Features Implemented:

- ✅ SMS permission request with Telephony plugin
- ✅ Android permission dialog integration
- ✅ Permission state persistence (SharedPreferences)
- ✅ User-friendly Vietnamese UI
- ✅ Real-time status updates
- ✅ Console logging for debugging
- ✅ Integration with Settings screen
- ✅ Check permission status functionality

## 🎯 Success Criteria Met:

- ✅ Nút "Cho phép FinPal đọc SMS" → Android permission dialog appears
- ✅ Trạng thái quyền được lưu vào SharedPreferences
- ✅ Console logs show permission state
- ✅ UI updates based on permission status
