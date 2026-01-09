// lib/data/services/coach_engine.dart

import 'package:finpal/domain/models/coach_message.dart';
import 'package:finpal/data/services/analytics_service.dart';
import 'package:finpal/data/repositories/budget_repository.dart';
import 'package:intl/intl.dart';

/// CoachEngine - Logic engine for generating AI coaching insights
class CoachEngine {
  final AnalyticsService _analyticsService;
  final BudgetRepository _budgetRepository;

  CoachEngine(this._analyticsService, this._budgetRepository);

  /// S3-C2: Generate budget limit warnings (70% threshold)
  /// Returns warnings when spending exceeds 70% or 90% of budget limit
  Future<List<CoachMessage>> generateBudgetWarnings({
    required int year,
    required int month,
  }) async {
    final messages = <CoachMessage>[];
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final now = DateTime.now();

    try {
      final budgets = await _budgetRepository.getAllBudgets();
      
      for (final budget in budgets) {
        // Skip if budget is not for current month
        if (budget.year != year || budget.month != month) continue;

        // Calculate spent amount for this category
        final spent = await _analyticsService.getExpenseByCategory(year, month, budget.categoryId);
        
        // Skip if no spending yet
        if (spent == 0) continue;
        
        // Calculate percentage
        final percentage = (spent / budget.limitAmount * 100).round();
        
        // Get category name
        final categoryName = await _analyticsService.getCategoryNameById(budget.categoryId);
        
        // Generate warning based on threshold
        if (percentage >= 90) {
          // Critical warning - 90%+
          messages.add(CoachMessage(
            id: 'budget_critical_${budget.id}',
            title: '⚠️ Chi "$categoryName" gần chạm hạn mức!',
            description: 'Bạn đã chi $percentage% hạn mức "$categoryName" của tháng này (${currencyFormat.format(spent)}/${currencyFormat.format(budget.limitAmount)}). Hãy cẩn thận với chi tiêu!',
            type: CoachMessageType.warning,
          ));
        } else if (percentage >= 70) {
          // Caution warning - 70-89%
          final daysRemaining = DateTime(year, month + 1, 0).day - now.day;
          messages.add(CoachMessage(
            id: 'budget_caution_${budget.id}',
            title: '📊 Chú ý chi tiêu "$categoryName"',
            description: 'Bạn đã chi $percentage% hạn mức "$categoryName" (${currencyFormat.format(spent)}/${currencyFormat.format(budget.limitAmount)}). Còn $daysRemaining ngày nữa là hết tháng.',
            type: CoachMessageType.warning,
          ));
        }
      }

      print('💡 [CoachEngine] Generated ${messages.length} budget warnings');
    } catch (e) {
      print('❌ [CoachEngine] Error generating budget warnings: $e');
    }

    return messages;
  }

  /// S4-C1: Generate savings suggestions based on spending habits
  /// Analyzes weekly average spending and suggests reduction opportunities
  Future<List<CoachMessage>> generateSavingsSuggestions({
    required int year,
    required int month,
    int minWeeklySpending = 100000, // Only suggest for categories spending >100k/week
    double reductionPercent = 0.3, // Suggest 30% reduction
  }) async {
    final messages = <CoachMessage>[];
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    try {
      // Get top spending categories
      final topCategories = await _analyticsService.getTopExpenseCategories(year, month, limit: 5);
      
      for (final entry in topCategories.entries) {
        final categoryName = entry.key;
        
        // Calculate weekly average for this category
        final weeklyAvg = await _analyticsService.getWeeklyAverageExpenseByCategoryName(categoryName);
        
        // Only suggest if weekly spending is significant
        if (weeklyAvg < minWeeklySpending) continue;
        
        // Calculate potential savings
        final monthlySavings = (weeklyAvg * reductionPercent * 4).round();
        final newWeeklyAmount = (weeklyAvg * (1 - reductionPercent)).round();
        
        // Generate suggestion
        messages.add(CoachMessage(
          id: 'savings_tip_$categoryName',
          title: '💡 Giảm "$categoryName" để tiết kiệm nhiều hơn',
          description: 'FinPal nhận thấy bạn chi trung bình ${currencyFormat.format(weeklyAvg.round())} cho "$categoryName" mỗi tuần. '
              'Nếu giảm ${(reductionPercent * 100).round()}% (còn ${currencyFormat.format(newWeeklyAmount)}), '
              'bạn có thể tiết kiệm ${currencyFormat.format(monthlySavings)} mỗi tháng.',
          type: CoachMessageType.suggestion,
        ));
      }

      print('💡 [CoachEngine] Generated ${messages.length} savings suggestions');
    } catch (e) {
      print('❌ [CoachEngine] Error generating savings suggestions: $e');
    }

    return messages;
  }

  /// Generate high spending alerts (spending 30% above average)
  Future<List<CoachMessage>> generateHighSpendingAlerts({
    required int year,
    required int month,
  }) async {
    final messages = <CoachMessage>[];
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    try {
      final topCategories = await _analyticsService.getTopExpenseCategories(year, month, limit: 3);
      
      for (final entry in topCategories.entries) {
        final categoryName = entry.key;
        final amount = entry.value;
        
        // Get weekly average
        final weeklyAvg = await _analyticsService.getWeeklyAverageExpenseByCategoryName(categoryName);
        
        // Check if spending is 30% above average
        if (weeklyAvg > 0 && amount > weeklyAvg * 4 * 1.3) {
          final increasePercent = ((amount / (weeklyAvg * 4) - 1) * 100).round();
          
          messages.add(CoachMessage(
            id: 'high_expense_$categoryName',
            title: '📈 Chi "$categoryName" tháng này cao hơn bình thường',
            description: 'Tháng này bạn chi ${currencyFormat.format(amount)} cho "$categoryName", '
                'cao hơn khoảng $increasePercent% so với mức trung bình.',
            type: CoachMessageType.warning,
          ));
        }
      }

      print('💡 [CoachEngine] Generated ${messages.length} high spending alerts');
    } catch (e) {
      print('❌ [CoachEngine] Error generating high spending alerts: $e');
    }

    return messages;
  }

  /// Generate surplus/deficit alerts
  Future<List<CoachMessage>> generateBalanceAlerts({
    required int year,
    required int month,
  }) async {
    final messages = <CoachMessage>[];
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    try {
      final totalExpense = await _analyticsService.getTotalExpense(year, month);
      final totalIncome = await _analyticsService.getTotalIncome(year, month);
      
      if (totalIncome > 0) {
        final surplus = totalIncome - totalExpense;
        
        if (surplus > 0) {
          messages.add(CoachMessage(
            id: 'surplus_advice',
            title: '🎯 Tạo mục tiêu tiết kiệm mới',
            description: 'Bạn đang có khoảng dư ${currencyFormat.format(surplus)} tháng này. '
                'Hãy tạo mục tiêu tiết kiệm để đạt được ước mơ của bạn!',
            type: CoachMessageType.suggestion,
          ));
        } else if (surplus < 0) {
          messages.add(CoachMessage(
            id: 'deficit_warning',
            title: '⚠️ Chi tiêu vượt thu nhập!',
            description: 'Tháng này bạn đã chi nhiều hơn thu nhập ${currencyFormat.format(-surplus)}. '
                'Hãy xem xét điều chỉnh chi tiêu.',
            type: CoachMessageType.warning,
          ));
        }
      }

      print('💡 [CoachEngine] Generated ${messages.length} balance alerts');
    } catch (e) {
      print('❌ [CoachEngine] Error generating balance alerts: $e');
    }

    return messages;
  }

  /// Generate growth rate warnings
  Future<List<CoachMessage>> generateGrowthWarnings({
    required int year,
    required int month,
  }) async {
    final messages = <CoachMessage>[];
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    try {
      final growthRate = await _analyticsService.getExpenseGrowthRate(year, month);
      final totalExpense = await _analyticsService.getTotalExpense(year, month);
      
      if (growthRate > 20) {
        messages.add(CoachMessage(
          id: 'growth_warning',
          title: '📊 Chi tiêu tăng cao so với tháng trước',
          description: 'Chi tiêu tháng này tăng ${growthRate.round()}% so với tháng trước '
              '(${currencyFormat.format(totalExpense)}). Hãy kiểm tra lại các khoản chi!',
          type: CoachMessageType.warning,
        ));
      }

      print('💡 [CoachEngine] Generated ${messages.length} growth warnings');
    } catch (e) {
      print('❌ [CoachEngine] Error generating growth warnings: $e');
    }

    return messages;
  }

  /// S4-C2: Detect recurring bill anomalies
  /// Compares current month bill expenses with 3-month average
  Future<List<CoachMessage>> generateRecurringBillAnomalies({
    required int year,
    required int month,
  }) async {
    final messages = <CoachMessage>[];
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    try {
      // Bill categories (recurring expenses)
      final billCategoryNames = ['Hóa đơn', 'Điện nước', 'Internet', 'Thuê nhà', 'Điện thoại'];
      
      for (final categoryName in billCategoryNames) {
        // Get current month expense
        final currentExpense = await _analyticsService.getExpenseByCategoryName(year, month, categoryName);
        
        // Skip if no expense this month
        if (currentExpense == 0) continue;
        
        // Calculate 3-month average (current month - 1, -2, -3)
        var totalPast3Months = 0;
        var monthsWithData = 0;
        
        for (var i = 1; i <= 3; i++) {
          final pastDate = DateTime(year, month).subtract(Duration(days: 30 * i));
          final pastYear = pastDate.year;
          final pastMonth = pastDate.month;
          
          final pastExpense = await _analyticsService.getExpenseByCategoryName(pastYear, pastMonth, categoryName);
          if (pastExpense > 0) {
            totalPast3Months += pastExpense;
            monthsWithData++;
          }
        }
        
        // Need at least 2 months of historical data to detect anomaly
        if (monthsWithData < 2) continue;
        
        final averagePast3Months = (totalPast3Months / monthsWithData).round();
        
        // Skip if average is too small (< 50k) to avoid false positives
        if (averagePast3Months < 50000) continue;
        
        // Calculate difference percentage
        final difference = currentExpense - averagePast3Months;
        final differencePercent = ((difference / averagePast3Months) * 100).abs().round();
        
        // Generate alert if difference is significant (> 30%)
        if (differencePercent > 30) {
          if (currentExpense > averagePast3Months) {
            // Bill higher than usual
            messages.add(CoachMessage(
              id: 'bill_anomaly_high_$categoryName',
              title: '🔔 Chi "$categoryName" tăng bất thường',
              description: 'Chi "$categoryName" tháng này là ${currencyFormat.format(currentExpense)}, '
                  'cao hơn $differencePercent% so với trung bình 3 tháng trước '
                  '(${currencyFormat.format(averagePast3Months)}). Hãy kiểm tra lại hóa đơn!',
              type: CoachMessageType.warning,
            ));
          } else {
            // Bill lower than usual (could be good news or missing data)
            messages.add(CoachMessage(
              id: 'bill_anomaly_low_$categoryName',
              title: '💡 Chi "$categoryName" thấp hơn bình thường',
              description: 'Chi "$categoryName" tháng này là ${currencyFormat.format(currentExpense)}, '
                  'thấp hơn $differencePercent% so với trung bình 3 tháng trước '
                  '(${currencyFormat.format(averagePast3Months)}). Tuyệt vời nếu bạn đã tiết kiệm được!',
              type: CoachMessageType.info,
            ));
          }
        }
      }

      print('💡 [CoachEngine] Generated ${messages.length} recurring bill anomaly alerts');
    } catch (e) {
      print('❌ [CoachEngine] Error generating recurring bill anomalies: $e');
    }

    return messages;
  }

  /// Generate monthly summary
  Future<List<CoachMessage>> generateMonthlySummary({
    required int year,
    required int month,
  }) async {
    final messages = <CoachMessage>[];
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    try {
      final totalExpense = await _analyticsService.getTotalExpense(year, month);
      
      if (totalExpense > 0) {
        final totalIncome = await _analyticsService.getTotalIncome(year, month);
        final topCategories = await _analyticsService.getTopExpenseCategories(year, month, limit: 1);
        
        final summaryText = StringBuffer();
        summaryText.write('Tháng này bạn đã chi ${currencyFormat.format(totalExpense)}');
        
        if (totalIncome > 0) {
          summaryText.write(' từ tổng thu nhập ${currencyFormat.format(totalIncome)}');
        }
        
        if (topCategories.isNotEmpty) {
          summaryText.write('. Chi nhiều nhất cho "${topCategories.keys.first}"');
        }
        
        summaryText.write('.');
        
        messages.add(CoachMessage(
          id: 'monthly_summary',
          title: '📊 Tổng quan tháng này',
          description: summaryText.toString(),
          type: CoachMessageType.suggestion,
        ));
      }

      print('💡 [CoachEngine] Generated monthly summary');
    } catch (e) {
      print('❌ [CoachEngine] Error generating monthly summary: $e');
    }

    return messages;
  }

  /// Generate all insights (combines all engines)
  Future<List<CoachMessage>> generateAllInsights({
    required int year,
    required int month,
  }) async {
    final allMessages = <CoachMessage>[];

    // Priority 1: Budget warnings (most critical)
    final budgetWarnings = await generateBudgetWarnings(year: year, month: month);
    allMessages.addAll(budgetWarnings);

    // Priority 2: High spending alerts
    final highSpendingAlerts = await generateHighSpendingAlerts(year: year, month: month);
    allMessages.addAll(highSpendingAlerts);

    // Priority 3: Recurring bill anomalies (S4-C2)
    final billAnomalies = await generateRecurringBillAnomalies(year: year, month: month);
    allMessages.addAll(billAnomalies);

    // Priority 4: Savings suggestions
    final savingsSuggestions = await generateSavingsSuggestions(year: year, month: month);
    allMessages.addAll(savingsSuggestions);

    // Priority 5: Balance alerts
    final balanceAlerts = await generateBalanceAlerts(year: year, month: month);
    allMessages.addAll(balanceAlerts);

    // Priority 6: Growth warnings
    final growthWarnings = await generateGrowthWarnings(year: year, month: month);
    allMessages.addAll(growthWarnings);

    // Priority 7: Monthly summary
    final summary = await generateMonthlySummary(year: year, month: month);
    allMessages.addAll(summary);

    // If no messages, return welcome message
    if (allMessages.isEmpty) {
      allMessages.add(const CoachMessage(
        id: 'welcome',
        title: 'Chào mừng đến với AI Coach',
        description: 'Hãy bắt đầu thêm giao dịch để FinPal có thể phân tích và đưa ra gợi ý phù hợp với bạn!',
        type: CoachMessageType.suggestion,
      ));
    }

    print('✅ [CoachEngine] Generated ${allMessages.length} total insights');
    return allMessages;
  }
}
