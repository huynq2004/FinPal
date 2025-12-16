import 'package:finpal/ui/screens/transaction_detail_screen.dart';
import 'package:finpal/ui/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/transaction_history_viewmodel.dart';
import 'manual_transaction_screen.dart';
import 'transaction_detail_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');
  String _filter = 'all'; // all | income | expense
  String _query = '';
  final _chipSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionHistoryViewModel>().loadFakeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {},
          // ),
        ],
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
            ),
          ),
        ),
      ),
      body: Consumer<TransactionHistoryViewModel>(
        builder: (context, vm, _) {
          final items = vm.transactions
              .where((tx) {
                if (_filter == 'income' && tx.type != 'income') return false;
                if (_filter == 'expense' && tx.type != 'expense') return false;
                if (_query.isEmpty) return true;
                final q = _query.toLowerCase();
                return (tx.note ?? '').toLowerCase().contains(q) ||
                    tx.categoryName.toLowerCase().contains(q) ||
                    (tx.bank ?? '').toLowerCase().contains(q);
              })
              .toList();

          if (items.isEmpty) return const Center(child: Text('Không tìm thấy giao dịch'));

          // group by day labels
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final Map<String, List> groups = {};
          String groupKey(DateTime dt) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final d = DateTime(dt.year, dt.month, dt.day);
            if (d == today) return 'Hôm nay';
            if (d == today.subtract(const Duration(days: 1))) return 'Hôm qua';
            return DateFormat('dd/MM/yyyy').format(dt);
          }

          for (var tx in items) {
            final k = groupKey(tx.createdAt);
            groups.putIfAbsent(k, () => []).add(tx);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  children: [
                    TextField(
                      key: const Key('history_search'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                        hintText: 'Tìm GRAB, Shopee, tiền điện...',
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ChoiceChip(
                          key: const Key('chip_all'),
                          label: const Text('Tất cả'),
                          selected: _filter == 'all',
                          selectedColor: const Color(0xFF3E8AFF),
                          onSelected: (_) => setState(() => _filter = 'all'),
                          labelStyle: TextStyle(color: _filter == 'all' ? Colors.white : const Color(0xFF64748B)),
                          backgroundColor: const Color(0xFFF3F4F6),
                        ),
                        SizedBox(width: _chipSpacing),
                        ChoiceChip(
                          key: const Key('chip_expense'),
                          label: const Text('Chi tiêu'),
                          selected: _filter == 'expense',
                          selectedColor: const Color(0xFF3E8AFF),
                          onSelected: (_) => setState(() => _filter = 'expense'),
                          labelStyle: TextStyle(color: _filter == 'expense' ? Colors.white : const Color(0xFF64748B)),
                          backgroundColor: const Color(0xFFF3F4F6),
                        ),
                        SizedBox(width: _chipSpacing),
                        ChoiceChip(
                          key: const Key('chip_income'),
                          label: const Text('Thu nhập'),
                          selected: _filter == 'income',
                          selectedColor: const Color(0xFF3E8AFF),
                          onSelected: (_) => setState(() => _filter = 'income'),
                          labelStyle: TextStyle(color: _filter == 'income' ? Colors.white : const Color(0xFF64748B)),
                          backgroundColor: const Color(0xFFF3F4F6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // list grouped
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  children: groups.entries.map((entry) {
                    final label = entry.key;
                    final list = entry.value as List;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(label, style: const TextStyle(color: Color(0xFF64748B))),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: List.generate(list.length, (i) {
                              final tx = list[i];
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TransactionDetailScreen(tx: tx),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                      child: TransactionTile(tx: tx),
                                    ),
                                  ),
                                  if (i != list.length - 1) const Divider(height: 0),
                                ],
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManualTransactionScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
