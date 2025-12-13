import 'package:finpal/domain/models/coach_message.dart';

class AiCoachRepository {
  Future<List<CoachMessage>> getFakeMessages() async {
    return [
      const CoachMessage(
        id: '1',
        title: 'Hạn mức ăn ngoài sắp vượt',
        description:
            'Bạn đã sử dụng 75% hạn mức ăn ngoài trong khi mới đi qua 50% tháng.',
        type: CoachMessageType.warning,
      ),
      const CoachMessage(
        id: '2',
        title: 'Gợi ý tiết kiệm',
        description:
            'Nếu giảm chi tiêu trà sữa xuống 100.000đ/tuần, bạn sẽ tiết kiệm được 400.000đ/tháng.',
        type: CoachMessageType.suggestion,
      ),
    ];
  }
}
