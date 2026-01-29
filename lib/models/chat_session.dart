import 'message.dart';

class ChatSession {
  final String id;
  final DateTime timestamp;
  final List<Message> messages;
  final String title;

  ChatSession({
    required this.id,
    required this.timestamp,
    required this.messages,
    required this.title,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'title': title,
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        messages: (json['messages'] as List)
            .map((m) => Message.fromJson(m))
            .toList(),
        title: json['title'],
      );

  String get preview {
    if (messages.isEmpty) return 'Empty chat';
    final firstUserMessage = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => messages.first,
    );
    return firstUserMessage.text.length > 60
        ? '${firstUserMessage.text.substring(0, 60)}...'
        : firstUserMessage.text;
  }
}
