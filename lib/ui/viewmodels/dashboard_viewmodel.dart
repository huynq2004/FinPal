import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/data/repositories/categories_repository.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/category_stat.dart';

class DashboardViewModel extends ChangeNotifier {
  int totalIncome = 0;
  int totalExpense = 0;
  int get balance => totalIncome - totalExpense;

  final List<Transaction> _recent = [];

  List<Transaction> get recentTransactions => List.unmodifiable(_recent);

  List<CategoryStat> _categories = [];
  List<CategoryStat> get categories => List.unmodifiable(_categories);

  // Repositories
  late final TransactionRepository _txRepo;

  // Cached maps
  Map<int, String> _categoryNames = {};
  Map<String, Color> _categoryColors = {};

  DashboardViewModel() {
    _txRepo = TransactionRepository(DatabaseProvider.instance);
  }

  String monthLabel(int year, int month) {
    return 'Tháng $month/$year';
  }

  Future<void> loadSummary(int year, int month) async {
    try {
      // Ensure category maps are ready
      await _ensureCategoryMaps();

      // Load transactions for the month (both manual and scanned SMS already persisted)
      final txs = await _txRepo.getTransactionsByMonth(year, month);
      debugPrint(
        '🔍 Dashboard: Loaded ${txs.length} transactions for $year/$month',
      );
      for (final tx in txs) {
        debugPrint(
          '  📄 ID=${tx.id}, amount=${tx.amount}, type=${tx.type}, cat=${tx.categoryName}, note=${tx.note}',
        );
      }

      // Attach category names for display (fallback to 'Khác')
      final enriched = txs.map((t) {
        final name = (t.categoryName.isNotEmpty)
            ? t.categoryName
            : (_categoryNames[t.categoryId ?? -1] ?? 'Khác');
        return t.copyWith(categoryName: name);
      }).toList();

      // Recent transactions (already ordered DESC by repo)
      _recent
        ..clear()
        ..addAll(enriched);

      // Compute totals
      totalIncome = 0;
      totalExpense = 0;
      for (final t in enriched) {
        if (t.type == 'income') {
          totalIncome += t.amount;
        } else {
          totalExpense += t.amount;
        }
      }
      debugPrint(
        '💰 Dashboard: totalIncome=$totalIncome, totalExpense=$totalExpense',
      );

      // Compute category stats for expenses ONLY
      final Map<String, int> byCategory = {};
      for (final t in enriched) {
        if (t.type != 'expense') continue;
        final key = (t.categoryName.isNotEmpty)
            ? t.categoryName
            : (_categoryNames[t.categoryId ?? -1] ?? 'Khác');
        byCategory[key] = (byCategory[key] ?? 0) + t.amount;
      }

      // Sort by amount desc
      final entries = byCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      debugPrint(
        '📊 Dashboard: Category breakdown: ${entries.map((e) => '${e.key}=${e.value}').join(", ")}',
      );

      // Build CategoryStat list with percents and colors
      final total = totalExpense == 0 ? 1 : totalExpense; // avoid div by zero
      final fallbackPalette = <Color>[
        const Color(0xFFFF6B6B),
        const Color(0xFF4ECDC4),
        const Color(0xFFFFD93D),
        const Color(0xFF95E1D3),
        const Color(0xFFC7CEEA),
        const Color(0xFF3E8AFF),
        const Color(0xFF325DFF),
      ];
      int colorIdx = 0;

      _categories = entries.map((e) {
        final name = e.key;
        final amount = e.value;
        final color =
            _categoryColors[name] ??
            fallbackPalette[colorIdx++ % fallbackPalette.length];
        final percent = amount / total;
        debugPrint(
          '  → $name: $amount VND (${(percent * 100).toStringAsFixed(1)}%)',
        );
        return CategoryStat(
          name: name,
          color: color,
          percent: percent,
          amount: amount,
        );
      }).toList();

      debugPrint(
        '✅ Dashboard: Loaded ${_categories.length} expense categories',
      );
      notifyListeners();
    } catch (e) {
      // In case of any failure, keep state safe and notify
      debugPrint('❌ Dashboard loadSummary error: $e');
      notifyListeners();
    }
  }

  Future<void> _ensureCategoryMaps() async {
    if (_categoryNames.isNotEmpty && _categoryColors.isNotEmpty) return;

    final db = await DatabaseProvider.instance.database;
    final catRepo = CategoriesRepository(db);

    // id -> name
    _categoryNames = await catRepo.loadCategoryNames();

    // name -> Color (parse from hex), with safe fallbacks
    _categoryColors.clear();
    final rows = await catRepo.getAllCategories();
    for (final r in rows) {
      final name = r['name']?.toString() ?? '';
      final hex = r['color']?.toString() ?? '';
      if (name.isEmpty) continue;
      _categoryColors[name] =
          _parseHexColor(hex) ?? _categoryColors[name] ?? Colors.blueGrey;
    }
  }

  Color? _parseHexColor(String hex) {
    if (hex.isEmpty) return null;
    var value = hex.trim();
    if (value.startsWith('#')) value = value.substring(1);
    // Support RRGGBB or AARRGGBB
    if (value.length == 6) {
      value = 'FF$value';
    }
    if (value.length != 8) return null;
    final intVal = int.tryParse(value, radix: 16);
    if (intVal == null) return null;
    return Color(intVal);
  }
}
