// lib/ui/screens/notifications_center_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:finpal/ui/viewmodels/notifications_viewmodel.dart';
import 'package:finpal/domain/models/notification_item.dart';
import 'package:finpal/domain/models/ai_insight.dart';
import 'package:finpal/ui/screens/ai_insight_detail_screen.dart';

class NotificationsCenterScreen extends StatelessWidget {
  const NotificationsCenterScreen({super.key});

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.warning:
        return const Color(0xFFFF5A5F);
      case NotificationType.suggestion:
        return const Color(0xFF3E8AFF);
      case NotificationType.info:
        return const Color(0xFF2ECC71);
    }
  }

  Color _getBorderColor(NotificationType type) {
    switch (type) {
      case NotificationType.warning:
        return const Color(0xFFFFC9C9);
      case NotificationType.suggestion:
        return const Color(0xFFBEDBFF);
      case NotificationType.info:
        return const Color(0xFFB9F8CF);
    }
  }

  Color _getBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.warning:
        return const Color(0xFFFEF2F2);
      case NotificationType.suggestion:
        return const Color(0xFFEFF6FF);
      case NotificationType.info:
        return const Color(0xFFF0FDF4);
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.suggestion:
        return Icons.lightbulb_outline;
      case NotificationType.info:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = NotificationsViewModel();
        vm.loadNotifications();
        return vm;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Consumer<NotificationsViewModel>(
            builder: (context, vm, child) {
              return Column(
                children: [
                  // Header
                  _buildHeader(context, vm),

                  // Mark all as read button
                  _buildMarkAllButton(vm),

                  // Notifications list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      itemCount: vm.notifications.length + 1, // +1 for info banner
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == vm.notifications.length) {
                          return _buildInfoBanner();
                        }
                        
                        final notification = vm.notifications[index];
                        return _buildNotificationCard(context, notification, vm);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificationsViewModel vm) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3E8AFF),
            Color(0xFF325DFF),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Thông báo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
              if (vm.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5A5F),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${vm.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Cảnh báo và gợi ý từ FinPal',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkAllButton(NotificationsViewModel vm) {
    if (vm.unreadCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF3F4F6),
            width: 1.2,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: GestureDetector(
        onTap: vm.markAllAsRead,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF3E8AFF),
              size: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              'Đánh dấu tất cả là đã đọc',
              style: TextStyle(
                color: Color(0xFF3E8AFF),
                fontSize: 14,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationItem notification,
    NotificationsViewModel vm,
  ) {
    final color = _getTypeColor(notification.type);
    final borderColor = _getBorderColor(notification.type);
    final bgColor = _getBackgroundColor(notification.type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: [
          if (!notification.isRead)
            const BoxShadow(
              color: Color(0xFF3E8AFF),
              blurRadius: 0,
              spreadRadius: 2,
            ),
          const BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          const BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with unread indicator and close button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF5A5F),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => vm.dismissNotification(notification.id),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        notification.description,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          height: 1.625,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Timestamp and mark as read
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              height: 1.33,
                            ),
                          ),
                          if (!notification.isRead)
                            GestureDetector(
                              onTap: () => vm.markAsRead(notification.id),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFF3E8AFF),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Đánh dấu đã đọc',
                                    style: TextStyle(
                                      color: Color(0xFF3E8AFF),
                                      fontSize: 12,
                                      height: 1.33,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // View details button
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              border: Border(
                top: BorderSide(
                  color: Color(0xFFF3F4F6),
                  width: 1.2,
                ),
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // Navigate to detail screen
                  if (notification.relatedInsightId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AiInsightDetailScreen(
                          insight: AiInsight(
                            id: notification.relatedInsightId!,
                            title: notification.title,
                            description: notification.description,
                            type: notification.type == NotificationType.warning
                                ? InsightType.warning
                                : notification.type == NotificationType.suggestion
                                    ? InsightType.suggestion
                                    : InsightType.info,
                            categoryName: 'Ăn uống',
                            spentAmount: 3500000,
                            limitAmount: 5000000,
                            daysRemaining: 10,
                            avgDailySpending: 350000,
                            maxDailySpending: 150000,
                          ),
                          recentTransactions: const [],
                        ),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        color: Color(0xFF3E8AFF),
                        fontSize: 14,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Transform.rotate(
                      angle: 3.14159, // 180 degrees in radians
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF3E8AFF),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(
          color: const Color(0xFFDBEAFE),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.settings_outlined,
            color: Color(0xFF3E8AFF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tùy chỉnh thông báo',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bạn có thể bật/tắt từng loại thông báo trong phần Cài đặt.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                  child: const Text(
                    'Đi tới Cài đặt →',
                    style: TextStyle(
                      color: Color(0xFF3E8AFF),
                      fontSize: 12,
                      height: 1.33,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      final formatter = DateFormat('HH:mm', 'vi_VN');
      return 'Hôm nay, ${formatter.format(timestamp)}';
    } else if (diff.inDays == 1) {
      final formatter = DateFormat('HH:mm', 'vi_VN');
      return 'Hôm qua, ${formatter.format(timestamp)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks tuần trước';
    } else {
      final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
      return formatter.format(timestamp);
    }
  }
}
