import 'package:flutter/foundation.dart';
import 'package:finpal/domain/models/coach_message.dart';

class AiCoachViewModel extends ChangeNotifier {
  List<CoachMessage> _messages = [];

  List<CoachMessage> get messages => _messages;

  AiCoachViewModel() {
    _loadDummyMessages();
  }

  void _loadDummyMessages() {
    _messages = [
      const CoachMessage(
        id: '1',
        title: 'Hạn mức Ăn ngoài sắp vượt',
        description:
            'Bạn đã dùng 75% hạn mức "Ăn ngoài" trong khi mới qua 50% thời gian của tháng.',
        type: CoachMessageType.warning,
      ),
      const CoachMessage(
        id: '2',
        title: 'Gợi ý tiết kiệm trà sữa',
        description:
            'Trung bình mỗi tuần bạn chi 200.000đ cho trà sữa. Nếu giảm còn 100.000đ, mỗi tháng bạn tiết kiệm ~400.000đ.',
        type: CoachMessageType.suggestion,
      ),
      const CoachMessage(
        id: '3',
        title: 'Thông tin tổng quan',
        description:
            'Tháng này bạn chi ít hơn tháng trước 10%. Tiếp tục duy trì nhé!',
        type: CoachMessageType.info,
      ),
    ];

    notifyListeners();
  }
}
