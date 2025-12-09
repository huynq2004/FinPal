// lib/ui/screens/ai_coach_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finpal/ui/viewmodels/ai_coach_viewmodel.dart';
import 'package:finpal/domain/models/coach_message.dart';

class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  Color _getTypeColor(BuildContext context, CoachMessageType type) {
    switch (type) {
      case CoachMessageType.warning:
        return Colors.orange;
      case CoachMessageType.suggestion:
        return Colors.green;
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
      create: (_) => AiCoachViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Trợ lý tài chính')),
        body: Consumer<AiCoachViewModel>(
          builder: (context, vm, child) {
            if (vm.messages.isEmpty) {
              return const Center(child: Text('Chưa có gợi ý nào.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.messages.length,
              itemBuilder: (context, index) {
                final msg = vm.messages[index];
                final color = _getTypeColor(context, msg.type);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_getTypeIcon(msg.type), color: color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
