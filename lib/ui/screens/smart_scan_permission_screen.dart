import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sms_permission_viewmodel.dart';

class SmartScanPermissionScreen extends StatelessWidget {
  final VoidCallback? onNavigateToDashboard;
  
  const SmartScanPermissionScreen({super.key, this.onNavigateToDashboard});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SmsPermissionViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Consumer<SmsPermissionViewModel>(
          builder: (context, viewModel, child) {
            return SafeArea(
              child: Column(
                children: [
                  // Main scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Blue gradient header
                          _buildHeader(),
                          
                          const SizedBox(height: 24),
                          
                          // Security features card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                _buildSecurityFeaturesCard(),
                                const SizedBox(height: 16),
                                _buildInfoCard(),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 100), // Space for bottom buttons
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom buttons
                  _buildBottomButtons(context, viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          // Shield icon
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 33,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Title
          const Text(
            'Cho phép FinPal đọc SMS ngân hàng',
            style: TextStyle(
              fontSize: 16.5,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Column(
            children: [
              Text(
                'Chỉ đọc tin nhắn biến động số dư.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Không đọc OTP, không đọc tin nhắn cá nhân.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeaturesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFeatureItem(
            icon: Icons.lock_outline,
            text: 'Không bao giờ yêu cầu mật khẩu/OTP ngân hàng',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.visibility_outlined,
            text: 'Chỉ đọc nội dung SMS giao dịch',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.shield_outlined,
            text: 'Dữ liệu được mã hóa trong hệ thống',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF3E8AFF),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16.5,
                color: Color(0xFF0F172A),
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDBEAFE),
          width: 0.7,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'FinPal chỉ hoạt động trên thiết bị của bạn. Dữ liệu giao dịch không được chia sẻ với bên thứ ba.',
              style: TextStyle(
                fontSize: 14.5,
                color: const Color(0xFF0F172A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, SmsPermissionViewModel viewModel) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFF3F4F6),
            width: 0.7,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Allow button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      await viewModel.requestSmsPermission();
                      if (context.mounted && viewModel.isPermissionGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Đã cấp quyền thành công!'),
                            backgroundColor: Color(0xFF10B981),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // Call callback to refresh parent state
                        onNavigateToDashboard?.call();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E8AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Cho phép',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Later button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                      // Navigate back to Dashboard
                      onNavigateToDashboard?.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bạn có thể cấp quyền sau trong Cài đặt'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: const Color(0xFF64748B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Để sau',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
