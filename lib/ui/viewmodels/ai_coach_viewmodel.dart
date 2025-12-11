import 'package:flutter/foundation.dart';
import 'package:finpal/domain/models/coach_message.dart';
import 'package:finpal/data/repositories/ai_coach_repository.dart';

class AiCoachViewModel extends ChangeNotifier {
  final AiCoachRepository _repository;

  AiCoachViewModel(this._repository);

  List<CoachMessage> _messages = [];
  List<CoachMessage> get messages => _messages;

  Future<void> loadMessages() async {
    _messages = await _repository.getFakeMessages();
    notifyListeners();
  }
}
