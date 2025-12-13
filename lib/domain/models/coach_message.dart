enum CoachMessageType { warning, suggestion, info }

class CoachMessage {
  final String id;
  final String title;
  final String description;
  final CoachMessageType type;

  const CoachMessage({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
  });
}
