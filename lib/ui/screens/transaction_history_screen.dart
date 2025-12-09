import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_history_viewmodel.dart';
import '../../domain/models/transaction.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    // gọi load dữ liệu khi màn hình tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionHistoryViewModel>().loadFakeData();
      // sau này thay bằng loadTransactionsForMonth(year, month)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
      ),
      body: Consumer<TransactionHistoryViewModel>(
        builder: (context, vm, child) {
          final items = vm.transactions;

          if (items.isEmpty) {
            return const Center(
              child: Text('Chưa có giao dịch nào'),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final tx = items[index];
              final isIncome = tx.type == 'income';

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    _formatAmount(tx.amount, isIncome),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Danh mục: ${tx.categoryName}'),
                      if (tx.bank != null) Text('Ngân hàng: ${tx.bank}'),
                      Text('Thời gian: ${_dateFormatter.format(tx.createdAt)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatAmount(int amount, bool isIncome) {
    // cậu có thể dùng NumberFormat ở đây nếu muốn format đẹp hơn
    final formatted = '${amount.toString()} đ';
    return isIncome ? '+ $formatted' : '- $formatted';
  }
}
