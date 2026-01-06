import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/transaction.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction tx;

  const TransactionDetailScreen({super.key, required this.tx});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late final TextEditingController _noteController;
  late String _category;

  final List<String> _categories = [
    'Di chuyển',
    'Ăn uống',
    'Mua sắm',
    'Hóa đơn',
    'Giải trí',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.tx.note ?? '');

    // ✅ init category an toàn
    final initCat = widget.tx.categoryName.trim();
    _category = initCat.isNotEmpty ? initCat : _categories.first;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Widget _infoRow(String label, String value, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF3F4F6), width: 0.67),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('vi');
    final dateFmt = DateFormat('dd/MM/yyyy');
    final timeFmt = DateFormat('HH:mm');

    final tx = widget.tx;
    final isIncome = tx.type == 'income';

    // ✅ FIX: tiền hiển thị đúng (abs + sign)
    final num amountAbs = (tx.amount as num).abs();
    final sign = isIncome ? '+' : '-';

    // ✅ FIX: màu đúng theo loại giao dịch
    final amountColor = isIncome ? const Color(0xFF22C55E) : const Color(0xFFFF5A5F);
    final pillBg = isIncome ? const Color(0xFFEAFBF1) : const Color(0xFFFFEEF0);
    final pillText = isIncome ? const Color(0xFF22C55E) : const Color(0xFFFF5A5F);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Chi tiết giao dịch',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.67),
          child: Divider(height: 0.67, thickness: 0.67, color: Color(0xFFF3F4F6)),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Amount Card (BỎ Stack để không bị chèn lên nhau)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  const Text(
                    'Số tiền',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    '$sign${fmt.format(amountAbs)}đ',
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isIncome ? 'Thu nhập' : 'Chi tiêu',
                      style: TextStyle(
                        color: pillText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _infoRow('Ngân hàng', tx.bank ?? 'Không có thông tin ngân hàng'),
                  _infoRow('Ngày', dateFmt.format(tx.createdAt)),
                  _infoRow('Giờ', timeFmt.format(tx.createdAt)),
                  _infoRow('Nội dung gốc', tx.note ?? '—', last: true),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Classification Card (giữ nguyên như bạn)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Phân loại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  const Text('Danh mục', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 0.67),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        key: const Key('tx_detail_category'),
                        value: _category,
                        isExpanded: true,
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _category = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '💡 Nếu AI phân loại sai, bạn có thể chỉnh sửa danh mục.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ghi chú (tùy chọn)', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 0.67),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      key: const Key('tx_detail_notes'),
                      controller: _noteController,
                      maxLines: 5,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Thêm ghi chú cho giao dịch này...',
                        hintStyle: TextStyle(color: Color(0xFFD1D5DC)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Save button (gradient)
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('tx_detail_save'),
                  onTap: () {
                    final updated = tx.copyWith(
                      note: _noteController.text,
                      categoryName: _category,
                    );
                    Navigator.pop(context, updated);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: const Center(
                    child: Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Delete button (pale red)
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFEEDEE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('tx_detail_delete'),
                  onTap: () {
                    Navigator.pop(context, {'deleted': true, 'tx': tx});
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.delete, color: Color(0xFFFF5A5F)),
                      SizedBox(width: 8),
                      Text('Xóa giao dịch', style: TextStyle(color: Color(0xFFFF5A5F), fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
