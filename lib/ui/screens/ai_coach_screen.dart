// lib/ui/screens/ai_coach_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finpal/ui/viewmodels/ai_coach_viewmodel.dart';
import 'package:finpal/domain/models/coach_message.dart';
import 'package:finpal/data/repositories/ai_coach_repository.dart';

class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  Color _getTypeColor(CoachMessageType type) {
    switch (type) {
      case CoachMessageType.warning:
        return const Color(0xFFFF5A5F); // pinkish
      case CoachMessageType.suggestion:
        return const Color(0xFF3E8AFF); // blue
      case CoachMessageType.info:
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getTypeIcon(CoachMessageType type) {
    switch (type) {
      case CoachMessageType.warning:
        return Icons.warning_amber_rounded;
      case CoachMessageType.suggestion:
        return Icons.lightbulb_outline;
      case CoachMessageType.info:
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = AiCoachViewModel(AiCoachRepository());
        vm.loadMessages();
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

                  // List
                  Expanded(
                    child: vm.filteredMessages.isEmpty
                        ? const Center(child: Text('Không có gợi ý phù hợp.'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: vm.filteredMessages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final msg = vm.filteredMessages[index];
                              final color = _getTypeColor(msg.type);
                              return _CoachCard(
                                message: msg,
                                accentColor: color,
                                iconData: _getTypeIcon(msg.type),
                                onViewDetails: () {
                                  // placeholder: navigate to details or show modal
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Xem chi tiết: ${msg.title}',
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withOpacity(0.18), width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
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
                    color: accentColor.withOpacity(0.12),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: const Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message.description,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    message.type == CoachMessageType.warning
                        ? 'Cảnh báo'
                        : 'Gợi ý tiết kiệm',
                    style: TextStyle(color: accentColor, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: onViewDetails,
                  child: const Row(
                    children: [
                      Text('Xem chi tiết'),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
