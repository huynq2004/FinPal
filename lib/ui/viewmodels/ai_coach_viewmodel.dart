import 'package:flutter/foundation.dart';
import 'package:finpal/domain/models/coach_message.dart';
import 'package:finpal/data/repositories/ai_coach_repository.dart';
import 'package:finpal/data/services/analytics_service.dart';

class AiCoachViewModel extends ChangeNotifier {
  final AiCoachRepository _repository;
  final AnalyticsService? _analyticsService;

  AiCoachViewModel(this._repository, [this._analyticsService]);

  List<CoachMessage> _messages = [];
  List<CoachMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Filter state for the list view.
  AiCoachFilter _filter = AiCoachFilter.all;
  AiCoachFilter get filter => _filter;

  List<CoachMessage> get filteredMessages {
    if (_filter == AiCoachFilter.all) return _messages;
    if (_filter == AiCoachFilter.warning) {
      return _messages
          .where((m) => m.type == CoachMessageType.warning)
          .toList();
    }
    if (_filter == AiCoachFilter.suggestion) {
      return _messages
          .where((m) => m.type == CoachMessageType.suggestion)
          .toList();
    }
    return _messages;
  }

  void setFilter(AiCoachFilter f) {
    _filter = f;
    notifyListeners();
  }

  /// Load messages using real data from AnalyticsService
  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use real insights if available
      _messages = await _repository.getRealInsights();
      print('✅ [AiCoachViewModel] Loaded ${_messages.length} real insights');
    } catch (e) {
      print('❌ [AiCoachViewModel] Error loading insights: $e');
      // Fallback to fake messages on error
      _messages = await _repository.getFakeMessages();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load basic insights - shortcut method for quick stats
  Future<Map<String, dynamic>> loadBasicInsights() async {
    if (_analyticsService == null) {
      return {};
    }

    try {
      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      final totalExpense = await _analyticsService.getTotalExpense(year, month);
      final totalIncome = await _analyticsService.getTotalIncome(year, month);
      final topCategories = await _analyticsService.getTopExpenseCategories(year, month, limit: 3);

      print('📊 [AiCoachViewModel] Basic Insights:');
      print('   - Total Expense: $totalExpense');
      print('   - Total Income: $totalIncome');
      print('   - Top Categories: $topCategories');

      return {
        'totalExpense': totalExpense,
        'totalIncome': totalIncome,
        'surplus': totalIncome - totalExpense,
        'topCategories': topCategories,
      };
    } catch (e) {
      print('❌ [AiCoachViewModel] Error loading basic insights: $e');
      return {};
    }
  }
}

enum AiCoachFilter { all, warning, suggestion }
