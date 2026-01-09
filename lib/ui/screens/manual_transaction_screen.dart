import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finpal/ui/viewmodels/manual_transaction_viewmodel.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/db/database_provider.dart';

class ManualTransactionScreen extends StatelessWidget {
  const ManualTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ManualTransactionViewModel(),
      child: const _ManualTransactionForm(),
    );
  }
}

class _ManualTransactionForm extends StatefulWidget {
  const _ManualTransactionForm();

  @override
  State<_ManualTransactionForm> createState() => _ManualTransactionFormState();
}

class _ManualTransactionFormState extends State<_ManualTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  final List<String> _categories = [
    'Ăn uống',
    'Mua sắm',
    'Di chuyển',
    'Hóa đơn',
    'Giải trí',
    'Lương',
    'Khác',
  ];
  final List<String> _sources = [
    'Vietcombank',
    'Techcombank',
    'ACB',
    'VPBank',
    'MB Bank',
    'Tiền mặt',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load categories from DB via ViewModel after widget is initialized
    Future.microtask(() {
      try {
        final vm = context.read<ManualTransactionViewModel>();
        vm.loadCategories();
      } catch (_) {}
    });
  }

  Future<void> _pickDate(
    BuildContext context,
    ManualTransactionViewModel viewModel,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) viewModel.setDate(picked);
  }

  Future<void> _pickTime(
    BuildContext context,
    ManualTransactionViewModel viewModel,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: viewModel.time,
    );
    if (picked != null) viewModel.setTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManualTransactionViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Thêm giao dịch',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
              ),
            ),
            centerTitle: false,
            actions: [
              // TEMP DEBUG: Dump all transactions to console
              IconButton(
                tooltip: 'Debug: Dump transactions',
                icon: const Icon(Icons.bug_report, color: Color(0xFF64748B)),
                onPressed: () async {
                  try {
                    final repo = TransactionRepository(
                      DatabaseProvider.instance,
                    );
                    final txs = await repo.getAllTransactions();
                    // Print structured dump to console
                    // ignore: avoid_print
                    print('===== TRANSACTION DUMP: count=${txs.length} =====');
                    for (var i = 0; i < txs.length; i++) {
                      final t = txs[i];
                      // ignore: avoid_print
                      print(
                        '[#${i + 1}] id=${t.id} | amount=${t.amount} | type=${t.type} | catId=${t.categoryId} | catName=${t.categoryName} | bank=${t.bank} | time=${t.createdAt.toIso8601String()} | note=${t.note} | source=${t.source}',
                      );
                    }
                    // ignore: avoid_print
                    print('===== END TRANSACTION DUMP =====');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã in ${txs.length} giao dịch ra console',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dump lỗi: ${e.toString()}')),
                      );
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Số tiền',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        suffixText: '₫',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 0.67,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        final v = int.tryParse(value);
                        if (v != null) viewModel.setAmount(v);
                      },
                      validator: (value) {
                        final v = int.tryParse(value ?? '');
                        if (v == null || v <= 0) return 'Số tiền phải > 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loại',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => viewModel.setType('Chi tiêu'),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: viewModel.type == 'Chi tiêu'
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: viewModel.type == 'Chi tiêu'
                                      ? [
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                            spreadRadius: -1,
                                          ),
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          ),
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Chi tiêu',
                                  style: TextStyle(
                                    color: viewModel.type == 'Chi tiêu'
                                        ? Color(0xFF0F172A)
                                        : Color(0xFF64748B),
                                    fontSize: 16,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => viewModel.setType('Thu nhập'),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: viewModel.type == 'Thu nhập'
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: viewModel.type == 'Thu nhập'
                                      ? [
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                            spreadRadius: -1,
                                          ),
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          ),
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Thu nhập',
                                  style: TextStyle(
                                    color: viewModel.type == 'Thu nhập'
                                        ? Color(0xFF0F172A)
                                        : Color(0xFF64748B),
                                    fontSize: 16,
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Danh mục',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: viewModel.category,
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          viewModel.setCategory(v ?? viewModel.category),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 0.67,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nguồn tiền',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: viewModel.source,
                      items: _sources
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          viewModel.setSource(v ?? viewModel.source),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 0.67,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ngày',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _pickDate(context, viewModel),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 0.67,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${viewModel.date.day}/${viewModel.date.month}/${viewModel.date.year}',
                                        style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Giờ',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _pickTime(context, viewModel),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 0.67,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 18,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        viewModel.time.format(context),
                                        style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nội dung / Mô tả',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'VD: Ăn trưa',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 0.67,
                          ),
                        ),
                      ),
                      onChanged: (value) => viewModel.setDescription(value),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Nhập nội dung';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ghi chú (tùy chọn)',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Thêm ghi chú...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 0.67,
                          ),
                        ),
                      ),
                      maxLines: 2,
                      onChanged: viewModel.setNote,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: const Color(0xFF3E8AFF),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                try {
                                  final success = await viewModel
                                      .saveTransaction();
                                  if (mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Đã lưu giao dịch thành công!',
                                        ),
                                      ),
                                    );
                                    Navigator.of(context).pop(true);
                                  } else if (mounted && !success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          viewModel.errorMessage ??
                                              'Có lỗi xảy ra khi lưu giao dịch',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          viewModel.errorMessage ??
                                              'Có lỗi xảy ra khi lưu giao dịch',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: const Text('Lưu'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFF2F4F6),
                                width: 0.67,
                              ),
                              foregroundColor: Color(0xFF64748B),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Hủy'),
                          ),
                        ),
                      ],
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
}
