import 'package:finpal/domain/models/coach_message.dart';

class AiCoachRepository {
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
