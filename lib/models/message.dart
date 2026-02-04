import 'package:equatable/equatable.dart';

enum MessageStatus { sending, sent, delivered, read, failed }

class MessageAttachment {
  final String name;
  final String path;
  final String type; // 'image', 'document', 'video', 'audio', 'other'
  final int size; // in bytes

  const MessageAttachment({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'type': type,
        'size': size,
      };

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      MessageAttachment(
        name: json['name'] ?? '',
        path: json['path'] ?? '',
        type: json['type'] ?? 'other',
        size: json['size'] ?? 0,
      );

  String get sizeInMB => (size / (1024 * 1024)).toStringAsFixed(2);
}

class Message extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;
  final MessageStatus? status;
  final Map<String, dynamic>? metadata;
  final List<MessageAttachment>? attachments;

  const Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
    this.status,
    this.metadata,
    this.attachments,
  });

  Message copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isTyping,
    MessageStatus? status,
    Map<String, dynamic>? metadata,
    List<MessageAttachment>? attachments,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      attachments: attachments ?? this.attachments,
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
        if (attachments != null)
          'attachments': attachments!.map((a) => a.toJson()).toList(),
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
        attachments: json['attachments'] != null
            ? (json['attachments'] as List)
                .map((a) => MessageAttachment.fromJson(a))
                .toList()
            : null,
      );

  @override
  List<Object?> get props =>
      [id, text, isUser, timestamp, isTyping, status, metadata, attachments];
}
