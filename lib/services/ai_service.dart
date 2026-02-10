import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/user_preference.dart';
import '../models/conversation_summary.dart';
import 'preference_service.dart';

class AIService {
  static const String openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String model = 'gpt-4o-mini'; // More affordable option
  
  // Main message sending function
  static Future<String> sendMessage(String userMessage, List<Message> context) async {
    final apiKey = PreferenceService.getApiKey();
    
    // If no API key, return helpful message
    if (apiKey == null || apiKey.isEmpty) {
      return _getMockResponse(userMessage);
    }
    
    try {
      // Get user preferences and learning context
      final prefs = PreferenceService.getUserPreferences();
      final learningContext = PreferenceService.generateLearningContext();
      
      // Extract topics and update tracking
      _extractAndUpdateTopic(userMessage);
      
      // Build messages for AI
      final messages = _buildMessages(userMessage, context, learningContext, prefs);
      
      // Call OpenAI API with timeout
      final response = await http.post(
        Uri.parse(openAIEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Validate response structure
        if (data['choices'] == null || data['choices'].isEmpty) {
          return "⚠️ Received invalid response from AI. Please try again.";
        }
        
        final aiResponse = data['choices'][0]['message']['content'];
        
        // Learn from this interaction
        await _learnFromInteraction(userMessage, aiResponse, context);
        
        return aiResponse;
      } else if (response.statusCode == 401) {
        return "⚠️ API key is invalid or unauthorized. Please update it in settings.";
      } else if (response.statusCode == 429) {
        return "⚠️ Rate limit exceeded. Please wait a moment and try again.";
      } else if (response.statusCode == 500 || response.statusCode == 503) {
        return "⚠️ AI service is temporarily unavailable. Please try again later.";
      } else {
        return "⚠️ Error (${response.statusCode}): ${response.reasonPhrase ?? 'Unknown error'}. Please try again.";
      }
    } on FormatException catch (e) {
      return "⚠️ Error parsing response. Please try again.";
    } on http.ClientException catch (e) {
      return "⚠️ Network error. Please check your internet connection.";
    } on Exception catch (e) {
      if (e.toString().contains('timeout')) {
        return "⚠️ Request timed out. Please check your connection and try again.";
      }
      return "⚠️ Unexpected error occurred. Please try again.";
    } catch (e) {
      return "⚠️ Connection error. Please check your internet and try again.";
    }
  }
  
  static List<Map<String, String>> _buildMessages(
    String userMessage,
    List<Message> context,
    String learningContext,
    UserPreference prefs,
  ) {
    final messages = <Map<String, String>>[];
    
    // System prompt with learning context
    messages.add({
      'role': 'system',
      'content': '''You are an AI assistant embedded in a mobile chat app. Act like ChatGPT optimized for daily life, learning, and education.

CORE BEHAVIOR:
- Answer ANY question: General Knowledge, Education, Coding, Math, Daily Life
- Be intelligent, calm, supportive, and adaptive
- Adjust explanation depth dynamically based on user needs
- If asked follow-up questions, increase clarity and simplicity
- If question is vague, ask ONE clarifying question
- If unsure, say "I'm not sure" instead of guessing

PERSONALIZATION:
$learningContext

RESPONSE FORMAT:
- Use bullet points where helpful
- Step-by-step for complex topics
- Code should be clean and well-commented
- Keep language ${prefs.explanationStyle == 'short' ? 'concise' : prefs.explanationStyle == 'detailed' ? 'thorough' : 'balanced'}
${prefs.likesExamples ? '- Include practical examples' : ''}
${prefs.likesStepByStep ? '- Use step-by-step explanations' : ''}

ETHICAL RULES:
- No hallucinations - admit when you don't know
- Encourage learning, not dependency
- Be respectful and helpful

Remember: Each chat is fresh, but you know this user from past interactions. Adapt your teaching style accordingly.'''
    });
    
    // Add recent context (last 6 messages for context)
    final recentMessages = context.length > 6 ? context.sublist(context.length - 6) : context;
    for (var msg in recentMessages) {
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }
    
    // Add current message
    messages.add({
      'role': 'user',
      'content': userMessage,
    });
    
    return messages;
  }

  static void _extractAndUpdateTopic(String message) {
    final keywords = {
      'code': 'Programming',
      'program': 'Programming',
      'function': 'Programming',
      'algorithm': 'Programming',
      'math': 'Mathematics',
      'calculate': 'Mathematics',
      'solve': 'Mathematics',
      'equation': 'Mathematics',
      'science': 'Science',
      'physics': 'Physics',
      'chemistry': 'Chemistry',
      'biology': 'Biology',
      'history': 'History',
      'geography': 'Geography',
      'explain': 'General Learning',
      'how': 'How-to Questions',
      'why': 'Conceptual Understanding',
      'what': 'General Knowledge',
    };

    for (var entry in keywords.entries) {
      if (message.toLowerCase().contains(entry.key)) {
        PreferenceService.updateInteraction(entry.value);
        break;
      }
    }
  }

  // Learn from conversation patterns
  static Future<void> _learnFromInteraction(
    String userMessage,
    String aiResponse,
    List<Message> context,
  ) async {
    // Detect if user likes examples (if response had examples and they engaged)
    final hasExample = aiResponse.contains('example') || aiResponse.contains('Example');
    final isFollowUp = context.isNotEmpty && 
        context.last.text.toLowerCase().contains('explain') ||
        context.last.text.toLowerCase().contains('more');
    
    // Detect preference for step-by-step
    final hasSteps = aiResponse.contains('Step ') || 
        aiResponse.contains('1.') || 
        aiResponse.contains('First,');
    
    // Extract topics from this conversation
    final topics = <String>[];
    _extractAndUpdateTopic(userMessage);
    
    // If conversation is getting longer, user might need detailed explanations
    if (context.length > 4) {
      final prefs = PreferenceService.getUserPreferences();
      if (prefs.explanationStyle == 'short') {
        prefs.explanationStyle = 'balanced';
        await PreferenceService.savePreferences(prefs);
      }
    }
  }

  // Save conversation summary when chat ends (call this when user closes chat)
  static Future<void> saveConversationSummary(List<Message> messages) async {
    if (messages.length < 2) return; // Too short to learn from
    
    final topics = <String>[];
    final keyLearnings = <String, String>{};
    
    // Analyze conversation
    for (var msg in messages) {
      if (msg.isUser) {
        // Extract topics
        final text = msg.text.toLowerCase();
        if (text.contains('code') || text.contains('program')) {
          topics.add('Programming');
        }
        if (text.contains('math') || text.contains('calculate')) {
          topics.add('Mathematics');
        }
        if (text.contains('explain') || text.contains('understand')) {
          topics.add('Conceptual Learning');
        }
      }
    }
    
    // Determine user behavior
    final avgMessageLength = messages
        .where((m) => m.isUser)
        .map((m) => m.text.length)
        .fold(0, (a, b) => a + b) / messages.where((m) => m.isUser).length;
    
    final userBehavior = avgMessageLength > 50 
        ? 'Detailed questions, thorough engagement'
        : 'Quick questions, concise style';
    
    final prefs = PreferenceService.getUserPreferences();
    
    final summary = ConversationSummary(
      timestamp: DateTime.now(),
      topicsDiscussed: topics.toSet().toList(),
      userBehavior: userBehavior,
      preferredDepth: prefs.explanationStyle,
      keyLearnings: keyLearnings,
    );
    
    await PreferenceService.saveConversationSummary(summary);
  }

  // Fallback mock response when no API key
  static String _getMockResponse(String message) {
    final msg = message.toLowerCase();

    if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey')) {
      return "👋 Hello! \n\n⚠️ **No API Key Configured**\n\nTo unlock full AI capabilities, please:\n1. Tap the settings icon (⚙️) in the app bar\n2. Enter your OpenAI API key\n3. Get your key at: https://platform.openai.com/api-keys\n\nOnce configured, I'll provide intelligent, personalized responses and learn from our conversations!";
    }

    return "⚠️ **API Key Required**\n\nI'm currently running in demo mode. To enable full AI capabilities:\n\n1. Get an OpenAI API key from: https://platform.openai.com/api-keys\n2. Tap settings (⚙️) in the app bar\n3. Enter your API key\n\nThen I can:\n✅ Answer any question intelligently\n✅ Learn your preferences\n✅ Adapt to your learning style\n✅ Remember context across conversations";
  }
}
