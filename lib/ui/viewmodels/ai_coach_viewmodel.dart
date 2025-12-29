import 'package:flutter/foundation.dart';
import 'package:finpal/domain/models/coach_message.dart';
import 'package:finpal/data/repositories/ai_coach_repository.dart';

class AiCoachViewModel extends ChangeNotifier {
  final AiCoachRepository _repository;

  AiCoachViewModel(this._repository);

  List<CoachMessage> _messages = [];
  List<CoachMessage> get messages => _messages;

  /// Filter state for the list view.
  AiCoachFilter _filter = AiCoachFilter.all;
  AiCoachFilter get filter => _filter;

  List<CoachMessage> get filteredMessages {
    if (_filter == AiCoachFilter.all) return _messages;
    if (_filter == AiCoachFilter.warning) {
      return _messages
          .where((m) => m.type == CoachMessageType.warning)
          .toList();
    }
    if (_filter == AiCoachFilter.suggestion) {
      return _messages
          .where((m) => m.type == CoachMessageType.suggestion)
          .toList();
    }
    return _messages;
  }

  void setFilter(AiCoachFilter f) {
    _filter = f;
    notifyListeners();
  }

  Future<void> loadMessages() async {
    _messages = await _repository.getFakeMessages();
    notifyListeners();
  }
}

enum AiCoachFilter { all, warning, suggestion }
