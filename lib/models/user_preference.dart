class UserPreference {
  String explanationStyle; // 'short', 'detailed', 'examples', 'balanced'
  List<String> frequentTopics;
  Map<String, int> topicFrequency;
  int totalInteractions;
  
  // Enhanced learning data
  Map<String, int> topicDifficulty; // topic -> difficulty level (1-5)
  List<String> strengthAreas; // Topics user is strong in
  List<String> weaknessAreas; // Topics user struggles with
  String communicationStyle; // How user asks questions
  bool likesExamples;
  bool likesStepByStep;
  DateTime? lastInteraction;

  UserPreference({
    this.explanationStyle = 'balanced',
    List<String>? frequentTopics,
    Map<String, int>? topicFrequency,
    this.totalInteractions = 0,
    Map<String, int>? topicDifficulty,
    List<String>? strengthAreas,
    List<String>? weaknessAreas,
    this.communicationStyle = 'casual',
    this.likesExamples = true,
    this.likesStepByStep = false,
    this.lastInteraction,
  })  : frequentTopics = frequentTopics ?? [],
        topicFrequency = topicFrequency ?? {},
        topicDifficulty = topicDifficulty ?? {},
        strengthAreas = strengthAreas ?? [],
        weaknessAreas = weaknessAreas ?? [];

  Map<String, dynamic> toJson() => {
        'explanationStyle': explanationStyle,
        'frequentTopics': frequentTopics,
        'topicFrequency': topicFrequency,
        'totalInteractions': totalInteractions,
        'topicDifficulty': topicDifficulty,
        'strengthAreas': strengthAreas,
        'weaknessAreas': weaknessAreas,
        'communicationStyle': communicationStyle,
        'likesExamples': likesExamples,
        'likesStepByStep': likesStepByStep,
        'lastInteraction': lastInteraction?.toIso8601String(),
      };

  factory UserPreference.fromJson(Map<String, dynamic> json) => UserPreference(
        explanationStyle: json['explanationStyle'] ?? 'balanced',
        frequentTopics: List<String>.from(json['frequentTopics'] ?? []),
        topicFrequency: Map<String, int>.from(json['topicFrequency'] ?? {}),
        totalInteractions: json['totalInteractions'] ?? 0,
        topicDifficulty: Map<String, int>.from(json['topicDifficulty'] ?? {}),
        strengthAreas: List<String>.from(json['strengthAreas'] ?? []),
        weaknessAreas: List<String>.from(json['weaknessAreas'] ?? []),
        communicationStyle: json['communicationStyle'] ?? 'casual',
        likesExamples: json['likesExamples'] ?? true,
        likesStepByStep: json['likesStepByStep'] ?? false,
        lastInteraction: json['lastInteraction'] != null 
            ? DateTime.parse(json['lastInteraction']) 
            : null,
      );

  void updateTopic(String topic) {
    topicFrequency[topic] = (topicFrequency[topic] ?? 0) + 1;
    if (!frequentTopics.contains(topic)) {
      frequentTopics.add(topic);
    }
    lastInteraction = DateTime.now();
  }

  void updateLearningPattern({
    String? style,
    bool? examples,
    bool? stepByStep,
    String? commStyle,
  }) {
    if (style != null) explanationStyle = style;
    if (examples != null) likesExamples = examples;
    if (stepByStep != null) likesStepByStep = stepByStep;
    if (commStyle != null) communicationStyle = commStyle;
  }

  void markStrength(String topic) {
    if (!strengthAreas.contains(topic)) {
      strengthAreas.add(topic);
    }
    weaknessAreas.remove(topic);
  }

  void markWeakness(String topic) {
    if (!weaknessAreas.contains(topic)) {
      weaknessAreas.add(topic);
    }
  }
}
