import 'package:flutter/material.dart';
import 'smart_scan_results_screen.dart';

class SmartScanScreen extends StatefulWidget {
  const SmartScanScreen({super.key});

  @override
  State<SmartScanScreen> createState() => _SmartScanScreenState();
}

class _SmartScanScreenState extends State<SmartScanScreen> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Smart Scan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // Scanning Animation Section
                    _buildScanningSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Transaction List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildTransactionList(),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Results Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SmartScanResultsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E8AFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Xem kết quả (Demo)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Scanning Animation Circle
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3E8AFF).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated outer ring
              if (_isScanning)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 6.28,
                      child: child,
                    );
                  },
                  onEnd: () {
                    if (_isScanning) {
                      setState(() {
                        _isScanning = _isScanning;
                      });
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 3,
                      ),
                    ),
                  ),
                ),
              
              // Center loading circle
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Status Text
        Text(
          'Đang quét tin nhắn ngân hàng...',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Detected transactions count
        Text(
          'Đã phát hiện 12 giao dịch',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Column(
      children: [
        _buildTransactionCard(
          bankName: 'Vietcombank',
          amount: '-55.000 VND',
          details: 'Bien dong so du TK 001...: -55.000 VND...',
        ),
        const SizedBox(height: 12),
        _buildTransactionCard(
          bankName: 'Techcombank',
          amount: '-120.000 VND',
          details: 'Bien dong so du TK 190...: -120.000 VND...',
        ),
      ],
    );
  }

  Widget _buildTransactionCard({
    required String bankName,
    required String amount,
    required String details,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB).withOpacity(0.5),
          width: 0.667,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank name with indicator
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C950),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C950).withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                bankName,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Transaction details
          Text(
            details,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
