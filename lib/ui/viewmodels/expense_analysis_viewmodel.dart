import 'package:flutter/foundation.dart';
import '../../domain/models/transaction.dart';

class ExpenseAnalysisViewModel extends ChangeNotifier {
  String _timeRange = 'week'; // 'week', 'month', 'year'
  int _totalExpense = 0;
  List<ExpenseItem> _expenseItems = [];

  String get timeRange => _timeRange;
  int get totalExpense => _totalExpense;
  List<ExpenseItem> get expenseItems => List.unmodifiable(_expenseItems);

  void setTimeRange(String range) {
    if (_timeRange != range) {
      _timeRange = range;
      _loadExpenseData();
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

  Future<void> _loadExpenseData() async {
    // TODO: Load data từ repository
    // Sprint 1: Fake data
    final now = DateTime.now();

    if (_timeRange == 'week') {
      _loadWeeklyData(now);
    } else if (_timeRange == 'month') {
      _loadMonthlyData(now);
    } else if (_timeRange == 'year') {
      _loadYearlyData(now);
    }
  }

  void _loadWeeklyData(DateTime now) {
    // Lấy ngày đầu tuần (Thứ 2)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    _expenseItems = [];
    _totalExpense = 0;

    // Tạo 7 ngày
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      final amount = _getFakeAmount(i);

      _expenseItems.add(
        ExpenseItem(
          label: '$dayName\n${date.day}/${date.month}',
          amount: amount,
          date: date,
          categoryBreakdown: _generateCategoryBreakdown(amount),
        ),
      );

      _totalExpense += amount;
    }
  }

  void _loadMonthlyData(DateTime now) {
    final year = now.year;
    final month = now.month;

    // Lấy số ngày trong tháng
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Lấy ngày đầu tháng và weekday của nó
    final firstDay = DateTime(year, month, 1);
    final startWeekday = firstDay.weekday;

    _expenseItems = [];
    _totalExpense = 0;

    // Thêm các ngày từ tuần trước (nếu có)
    for (int i = 1; i < startWeekday; i++) {
      final prevDate = firstDay.subtract(Duration(days: startWeekday - i));
      final amount = _getFakeAmount(i - 1);

      _expenseItems.add(
        ExpenseItem(
          label: 'Tuần trước\n${prevDate.day}/${prevDate.month}',
          amount: amount,
          date: prevDate,
          isOutOfMonth: true,
          categoryBreakdown: _generateCategoryBreakdown(amount),
        ),
      );

      _totalExpense += amount;
    }

    // Thêm các ngày trong tháng
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final amount = _getFakeAmount(day - 1);

      _expenseItems.add(
        ExpenseItem(
          label: 'Ngày $day',
          amount: amount,
          date: date,
          categoryBreakdown: _generateCategoryBreakdown(amount),
        ),
      );

      _totalExpense += amount;
    }

    // Thêm các ngày từ tuần sau (nếu cần)
    final endWeekday = DateTime(year, month, daysInMonth).weekday;
    if (endWeekday != 7) {
      for (int i = 1; i <= 7 - endWeekday; i++) {
        final nextDate = DateTime(
          year,
          month,
          daysInMonth,
        ).add(Duration(days: i));
        final amount = _getFakeAmount(daysInMonth + i - 1);

        _expenseItems.add(
          ExpenseItem(
            label: 'Tuần sau\n${nextDate.day}/${nextDate.month}',
            amount: amount,
            date: nextDate,
            isOutOfMonth: true,
            categoryBreakdown: _generateCategoryBreakdown(amount),
          ),
        );

        _totalExpense += amount;
      }
    }
  }

  void _loadYearlyData(DateTime now) {
    final year = now.year;
    final months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];

    _expenseItems = [];
    _totalExpense = 0;

    for (int i = 0; i < 12; i++) {
      final amount = _getFakeAmount(i) * 5; // Tăng amount cho năm
      final date = DateTime(year, i + 1, 1);

      _expenseItems.add(
        ExpenseItem(
          label: months[i],
          amount: amount,
          date: date,
          categoryBreakdown: _generateCategoryBreakdown(amount),
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
