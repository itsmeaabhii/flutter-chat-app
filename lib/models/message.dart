import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

class Message extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;
  final MessageStatus? status;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
    this.status,
    this.metadata,
  });

  Message copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isTyping,
    MessageStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'isTyping': isTyping,
        if (status != null) 'status': status!.name,
        if (metadata != null) 'metadata': metadata,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] ?? '',
        text: json['text'] ?? '',
        isUser: json['isUser'] ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        isTyping: json['isTyping'] ?? false,
        status: json['status'] != null
            ? MessageStatus.values.firstWhere(
                (e) => e.name == json['status'],
                orElse: () => MessageStatus.sent,
              )
            : null,
        metadata: json['metadata'],
      );

  @override
  List<Object?> get props => [id, text, isUser, timestamp, isTyping, status, metadata];
}
