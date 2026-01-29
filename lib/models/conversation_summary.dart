class ConversationSummary {
  final DateTime timestamp;
  final List<String> topicsDiscussed;
  final String userBehavior; // How user asked questions
  final String preferredDepth; // short/detailed/examples
  final Map<String, String> keyLearnings; // topic -> observation
  
  ConversationSummary({
    required this.timestamp,
    required this.topicsDiscussed,
    required this.userBehavior,
    required this.preferredDepth,
    required this.keyLearnings,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'topicsDiscussed': topicsDiscussed,
        'userBehavior': userBehavior,
        'preferredDepth': preferredDepth,
        'keyLearnings': keyLearnings,
      };

  factory ConversationSummary.fromJson(Map<String, dynamic> json) =>
      ConversationSummary(
        timestamp: DateTime.parse(json['timestamp']),
        topicsDiscussed: List<String>.from(json['topicsDiscussed'] ?? []),
        userBehavior: json['userBehavior'] ?? '',
        preferredDepth: json['preferredDepth'] ?? 'balanced',
        keyLearnings: Map<String, String>.from(json['keyLearnings'] ?? {}),
      );
}
