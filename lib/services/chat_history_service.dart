import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';
import '../models/message.dart';

class ChatHistoryService {
  static SharedPreferences? _prefs;
  static const String _historyKey = 'chat_history';
  static const int maxSessions = 50;

  static Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
  }

  static Future<void> saveSession(List<Message> messages) async {
    if (messages.length < 2) return; // Don't save empty chats

    // Generate title from first user message
    final firstUserMsg = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => messages.first,
    );
    final title = _generateTitle(firstUserMsg.text);

    final session = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      messages: messages,
      title: title,
    );

    final sessions = await getSessions();
    sessions.insert(0, session);

    // Keep only recent sessions
    if (sessions.length > maxSessions) {
      sessions.removeRange(maxSessions, sessions.length);
    }

    await _saveSessions(sessions);
  }

  static String _generateTitle(String firstMessage) {
    final cleaned = firstMessage.trim();
    if (cleaned.length <= 40) return cleaned;
    return '${cleaned.substring(0, 40)}...';
  }

  static Future<List<ChatSession>> getSessions() async {
    final jsonString = _prefs?.getString(_historyKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ChatSession.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _saveSessions(List<ChatSession> sessions) async {
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await _prefs?.setString(_historyKey, jsonEncode(jsonList));
  }

  static Future<void> deleteSession(String id) async {
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.id == id);
    await _saveSessions(sessions);
  }

  static Future<void> clearAll() async {
    await _prefs?.remove(_historyKey);
  }
}
