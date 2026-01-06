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
  String _filter = 'all'; // all | expense | income
  String _query = '';

  final _timeFmt = DateFormat('HH:mm');
  final _dateFmt = DateFormat('dd/MM/yyyy');

  final _moneyFmt = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

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
      backgroundColor: const Color(0xFFF5F7FA),

      // AppBar: title bên trái gần back
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          color: const Color(0xFF0F172A),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Lịch sử giao dịch',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF0F172A),
          ),
        ),
      ),

      body: Consumer<TransactionHistoryViewModel>(
        builder: (context, vm, _) {
          final items = vm.transactions.where((tx) {
            if (_filter == 'income' && tx.type != 'income') return false;
            if (_filter == 'expense' && tx.type != 'expense') return false;

            final q = _query.trim().toLowerCase();
            if (q.isEmpty) return true;

            final note = (tx.note ?? '').toLowerCase();
            final cat = (tx.categoryName).toLowerCase();
            final bank = (tx.bank ?? '').toLowerCase();
            return note.contains(q) || cat.contains(q) || bank.contains(q);
          }).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // group by day labels
          final groups = <String, List<dynamic>>{};
          String groupKey(DateTime dt) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final d = DateTime(dt.year, dt.month, dt.day);

            if (d == today) return 'Hôm nay';
            if (d == today.subtract(const Duration(days: 1))) return 'Hôm qua';
            return _dateFmt.format(dt);
          }

          for (final tx in items) {
            final k = groupKey(tx.createdAt);
            groups.putIfAbsent(k, () => []).add(tx);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    _SearchBox(
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 10),
                    _FilterPills(
                      value: _filter,
                      onChanged: (v) => setState(() => _filter = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          'Không tìm thấy giao dịch',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                        children: groups.entries.map((entry) {
                          final label = entry.key;
                          final list = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 8, left: 2),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: List.generate(list.length, (i) {
                                    final tx = list[i];

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TransactionDetailScreen(tx: tx),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            child: _TxRow(
                                              isIncome: tx.type == 'income',
                                              title: (tx.note ?? '').trim().isEmpty ? tx.categoryName : tx.note!,
                                              subtitle: _subtitle(tx),
                                              amountText: _formatMoney(tx),
                                              timeText: _timeFmt.format(tx.createdAt),
                                            ),
                                          ),
                                          if (i != list.length - 1)
                                            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                                        ],
                                      ),
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

      // ✅ FAB mới: tròn + gradient + shadow + nâng cao lên
      floatingActionButton: _BlueFab(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManualTransactionScreen()),
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

  String _subtitle(dynamic tx) {
    final bank = (tx.bank ?? '').toString().trim();
    final cat = tx.categoryName.toString().trim();
    if (bank.isEmpty) return cat;
    return '$cat • $bank';
  }

  String _formatMoney(dynamic tx) {
    final num raw = (tx.amount as num?) ?? 0;
    final num absVal = raw.abs();
    final sign = tx.type == 'income' ? '+' : '-';
    return '$sign${_moneyFmt.format(absVal)}đ';
  }
}

// ===================== UI Widgets =====================

class _SearchBox extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBox({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        key: const Key('history_search'),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Tìm GRAB, Shopee, tiền điện...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _FilterPills({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget pill(String key, String text) {
      final selected = value == key;
      return FilterChip(
        label: Text(text),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onChanged(key),
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
        selectedColor: const Color(0xFF3E8AFF),
        backgroundColor: const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: selected ? Colors.transparent : const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
    }

    return Row(
      children: [
        Container(key: const Key('chip_all'), child: pill('all', 'Tất cả')),
        const SizedBox(width: 10),
        Container(key: const Key('chip_expense'), child: pill('expense', 'Chi tiêu')),
        const SizedBox(width: 10),
        Container(key: const Key('chip_income'), child: pill('income', 'Thu nhập')),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  final bool isIncome;
  final String title;
  final String subtitle;
  final String amountText;
  final String timeText;

  const _TxRow({
    required this.isIncome,
    required this.title,
    required this.subtitle,
    required this.amountText,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor = isIncome ? const Color(0xFF2ECC71) : const Color(0xFFFF5A5F);
    final iconBg = isIncome ? const Color(0xFFEAFBF1) : const Color(0xFFFFEEF0);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(
            isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: amountColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amountText,
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: amountColor),
            ),
            const SizedBox(height: 4),
            Text(
              timeText,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

//  FAB custom: 
class _BlueFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _BlueFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20), 
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Center(
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
