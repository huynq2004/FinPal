import 'package:finpal/domain/models/coach_message.dart';
import 'package:finpal/data/services/analytics_service.dart';
import 'package:finpal/data/repositories/budget_repository.dart';
import 'package:finpal/data/services/coach_engine.dart';

class AiCoachRepository {
  final AnalyticsService _analyticsService;
  final BudgetRepository _budgetRepository;
  late final CoachEngine _coachEngine;

  AiCoachRepository(this._analyticsService, this._budgetRepository) {
    _coachEngine = CoachEngine(_analyticsService, _budgetRepository);
  }

  /// Lấy insights dựa trên dữ liệu thực từ DB
  /// Uses CoachEngine for S3-C2 (budget warnings) and S4-C1 (savings suggestions)
  Future<List<CoachMessage>> getRealInsights() async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    try {
      // Use CoachEngine to generate all insights
      return await _coachEngine.generateAllInsights(year: year, month: month);
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
