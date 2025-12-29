import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sms_permission_viewmodel.dart';

class SmsPermissionScreen extends StatelessWidget {
  const SmsPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SmsPermissionViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quyền đọc SMS'),
          backgroundColor: Colors.teal,
        ),
        body: Consumer<SmsPermissionViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.sms,
                    size: 100,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'FinPal cần quyền đọc SMS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Để tự động quét và thêm giao dịch từ tin nhắn ngân hàng, '
                    'FinPal cần quyền đọc SMS của bạn.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Status display
                  if (viewModel.permissionStatus != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: viewModel.isPermissionGranted 
                            ? Colors.green.shade50 
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: viewModel.isPermissionGranted 
                              ? Colors.green 
                              : Colors.orange,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            viewModel.isPermissionGranted 
                                ? Icons.check_circle 
                                : Icons.warning,
                            color: viewModel.isPermissionGranted 
                                ? Colors.green 
                                : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              viewModel.isPermissionGranted
                                  ? 'Quyền đã được cấp'
                                  : 'Quyền chưa được cấp',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: viewModel.isPermissionGranted 
                                    ? Colors.green.shade900 
                                    : Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Request permission button
                  ElevatedButton(
                    onPressed: viewModel.isLoading 
                        ? null 
                        : () async {
                            await viewModel.requestSmsPermission();
                            if (context.mounted && viewModel.isPermissionGranted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cấp quyền thành công!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else if (context.mounted && !viewModel.isPermissionGranted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Quyền bị từ chối. Vui lòng cấp quyền trong cài đặt.'),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
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
                        : const Text('Cho phép FinPal đọc SMS'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Check permission status button
                  OutlinedButton(
                    onPressed: viewModel.isLoading 
                        ? null 
                        : () async {
                            await viewModel.checkPermissionStatus();
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.teal),
                    ),
                    child: const Text('Kiểm tra trạng thái quyền'),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Debug info
                  if (viewModel.hasRequestedPermission)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin debug:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đã yêu cầu quyền: ${viewModel.hasRequestedPermission ? "Có" : "Không"}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Trạng thái: ${viewModel.permissionStatus ?? "Chưa kiểm tra"}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Được cấp: ${viewModel.isPermissionGranted ? "Có" : "Không"}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
