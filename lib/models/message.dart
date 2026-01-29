class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        text: json['text'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
