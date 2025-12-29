import 'package:flutter/material.dart';

class TransactionData {
  final String bankName;
  final String bankCode;
  final String originalSms;
  final String amount;
  final String amountColor;
  final String transactionType;
  final String bankFullName;
  final String dateTime;
  final String description;
  final String category;
  final bool isSelected;

  TransactionData({
    required this.bankName,
    required this.bankCode,
    required this.originalSms,
    required this.amount,
    required this.amountColor,
    required this.transactionType,
    required this.bankFullName,
    required this.dateTime,
    required this.description,
    required this.category,
    this.isSelected = false,
  });
}

class SmartScanResultsScreen extends StatefulWidget {
  const SmartScanResultsScreen({super.key});

  @override
  State<SmartScanResultsScreen> createState() => _SmartScanResultsScreenState();
}

class _SmartScanResultsScreenState extends State<SmartScanResultsScreen> {
  late List<TransactionData> transactions;
  late List<bool> selectedTransactions;

  @override
  void initState() {
    super.initState();
    transactions = [
      TransactionData(
        bankName: 'Vietcombank',
        bankCode: 'VCB',
        originalSms:
            'Bien dong so du TK 001234567: -55.000 VND luc 12/11/2025 09:00. ND: GRAB BIKE...',
        amount: '-55.000₫',
        amountColor: '#FF5A5F',
        transactionType: 'Chi tiêu',
        bankFullName: 'Vietcombank',
        dateTime: '12/11/2025 09:00',
        description: 'GRAB BIKE',
        category: 'Di chuyển',
      ),
      TransactionData(
        bankName: 'Techcombank',
        bankCode: 'TCB',
        originalSms:
            'Bien dong so du TK 19012345678: -120.000 VND luc 11/11/2025 18:30. ND: SHOPEE...',
        amount: '-120.000₫',
        amountColor: '#FF5A5F',
        transactionType: 'Chi tiêu',
        bankFullName: 'Techcombank',
        dateTime: '11/11/2025 18:30',
        description: 'SHOPEE',
        category: 'Mua sắm',
      ),
      TransactionData(
        bankName: 'ACB',
        bankCode: 'ACB',
        originalSms:
            'Bien dong so du TK 123456: +2.000.000 VND luc 10/11/2025 14:00. ND: Chuyen tien...',
        amount: '2.000.000₫',
        amountColor: '#2ECC71',
        transactionType: 'Thu nhập',
        bankFullName: 'ACB',
        dateTime: '10/11/2025 14:00',
        description: 'Chuyen tien',
        category: 'Lương',
      ),
    ];
    selectedTransactions = [true, true, false];
  }

  int get selectedCount => selectedTransactions.where((e) => e).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giao dịch vừa quét',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 16.669,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chọn giao dịch để lưu vào hệ thống',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14.585,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Transaction List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildTransactionCard(index);
                },
              ),
            ),
            // Save Button
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedCount > 0 ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E8AFF),
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.6),
                    ),
                  ),
                  child: Text(
                    'Lưu các giao dịch đã chọn ($selectedCount)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 16.684,
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

  Widget _buildTransactionCard(int index) {
    final tx = transactions[index];
    final isSelected = selectedTransactions[index];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.669),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3.125,
            offset: const Offset(0, 1.042),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with checkbox
          Container(
            color: const Color(0xFFF9FAFB),
            padding: const EdgeInsets.fromLTRB(16.669, 0, 0, 0),
            child: Row(
              children: [
                SizedBox(
                  width: 25.003,
                  height: 59.034,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        selectedTransactions[index] = value ?? false;
                      });
                    },
                    fillColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return const Color(0xFF3E8AFF);
                      }
                      return Colors.transparent;
                    }),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.418),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF3E8AFF),
                      width: 2.084,
                    ),
                  ),
                ),
                const SizedBox(width: 12.501),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Từ SMS:',
                        style: const TextStyle(
                          fontSize: 14.585,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tx.bankName,
                        style: const TextStyle(
                          fontSize: 14.585,
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          // Original SMS Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16.669, 16.669, 16.669, 16.669),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nội dung SMS gốc:',
                  style: const TextStyle(
                    fontSize: 12.501,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tx.originalSms,
                  style: const TextStyle(
                    fontSize: 14.585,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          // Extracted Information
          Container(
            color: const Color(0xFFEFF6FF).withOpacity(0.5),
            padding: const EdgeInsets.all(16.669),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin đã bóc tách',
                  style: const TextStyle(
                    fontSize: 12.501,
                    color: Color(0xFF3E8AFF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12.501),
                _buildInfoGrid(tx),
              ],
            ),
          ),
          // AI Classification Section
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFFAF5FF), Color(0xFFEFF6FF)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16.669),
                bottomRight: Radius.circular(16.669),
              ),
            ),
            padding: const EdgeInsets.all(16.669),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16.669,
                      color: const Color(0xFF3E8AFF),
                    ),
                    const SizedBox(width: 8.334),
                    const Text(
                      'Phân loại AI',
                      style: TextStyle(
                        fontSize: 12.501,
                        color: Color(0xFF3E8AFF),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.501),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gợi ý danh mục',
                      style: TextStyle(
                        fontSize: 12.501,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8.334),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 0.695,
                        ),
                        borderRadius: BorderRadius.circular(14.585),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.669,
                        vertical: 12.501,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tx.category,
                            style: const TextStyle(
                              fontSize: 14.585,
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Icon(
                            Icons.expand_more,
                            color: Color(0xFF64748B),
                            size: 20.836,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(TransactionData tx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInfoField(
                label: 'Số tiền',
                value: tx.amount,
                valueColor: Color(
                  int.parse(tx.amountColor.replaceFirst('#', '0xff')),
                ),
              ),
            ),
            const SizedBox(width: 12.501),
            Expanded(
              child: _buildInfoField(
                label: 'Loại',
                value: tx.transactionType,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.501),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInfoField(
                label: 'Ngân hàng',
                value: tx.bankCode,
              ),
            ),
            const SizedBox(width: 12.501),
            Expanded(
              child: _buildInfoField(
                label: 'Ngày giờ',
                value: tx.dateTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.501),
        _buildInfoField(
          label: 'Nội dung',
          value: tx.description,
        ),
      ],
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.501,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4.167),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.669,
            color: valueColor ?? const Color(0xFF0F172A),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
