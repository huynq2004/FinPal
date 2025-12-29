import 'package:flutter/material.dart';
import 'sms_permission_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSms = true; // local state tạm

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          // Section 1
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Đọc SMS tự động',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Đọc SMS tự động (Android)'),
            subtitle: const Text(
              'Ứng dụng sẽ quét SMS biến động số dư để tự động ghi nhận giao dịch.',
            ),
            value: _autoSms,
            onChanged: (v) => setState(() => _autoSms = v),
          ),
          
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Quản lý quyền SMS'),
            subtitle: const Text('Cấp hoặc kiểm tra quyền đọc SMS'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SmsPermissionScreen(),
                ),
              );
            },
          ),

          const Divider(height: 24),

          // Section 2
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Bảo mật & Quyền riêng tư',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'FinPal chỉ đọc nội dung SMS liên quan đến giao dịch ngân hàng để tự động ghi nhận chi tiêu.\n'
              '• Không đọc và không lưu OTP.\n'
              '• Không yêu cầu mật khẩu hoặc thông tin đăng nhập ngân hàng.\n'
              '• Dữ liệu chỉ lưu trên thiết bị của bạn.',
              style: TextStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
