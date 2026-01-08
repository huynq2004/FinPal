import 'package:flutter/foundation.dart';

import '../../data/db/database_provider.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/models/transaction.dart';

class ExpenseAnalysisViewModel extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository(
    DatabaseProvider.instance,
  );

  static const List<int> _palette = [
    0xFF3E8AFF,
    0xFFFF6B6B,
    0xFF4ECDC4,
    0xFFFFD93D,
    0xFF95E1D3,
    0xFFC7CEEA,
    0xFF7AD1F7,
    0xFF9AE6B4,
    0xFF6B7280,
  ];

  String _timeRange = 'week'; // 'week', 'month', 'year'
  int _totalExpense = 0;
  List<ExpenseItem> _expenseItems = [];

  String get timeRange => _timeRange;
  int get totalExpense => _totalExpense;
  List<ExpenseItem> get expenseItems => List.unmodifiable(_expenseItems);

  Future<void> setTimeRange(String range) async {
    if (_timeRange != range) {
      _timeRange = range;
      await _loadExpenseData();
      notifyListeners();
    }
  }

  Future<void> loadData() async {
    await _loadExpenseData();
    notifyListeners();
  }

  Map<String, dynamic> getHighestExpenseDay() {
    if (_expenseItems.isEmpty) {
      return {'label': 'N/A', 'amount': 0};
    }

    ExpenseItem highest = _expenseItems[0];
    for (var item in _expenseItems) {
      if (item.amount > highest.amount) {
        highest = item;
      }
    }

    // Chuyển đổi label để hiển thị đúng tên thứ
    String displayLabel = highest.label;
    if (_timeRange == 'week') {
      // Label là "T2\nngày/tháng", ta muốn hiển thị "Thứ X"
      final parts = highest.label.split('\n');
      final dayCode = parts[0];
      displayLabel = _getDayNameFull(dayCode);
    }

    return {'label': displayLabel, 'amount': highest.amount};
  }

  String _getDayNameFull(String code) {
    const dayNames = {
      'T2': 'Thứ Hai',
      'T3': 'Thứ Ba',
      'T4': 'Thứ Tư',
      'T5': 'Thứ Năm',
      'T6': 'Thứ Sáu',
      'T7': 'Thứ Bảy',
      'CN': 'Chủ Nhật',
    };
    return dayNames[code] ?? 'N/A';
  }

  List<Transaction> _filterByDate(List<Transaction> txs, DateTime date) {
    return txs.where((t) {
      if (t.type != 'expense') return false;
      final d = t.createdAt;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  int _sumAmount(Iterable<Transaction> txs) {
    var sum = 0;
    for (final t in txs) {
      sum += t.amount;
    }
    return sum;
  }

  List<CategoryBreakdown> _buildCategoryBreakdown(
    List<Transaction> txs,
    Map<int, String> catNameById,
  ) {
    final Map<String, int> agg = {};
    for (final t in txs.where((e) => e.type == 'expense')) {
      final rawName = t.categoryName.trim();
      final resolved = rawName.isNotEmpty
          ? rawName
          : (t.categoryId != null ? (catNameById[t.categoryId] ?? '') : '');
      final display = resolved.isNotEmpty ? _cleanName(resolved) : 'Khác';
      agg[display] = (agg[display] ?? 0) + t.amount;
    }

    final total = agg.values.fold<int>(0, (s, v) => s + v);
    final list =
        agg.entries
            .map(
              (e) => CategoryBreakdown(
                categoryName: e.key,
                amount: e.value,
                color: _colorForName(e.key),
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    // Nếu total=0, giữ amount nhưng percent không dùng; caller chỉ hiển thị amount
    return list;
  }

  int _colorForName(String name) {
    final idx = name.toLowerCase().hashCode.abs() % _palette.length;
    return _palette[idx];
  }

  String _cleanName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
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

  Future<void> _loadExpenseData() async {
    final now = DateTime.now();
    final catNameById = await _loadCategoryNames();

    if (_timeRange == 'week') {
      await _loadWeeklyData(now, catNameById);
    } else if (_timeRange == 'month') {
      await _loadMonthlyData(now, catNameById);
    } else if (_timeRange == 'year') {
      await _loadYearlyData(now, catNameById);
    }
  }

  Future<void> _loadWeeklyData(
    DateTime now,
    Map<int, String> catNameById,
  ) async {
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    final txs = await _repo.getTransactionsByDateRange(
      startDate: start,
      endDate: end,
    );

    _expenseItems = [];
    _totalExpense = 0;

    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final dayTx = _filterByDate(txs, date);
      final amount = _sumAmount(dayTx);

      _expenseItems.add(
        ExpenseItem(
          label: '${_getDayName(date.weekday)}\n${date.day}/${date.month}',
          amount: amount,
          date: date,
          categoryBreakdown: _buildCategoryBreakdown(dayTx, catNameById),
        ),
      );

      _totalExpense += amount;
    }
  }

  Future<void> _loadMonthlyData(
    DateTime now,
    Map<int, String> catNameById,
  ) async {
    final year = now.year;
    final month = now.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday;
    final lastDay = DateTime(year, month, daysInMonth);
    final endWeekday = lastDay.weekday;

    final rangeStart = firstDay.subtract(Duration(days: startWeekday - 1));
    final rangeEnd = lastDay.add(Duration(days: 7 - endWeekday));

    final txs = await _repo.getTransactionsByDateRange(
      startDate: rangeStart,
      endDate: rangeEnd.add(
        const Duration(hours: 23, minutes: 59, seconds: 59),
      ),
    );

    _expenseItems = [];
    _totalExpense = 0;

    // leading days
    for (int i = 0; i < startWeekday - 1; i++) {
      final date = rangeStart.add(Duration(days: i));
      final dayTx = _filterByDate(txs, date);
      final amount = _sumAmount(dayTx);
      _expenseItems.add(
        ExpenseItem(
          label: '${date.day}/${date.month}',
          amount: amount,
          date: date,
          isOutOfMonth: true,
          categoryBreakdown: _buildCategoryBreakdown(dayTx, catNameById),
        ),
      );
    }

    // in-month days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dayTx = _filterByDate(txs, date);
      final amount = _sumAmount(dayTx);
      _expenseItems.add(
        ExpenseItem(
          label: 'Ngày $day',
          amount: amount,
          date: date,
          categoryBreakdown: _buildCategoryBreakdown(dayTx, catNameById),
        ),
      );
      _totalExpense += amount;
    }

    // trailing days
    for (int i = 1; i <= 7 - endWeekday; i++) {
      final date = lastDay.add(Duration(days: i));
      final dayTx = _filterByDate(txs, date);
      final amount = _sumAmount(dayTx);
      _expenseItems.add(
        ExpenseItem(
          label: '${date.day}/${date.month}',
          amount: amount,
          date: date,
          isOutOfMonth: true,
          categoryBreakdown: _buildCategoryBreakdown(dayTx, catNameById),
        ),
      );
    }
  }

  Future<void> _loadYearlyData(
    DateTime now,
    Map<int, String> catNameById,
  ) async {
    final year = now.year;
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);

    final txs = await _repo.getTransactionsByDateRange(
      startDate: start,
      endDate: end,
    );

    _expenseItems = [];
    _totalExpense = 0;

    for (int m = 1; m <= 12; m++) {
      final monthTx = txs.where(
        (t) => t.type == 'expense' && t.createdAt.month == m,
      );
      final amount = _sumAmount(monthTx);
      final date = DateTime(year, m, 1);

      _expenseItems.add(
        ExpenseItem(
          label: 'Tháng $m',
          amount: amount,
          date: date,
          categoryBreakdown: _buildCategoryBreakdown(
            monthTx.toList(),
            catNameById,
          ),
        ),
      );

      _totalExpense += amount;
    }
  }

  String _getDayName(int weekday) {
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return days[weekday - 1];
  }

  int _getFakeAmount(int index) {
    final amounts = [
      150000,
      200000,
      120000,
      300000,
      180000,
      220000,
      250000,
      160000,
      190000,
      210000,
      240000,
      170000,
    ];
    return amounts[index % amounts.length];
  }

  List<CategoryBreakdown> _generateCategoryBreakdown(int total) {
    // Fake category breakdown
    return [
      CategoryBreakdown(
        categoryName: 'Ăn uống',
        amount: (total * 0.4).toInt(),
        color: 0xFFFF6B6B,
      ),
      CategoryBreakdown(
        categoryName: 'Di chuyển',
        amount: (total * 0.3).toInt(),
        color: 0xFF4ECDC4,
      ),
      CategoryBreakdown(
        categoryName: 'Mua sắm',
        amount: (total * 0.2).toInt(),
        color: 0xFFFFE66D,
      ),
      CategoryBreakdown(
        categoryName: 'Khác',
        amount: (total * 0.1).toInt(),
        color: 0xFFB5B5B5,
      ),
    ];
  }
}

class ExpenseItem {
  final String label;
  final int amount;
  final DateTime date;
  final List<CategoryBreakdown> categoryBreakdown;
  final bool isOutOfMonth;

  ExpenseItem({
    required this.label,
    required this.amount,
    required this.date,
    required this.categoryBreakdown,
    this.isOutOfMonth = false,
  });
}

class CategoryBreakdown {
  final String categoryName;
  final int amount;
  final int color;

  CategoryBreakdown({
    required this.categoryName,
    required this.amount,
    required this.color,
  });
}
