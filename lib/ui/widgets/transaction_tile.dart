import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction tx;
  final VoidCallback? onTap;
  final bool showFullDate;

  const TransactionTile({super.key, required this.tx, this.onTap, this.showFullDate = false});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern('vi');
    final dateFmt = showFullDate ? DateFormat('dd/MM/yyyy HH:mm') : DateFormat('dd/MM, HH:mm');
    final isIncome = tx.type == 'income';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green.shade50 : Colors.red.shade50,
          child: Icon(
            isIncome ? Icons.trending_up : Icons.trending_down,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          (tx.note ?? tx.categoryName).toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          '${tx.categoryName}${tx.bank != null && tx.bank!.isNotEmpty ? ' - ${tx.bank}' : ''}',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${isIncome ? '+' : '-'} ${fmt.format(tx.amount)}đ',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateFmt.format(tx.createdAt),
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
