import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final dynamic tx;
  const TransactionTile({super.key, this.tx});

  @override
  Widget build(BuildContext context) {
    final title = tx?.title ?? tx?.description ?? 'Giao dịch';
    return ListTile(
      title: Text(title),
      subtitle: tx != null ? Text(tx.toString()) : null,
    );
  }
}