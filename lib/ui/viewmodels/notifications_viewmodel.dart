// lib/ui/viewmodels/notifications_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:finpal/domain/models/notification_item.dart';

class NotificationsViewModel extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  
  List<NotificationItem> get notifications => _notifications;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void loadNotifications() {
    // Sample data - in production, fetch from repository
    _notifications = [
      NotificationItem(
        id: '1',
        title: 'Chi ăn ngoài gần chạm hạn mức!',
        description: 'Bạn đã chi 70% hạn mức "Ăn ngoài" của tháng này.',
        type: NotificationType.warning,
        timestamp: DateTime.now().subtract(const Duration(hours: 9, minutes: 30)),
        isRead: false,
        relatedInsightId: 'insight1',
      ),
      NotificationItem(
        id: '2',
        title: 'Giảm trà sữa để tiết kiệm nhiều hơn',
        description: 'Nếu giảm chi trà sữa còn 100.000₫/tuần, bạn có thể tiết kiệm 400.000₫ mỗi tháng.',
        type: NotificationType.suggestion,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 15)),
        isRead: false,
        relatedInsightId: 'insight2',
      ),
      NotificationItem(
        id: '3',
        title: 'Tiền điện tháng này cao bất thường',
        description: 'Hóa đơn tiền điện: 500.000₫. Cao hơn 30% so với mức trung bình.',
        type: NotificationType.warning,
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        isRead: true,
        relatedInsightId: 'insight3',
      ),
      NotificationItem(
        id: '4',
        title: 'Bạn đang tiết kiệm tốt tháng này!',
        description: 'Bạn đã tiết kiệm được 4.300.000₫ trong tháng 11. Tuyệt vời!',
        type: NotificationType.info,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        relatedInsightId: 'insight4',
      ),
      NotificationItem(
        id: '5',
        title: 'Tạo mục tiêu tiết kiệm mới',
        description: 'Bạn đang có khoảng dư. Hãy tạo mục tiêu tiết kiệm!',
        type: NotificationType.suggestion,
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        isRead: true,
        relatedInsightId: 'insight5',
      ),
    ];
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void dismissNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }
}
