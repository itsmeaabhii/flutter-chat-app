import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preference.dart';
import '../models/conversation_summary.dart';

class PreferenceService {
  static SharedPreferences? _prefs;
  static UserPreference? _userPref;
  static const int maxSummaries = 10; // Keep last 10 conversation summaries

  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPreferences();
    return _prefs!;
  }

  static void _loadPreferences() {
    final prefString = _prefs?.getString('user_preferences');
    if (prefString != null) {
      _userPref = UserPreference.fromJson(jsonDecode(prefString));
    } else {
      _userPref = UserPreference();
    }
  }

  static Future<void> savePreferences(UserPreference pref) async {
    _userPref = pref;
    await _prefs?.setString('user_preferences', jsonEncode(pref.toJson()));
  }

  static UserPreference getUserPreferences() {
    return _userPref ?? UserPreference();
  }

  static Future<void> updateInteraction(String topic) async {
    final pref = getUserPreferences();
    pref.updateTopic(topic);
    pref.totalInteractions++;
    await savePreferences(pref);
  }

  static Future<void> updateExplanationStyle(String style) async {
    final pref = getUserPreferences();
    pref.explanationStyle = style;
    await savePreferences(pref);
  }

  // API Key Management
  static Future<void> saveApiKey(String apiKey) async {
    await _prefs?.setString('openai_api_key', apiKey);
  }

  static String? getApiKey() {
    return _prefs?.getString('openai_api_key');
  }

  static bool hasApiKey() {
    return getApiKey()?.isNotEmpty ?? false;
  }

  // Dark Mode Management
  static Future<void> setDarkMode(bool isDark) async {
    await _prefs?.setBool('dark_mode', isDark);
  }

  static bool getDarkMode() {
    return _prefs?.getBool('dark_mode') ?? false;
  }

  // Font Size Management
  static Future<void> setFontSize(double size) async {
    await _prefs?.setDouble('font_size', size);
  }

  static double getFontSize() {
    return _prefs?.getDouble('font_size') ?? 1.0; // Default scale 1.0
  }

  // Language Management
  static Future<void> setLanguage(String languageCode) async {
    await _prefs?.setString('language', languageCode);
  }

  static String getLanguage() {
    return _prefs?.getString('language') ?? 'en'; // Default English
  }

  // Conversation Summary Storage
  static Future<void> saveConversationSummary(ConversationSummary summary) async {
    final summaries = getConversationSummaries();
    summaries.add(summary);
    
    // Keep only recent summaries
    if (summaries.length > maxSummaries) {
      summaries.removeRange(0, summaries.length - maxSummaries);
    }
    
    final summariesJson = summaries.map((s) => s.toJson()).toList();
    await _prefs?.setString('conversation_summaries', jsonEncode(summariesJson));
  }

  static List<ConversationSummary> getConversationSummaries() {
    final summariesString = _prefs?.getString('conversation_summaries');
    if (summariesString == null) return [];
    
    final List<dynamic> summariesJson = jsonDecode(summariesString);
    return summariesJson.map((json) => ConversationSummary.fromJson(json)).toList();
  }

  // Generate learning context for AI
  static String generateLearningContext() {
    final prefs = getUserPreferences();
    final summaries = getConversationSummaries();
    
    final buffer = StringBuffer();
    buffer.writeln('USER LEARNING PROFILE:');
    buffer.writeln('- Preferred explanation style: ${prefs.explanationStyle}');
    buffer.writeln('- Communication style: ${prefs.communicationStyle}');
    buffer.writeln('- Likes examples: ${prefs.likesExamples ? "Yes" : "No"}');
    buffer.writeln('- Prefers step-by-step: ${prefs.likesStepByStep ? "Yes" : "No"}');
    
    if (prefs.frequentTopics.isNotEmpty) {
      buffer.writeln('- Frequent topics: ${prefs.frequentTopics.take(5).join(", ")}');
    }
    
    if (prefs.strengthAreas.isNotEmpty) {
      buffer.writeln('- Strong in: ${prefs.strengthAreas.join(", ")}');
    }
    
    if (prefs.weaknessAreas.isNotEmpty) {
      buffer.writeln('- Needs help with: ${prefs.weaknessAreas.join(", ")}');
    }
    
    if (summaries.isNotEmpty) {
      buffer.writeln('\nRECENT INTERACTION PATTERNS:');
      final recentSummaries = summaries.reversed.take(3);
      for (var summary in recentSummaries) {
        buffer.writeln('- Topics: ${summary.topicsDiscussed.join(", ")}');
        buffer.writeln('  Behavior: ${summary.userBehavior}');
        if (summary.keyLearnings.isNotEmpty) {
          summary.keyLearnings.forEach((topic, learning) {
            buffer.writeln('  $topic: $learning');
          });
        }
      }
    }
    
    return buffer.toString();
  }

  static Future<void> updateLearningFromConversation({
    required List<String> topics,
    bool? likesExamples,
    bool? likesStepByStep,
    Map<String, bool>? topicPerformance,
  }) async {
    final pref = getUserPreferences();
    
    if (likesExamples != null || likesStepByStep != null) {
      pref.updateLearningPattern(
        examples: likesExamples,
        stepByStep: likesStepByStep,
      );
    }
    
    if (topicPerformance != null) {
      topicPerformance.forEach((topic, isStrong) {
        if (isStrong) {
          pref.markStrength(topic);
        } else {
          pref.markWeakness(topic);
        }
      });
    }
    
    await savePreferences(pref);
  }
}
