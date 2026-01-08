import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/db/database_provider.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/models/category_stat.dart';
import '../../domain/models/transaction.dart';

class DashboardViewModel extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository(
    DatabaseProvider.instance,
  );

  int totalIncome = 0;
  int totalExpense = 0;
  int get balance => totalIncome - totalExpense;

  final List<Transaction> _recent = [];

  List<Transaction> get recentTransactions => List.unmodifiable(_recent);

  List<CategoryStat> _categories = [];
  List<CategoryStat> get categories => List.unmodifiable(_categories);

  String monthLabel(int year, int month) {
    return 'Tháng $month/$year';
  }

  Future<void> loadSummary(int year, int month) async {
    totalIncome = 0;
    totalExpense = 0;
    _recent.clear();
    _categories = [];

    try {
      // Lấy toàn bộ lịch sử giao dịch
      final txs = await _repo.getAllTransactions();
      final catNameById = await _loadCategoryNames();

      for (final tx in txs) {
        if (tx.type == 'income') {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }

      _recent.addAll(txs.take(3));

      final Map<String, _CatAgg> catAgg = {};
      for (final tx in txs.where((t) => t.type == 'expense')) {
        final rawName = tx.categoryName.trim();
        final resolvedName = rawName.isNotEmpty
            ? rawName
            : (tx.categoryId != null ? (catNameById[tx.categoryId] ?? '') : '');
        final cleaned = _cleanName(resolvedName);
        final displayName = cleaned.isNotEmpty ? cleaned : 'Khác';
        final key = _nameKey(displayName);
        final entry = catAgg.putIfAbsent(
          key,
          () => _CatAgg(displayName: displayName),
        );
        entry.amount += tx.amount;
      }

      final totalCat = catAgg.values.fold<int>(0, (sum, e) => sum + e.amount);

      _categories =
          catAgg.values
              .map(
                (e) => CategoryStat(
                  name: e.displayName,
                  color: _stableColor(e.displayName),
                  percent: totalCat == 0 ? 0.0 : e.amount / totalCat,
                  amount: e.amount,
                ),
              )
              .toList()
            ..sort((a, b) => b.amount.compareTo(a.amount));

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Dashboard loadSummary error: $e');
      }
      notifyListeners();
    }
  }
}

class _CatAgg {
  _CatAgg({required this.displayName, this.amount = 0});
  final String displayName;
  int amount;
}

Future<Map<int, String>> _loadCategoryNames() async {
  try {
    final db = await DatabaseProvider.instance.database;
    final rows = await db.query('categories', columns: ['id', 'name']);
    final map = <int, String>{};
    for (final r in rows) {
      final id = r['id'] is int
          ? r['id'] as int
          : int.tryParse(r['id'].toString()) ?? -1;
      if (id < 0) continue;
      final name = (r['name'] ?? '').toString();
      if (name.isNotEmpty) map[id] = name;
    }
    return map;
  } catch (_) {
    return {};
  }
}

Color _stableColor(String name) {
  const palette = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFD93D),
    Color(0xFF95E1D3),
    Color(0xFFC7CEEA),
    Color(0xFF7AD1F7),
    Color(0xFF9AE6B4),
    Color(0xFF6B7280),
  ];
  final hash = name.toLowerCase().hashCode;
  final idx = hash.abs() % palette.length;
  return palette[idx];
}

String _cleanName(String name) {
  return name.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String _nameKey(String name) {
  return _cleanName(name).toLowerCase();
}
