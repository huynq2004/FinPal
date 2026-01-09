import 'package:finpal/domain/models/coach_message.dart';
import 'package:finpal/data/services/analytics_service.dart';
import 'package:finpal/data/repositories/budget_repository.dart';
import 'package:intl/intl.dart';

class AiCoachRepository {
  final AnalyticsService _analyticsService;
  final BudgetRepository _budgetRepository;

  AiCoachRepository(this._analyticsService, this._budgetRepository);

  /// Lấy insights dựa trên dữ liệu thực từ DB
  Future<List<CoachMessage>> getRealInsights() async {
    final messages = <CoachMessage>[];
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    try {
      // 1. Kiểm tra budget warnings
      final budgets = await _budgetRepository.getAllBudgets();
      for (final budget in budgets) {
        // Lấy chi tiêu cho category này trong tháng
        final spent = await _analyticsService.getExpenseByCategory(year, month, budget.categoryId);
        
        // Bỏ qua budget chưa có chi tiêu
        if (spent == 0) continue;
        
        final percentage = (spent / budget.limitAmount * 100).round();
        
        // Lấy tên category
        final categoryName = await _analyticsService.getCategoryNameById(budget.categoryId);
        
        if (percentage >= 90) {
          messages.add(CoachMessage(
            id: 'budget_warning_${budget.id}',
            title: 'Chi $categoryName gần chạm hạn mức!',
            description: 'Bạn đã chi $percentage% hạn mức "$categoryName" của tháng này (${currencyFormat.format(spent)}/${currencyFormat.format(budget.limitAmount)}). Hãy cẩn thận với chi tiêu!',
            type: CoachMessageType.warning,
          ));
        } else if (percentage >= 70) {
          messages.add(CoachMessage(
            id: 'budget_caution_${budget.id}',
            title: 'Chú ý chi tiêu $categoryName',
            description: 'Bạn đã chi $percentage% hạn mức "$categoryName" (${currencyFormat.format(spent)}/${currencyFormat.format(budget.limitAmount)}). Còn ${DateTime(year, month + 1, 0).day - now.day} ngày nữa là hết tháng.',
            type: CoachMessageType.warning,
          ));
        }
      }

      // 2. Phân tích top categories
      final topCategories = await _analyticsService.getTopExpenseCategories(year, month, limit: 3);
      for (final entry in topCategories.entries) {
        final categoryName = entry.key;
        final amount = entry.value;
        
        // Lấy chi tiêu trung bình hàng tuần
        final weeklyAvg = await _analyticsService.getWeeklyAverageExpenseByCategoryName(categoryName);
        
        if (weeklyAvg > 0 && amount > weeklyAvg * 4 * 1.3) { // Cao hơn 30% so với trung bình
          messages.add(CoachMessage(
            id: 'high_expense_$categoryName',
            title: 'Chi "$categoryName" tháng này cao hơn bình thường',
            description: 'Tháng này bạn chi ${currencyFormat.format(amount)} cho "$categoryName", cao hơn khoảng ${((amount / (weeklyAvg * 4) - 1) * 100).round()}% so với mức trung bình.',
            type: CoachMessageType.warning,
          ));
        }
      }

      // 3. Gợi ý tiết kiệm dựa trên weekly average
      if (topCategories.isNotEmpty) {
        final topCategory = topCategories.entries.first;
        final categoryName = topCategory.key;
        final weeklyAvg = await _analyticsService.getWeeklyAverageExpenseByCategoryName(categoryName);
        
        if (weeklyAvg > 100000) { // Chỉ gợi ý nếu chi trên 100k/tuần
          final potentialSavings = (weeklyAvg * 0.3 * 4).round(); // Tiết kiệm 30%
          messages.add(CoachMessage(
            id: 'saving_tip_$categoryName',
            title: 'Giảm "$categoryName" để tiết kiệm nhiều hơn',
            description: 'FinPal nhận thấy bạn chi trung bình ${currencyFormat.format(weeklyAvg.round())} cho "$categoryName" mỗi tuần. Nếu giảm 30%, bạn có thể tiết kiệm ${currencyFormat.format(potentialSavings)} mỗi tháng.',
            type: CoachMessageType.suggestion,
          ));
        }
      }

      // 4. Phân tích thu chi
      final totalExpense = await _analyticsService.getTotalExpense(year, month);
      final totalIncome = await _analyticsService.getTotalIncome(year, month);
      
      if (totalIncome > 0) {
        final surplus = totalIncome - totalExpense;
        
        if (surplus > 0) {
          messages.add(CoachMessage(
            id: 'surplus_advice',
            title: 'Tạo mục tiêu tiết kiệm mới',
            description: 'Bạn đang có khoảng dư ${currencyFormat.format(surplus)} tháng này. Hãy tạo mục tiêu tiết kiệm để đạt được ước mơ của bạn!',
            type: CoachMessageType.suggestion,
          ));
        } else if (surplus < 0) {
          messages.add(CoachMessage(
            id: 'deficit_warning',
            title: 'Chi tiêu vượt thu nhập!',
            description: 'Tháng này bạn đã chi nhiều hơn thu nhập ${currencyFormat.format(-surplus)}. Hãy xem xét điều chỉnh chi tiêu.',
            type: CoachMessageType.warning,
          ));
        }
      }

      // 5. So sánh với tháng trước
      final growthRate = await _analyticsService.getExpenseGrowthRate(year, month);
      if (growthRate > 20) {
        messages.add(CoachMessage(
          id: 'growth_warning',
          title: 'Chi tiêu tăng cao so với tháng trước',
          description: 'Chi tiêu tháng này tăng ${growthRate.round()}% so với tháng trước (${currencyFormat.format(totalExpense)}). Hãy kiểm tra lại các khoản chi!',
          type: CoachMessageType.warning,
        ));
      }

      // 6. Thông báo tổng quan nếu có dữ liệu
      if (totalExpense > 0) {
        messages.add(CoachMessage(
          id: 'monthly_summary',
          title: 'Tổng quan tháng này',
          description: 'Tháng này bạn đã chi ${currencyFormat.format(totalExpense)}${totalIncome > 0 ? " từ tổng thu nhập ${currencyFormat.format(totalIncome)}" : ""}. ${topCategories.isNotEmpty ? "Chi nhiều nhất cho \"${topCategories.keys.first}\"." : ""}',
          type: CoachMessageType.suggestion,
        ));
      }

      // Nếu không có dữ liệu, trả về message mặc định
      if (messages.isEmpty) {
        messages.add(const CoachMessage(
          id: 'welcome',
          title: 'Chào mừng đến với AI Coach',
          description: 'Hãy bắt đầu thêm giao dịch để FinPal có thể phân tích và đưa ra gợi ý phù hợp với bạn!',
          type: CoachMessageType.suggestion,
        ));
      }

      return messages;
    } catch (e) {
      print('❌ [AiCoachRepository] Lỗi getRealInsights: $e');
      // Fallback to welcome message on error
      return [
        const CoachMessage(
          id: 'error_fallback',
          title: 'Đang tải dữ liệu...',
          description: 'FinPal đang chuẩn bị phân tích chi tiêu của bạn. Vui lòng thử lại sau.',
          type: CoachMessageType.suggestion,
        ),
      ];
    }
  }

  /// Deprecated: Giữ lại để tương thích với code cũ
  @Deprecated('Use getRealInsights() instead')
  Future<List<CoachMessage>> getFakeMessages() async {
    return const [
      CoachMessage(
        id: '1',
        title: 'Chi ăn ngoài gần chạm hạn mức!',
        description:
            'Bạn đã chi 70% hạn mức "Ăn ngoài" của tháng này. Còn 10 ngày nữa là hết tháng.',
        type: CoachMessageType.warning,
      ),
      CoachMessage(
        id: '2',
        title: 'Giảm trà sữa để tiết kiệm nhiều hơn',
        description:
            'FinPal nhận thấy bạn chi trung bình 200.000₫ cho "Trà sữa" mỗi tuần. Nếu giảm còn 100.000₫, bạn có thể tiết kiệm 400.000₫ mỗi tháng.',
        type: CoachMessageType.suggestion,
      ),
      CoachMessage(
        id: '3',
        title: 'Tiền điện tháng này cao bất thường',
        description:
            'Hóa đơn tiền điện tháng này của bạn: 500.000₫. Cao hơn 30% so với mức trung bình 350.000₫.',
        type: CoachMessageType.warning,
      ),
      CoachMessage(
        id: '4',
        title: 'Tạo mục tiêu tiết kiệm mới',
        description:
            'Bạn đang có khoảng dư 4.300.000₫ tháng này. Hãy tạo mục tiêu tiết kiệm để đạt được ước mơ của bạn!',
        type: CoachMessageType.suggestion,
      ),
    ];
  }
}
