// lib/ui/screens/ai_coach_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finpal/ui/viewmodels/ai_coach_viewmodel.dart';
import 'package:finpal/domain/models/coach_message.dart';
import 'package:finpal/domain/models/ai_insight.dart';
import 'package:finpal/data/repositories/ai_coach_repository.dart';
import 'package:finpal/data/repositories/transaction_repository.dart';
import 'package:finpal/data/repositories/budget_repository.dart';
import 'package:finpal/data/services/analytics_service.dart';
import 'package:finpal/data/db/database_provider.dart';
import 'package:finpal/ui/screens/ai_insight_detail_screen.dart';

class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  Color _getTypeColor(CoachMessageType type) {
    switch (type) {
      case CoachMessageType.warning:
        return const Color(0xFFFF5A5F); // pinkish
      case CoachMessageType.suggestion:
        return const Color(0xFF3E8AFF); // blue
      case CoachMessageType.info:
        return const Color(0xFF2ECC71); // green
    }
  }

  IconData _getTypeIcon(CoachMessageType type) {
    switch (type) {
      case CoachMessageType.warning:
        return Icons.warning_amber_rounded;
      case CoachMessageType.suggestion:
        return Icons.lightbulb_outline;
      case CoachMessageType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        // Initialize real dependencies
        final dbProvider = DatabaseProvider.instance;
        final transactionRepo = TransactionRepository(dbProvider);
        final budgetRepo = BudgetRepository(dbProvider);
        final analyticsService = AnalyticsService(transactionRepo);
        final repository = AiCoachRepository(analyticsService, budgetRepo);
        
        final vm = AiCoachViewModel(repository, analyticsService);
        vm.loadMessages();
        
        // Log basic insights to console
        vm.loadBasicInsights().then((insights) {
          print('📊 [AiCoachScreen] Loaded basic insights: $insights');
        });
        
        return vm;
      },
      child: Scaffold(
        // no default appbar; design uses custom header
        body: SafeArea(
          child: Consumer<AiCoachViewModel>(
            builder: (context, vm, child) {
              return Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3E8AFF), Color(0xFF325DFF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.psychology_alt_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Trợ lý tài chính AI',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Phân tích thói quen chi tiêu và đưa ra gợi ý thông minh',
                          style: TextStyle(color: Color(0xE6FFFFFF)),
                        ),
                      ],
                    ),
                  ),

                  // Segment control
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        _SegmentButton(
                          label: 'Tất cả',
                          selected: vm.filter == AiCoachFilter.all,
                          onTap: () => vm.setFilter(AiCoachFilter.all),
                        ),
                        const SizedBox(width: 12),
                        _SegmentButton(
                          label: 'Cảnh báo',
                          selected: vm.filter == AiCoachFilter.warning,
                          onTap: () => vm.setFilter(AiCoachFilter.warning),
                        ),
                        const SizedBox(width: 12),
                        _SegmentButton(
                          label: 'Gợi ý',
                          selected: vm.filter == AiCoachFilter.suggestion,
                          onTap: () => vm.setFilter(AiCoachFilter.suggestion),
                        ),
                      ],
                    ),
                  ),

                  // List with info banner at bottom
                  Expanded(
                    child: vm.filteredMessages.isEmpty
                        ? const Center(child: Text('Không có gợi ý phù hợp.'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: vm.filteredMessages.length + 1, // +1 for info banner
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              // Info banner at the end
                              if (index == vm.filteredMessages.length) {
                                return const _InfoBanner();
                              }
                              
                              final msg = vm.filteredMessages[index];
                              final color = _getTypeColor(msg.type);
                              return _CoachCard(
                                message: msg,
                                accentColor: color,
                                iconData: _getTypeIcon(msg.type),
                                onViewDetails: () {
                                  // Navigate to detail screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AiInsightDetailScreen(
                                        insight: AiInsight(
                                          id: msg.id,
                                          title: msg.title,
                                          description: msg.description,
                                          type: msg.type == CoachMessageType.warning
                                              ? InsightType.warning
                                              : msg.type == CoachMessageType.suggestion
                                                  ? InsightType.suggestion
                                                  : InsightType.info,
                                          categoryName: 'Ăn uống',
                                          spentAmount: 3500000,
                                          limitAmount: 5000000,
                                          daysRemaining: 10,
                                          avgDailySpending: 350000,
                                          maxDailySpending: 150000,
                                          savingTips: const [
                                            SavingTip(
                                              id: '1',
                                              title: 'Giảm ăn ngoài',
                                              description: 'Mang cơm trưa 3 ngày/tuần',
                                              savingsAmount: 450000,
                                            ),
                                            SavingTip(
                                              id: '2',
                                              title: 'Hạn chế cafe',
                                              description: 'Từ 5 lần → 2 lần/tuần',
                                              savingsAmount: 360000,
                                            ),
                                          ],
                                        ),
                                        recentTransactions: const [],
                                      ),
                                    ),
                                  );
                                },
                              );
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
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF3E8AFF) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final CoachMessage message;
  final Color accentColor;
  final IconData iconData;
  final VoidCallback onViewDetails;

  const _CoachCard({
    required this.message,
    required this.accentColor,
    required this.iconData,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBorderColor(message.type), 
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: -1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(message.type),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: accentColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.title,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message.description,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          height: 1.625,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFF3F4F6),
                    width: 1.2,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(message.type),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _getTypeLabel(message.type),
                      style: TextStyle(
                        color: accentColor, 
                        fontSize: 12,
                        height: 1.33,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onViewDetails,
                    child: const Row(
                      children: [
                        Text(
                          'Xem chi tiết',
                          style: TextStyle(
                            color: Color(0xFF3E8AFF),
                            fontSize: 14,
                            height: 1.43,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          color: Color(0xFF3E8AFF),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor(CoachMessageType type) {
    switch (type) {
      case CoachMessageType.warning:
        return const Color(0xFFFFC9C9);
      case CoachMessageType.suggestion:
        return const Color(0xFFBEDBFF);
      case CoachMessageType.info:
        return const Color(0xFFB9F8CF);
    }
  }

  Color _getBackgroundColor(CoachMessageType type) {
    switch (type) {
      case CoachMessageType.warning:
        return const Color(0xFFFEF2F2);
      case CoachMessageType.suggestion:
        return const Color(0xFFEFF6FF);
      case CoachMessageType.info:
        return const Color(0xFFF0FDF4);
    }
  }

  String _getTypeLabel(CoachMessageType type) {
    switch (type) {
      case CoachMessageType.warning:
        return 'Cảnh báo';
      case CoachMessageType.suggestion:
        return 'Gợi ý tiết kiệm';
      case CoachMessageType.info:
        return 'Thông tin';
    }
  }
}

/// Info banner component shown at bottom of list
class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFF3E8FF),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAF5FF), // #faf5ff
            Color(0xFFEFF6FF), // #eff6ff
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: Color(0xFF8B5CF6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Coach học từ thói quen của bạn',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Càng sử dụng lâu, gợi ý càng chính xác và phù hợp với bạn hơn.',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
