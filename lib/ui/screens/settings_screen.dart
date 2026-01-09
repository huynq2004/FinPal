import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'budget_management_screen.dart';
import 'category_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  static const _bg = Color(0xFFF5F7FA);
  static const _primary = Color(0xFF3E8AFF);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  // làm card hẹp hơn và nằm giữa (giống ảnh)
  static const double _maxCardWidth = 360;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            title: const Text('Cài đặt'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxCardWidth),
                child: Column(
                  children: [
                    // ===== Card: Quản lý tài chính =====
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // header: icon + title
                          Row(
                            children: const [
                              Icon(Icons.pie_chart_outline, color: _primary),
                              SizedBox(width: 10),
                              Text(
                                'Quản lý tài chính',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // divider
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE5E7EB),
                          ),

                          const SizedBox(height: 6),

                          // Menu items
                          _simpleTile(
                            title: 'Quản lý hạn mức',
                            subtitle: 'Đặt giới hạn chi tiêu cho từng danh mục',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const BudgetManagementScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                          _simpleTile(
                            title: 'Quản lý danh mục',
                            subtitle: 'Tùy chỉnh danh mục cho giao dịch',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CategoryManagementScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                          _simpleTile(
                            title: 'Tài khoản ngân hàng',
                            subtitle: 'Quản lý tài khoản ngân hàng được kết nối',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ===== Card: SMS =====
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // header: icon + title
                          Row(
                            children: const [
                              Icon(Icons.phone_iphone, color: _primary),
                              SizedBox(width: 10),
                              Text(
                                'Đọc SMS tự động',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // divider
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE5E7EB),
                          ),

                          const SizedBox(height: 15),

                          // Android SMS Toggle
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Đọc SMS tự động (Android)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Tự động quét tin nhắn ngân hàng',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: _textSecondary,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: viewModel.isSmartScanEnabled,
                                activeColor: _primary,
                                onChanged: (value) {
                                  viewModel.setSmartScanEnabled(value);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // iOS info box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              border: Border.all(color: const Color(0xFFDBEAFE)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.info_outline, color: _primary, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'iOS: ',
                                              style: TextStyle(
                                                color: _primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Không thể tự đọc SMS',
                                              style: TextStyle(
                                                color: _textPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Do giới hạn của iOS, FinPal không thể tự động đọc tin nhắn SMS. Bạn có thể sử dụng các cách thay thế sau:',
                                  style: TextStyle(color: _textSecondary, height: 1.35),
                                ),
                                const SizedBox(height: 12),
                                _altRow(
                                  icon: Icons.email_outlined,
                                  title: 'Forward email sao kê ngân hàng',
                                  subtitle: 'Gửi email thông báo giao dịch đến FinPal',
                                ),
                                const SizedBox(height: 12),
                                _altRow(
                                  icon: Icons.camera_alt_outlined,
                                  title: 'Chụp màn hình thông báo',
                                  subtitle: 'Sử dụng OCR để quét ảnh chụp màn hình',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                const SizedBox(height: 14),

                // ===== Card: Security & Privacy =====
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // header icon giống privacy
                      Row(
                        children: const [
                          Icon(Icons.shield_outlined, color: _primary),
                          SizedBox(width: 10),
                          Text(
                            'Bảo mật & Quyền riêng tư',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 6),

                      _simpleTile(
                        title: 'Quyền riêng tư dữ liệu',
                        subtitle: 'Xem cách FinPal bảo vệ dữ liệu của bạn',
                        onTap: () {},
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                      _simpleTile(
                        title: 'Mã hóa dữ liệu',
                        subtitle: 'Tất cả dữ liệu được mã hóa',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Commitment box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFEFF6FF),
                        Color(0xFFFAF5FF),
                      ],
                    ),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.verified_user_outlined, color: _primary),
                          SizedBox(width: 10),
                          Text(
                            'Cam kết bảo mật',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _bullet('Không bao giờ yêu cầu mật khẩu/OTP ngân hàng'),
                      _bullet('Chỉ đọc tin nhắn biến động số dư'),
                      _bullet('Dữ liệu được mã hóa trong hệ thống'),
                      _bullet('Không chia sẻ dữ liệu với bên thứ ba'),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Supported banks
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngân hàng được hỗ trợ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'FinPal hỗ trợ nhiều định dạng SMS ngân hàng khác nhau',
                        style: TextStyle(color: _textSecondary, fontSize: 12.5),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _BankChip('Vietcombank'),
                          _BankChip('Techcombank'),
                          _BankChip('ACB'),
                          _BankChip('VPBank'),
                          _BankChip('MB Bank'),
                          _BankChip('BIDV'),
                          _BankChip('Agribank'),
                          _BankChip('Sacombank'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Version card
                _card(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        Text(
                          'FinPal – Ví Thông Minh',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _textSecondary, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Phiên bản 1.0.0',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }


  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 3),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _simpleTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12.5, color: _textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  static Widget _altRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: _textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BankChip extends StatelessWidget {
  final String label;
  const _BankChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _bullet extends StatelessWidget {
  final String text;
  const _bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(color: _SettingsScreenState._textSecondary)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _SettingsScreenState._textSecondary, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
