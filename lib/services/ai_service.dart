import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/user_preference.dart';
import '../models/conversation_summary.dart';
import 'preference_service.dart';

class AIService {
  static const String openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String model = 'gpt-4o-mini'; // More affordable option
  
  // Main message sending function
  static Future<String> sendMessage(String userMessage, List<Message> context) async {
    final provider = PreferenceService.getApiProvider();
    
    // Route to appropriate API based on provider
    if (provider == 'gemini') {
      return _sendMessageGemini(userMessage, context);
    } else {
      return _sendMessageOpenAI(userMessage, context);
    }
  }
  
  // OpenAI API implementation
  static Future<String> _sendMessageOpenAI(String userMessage, List<Message> context) async {
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
  
  // Google Gemini API implementation
  static Future<String> _sendMessageGemini(String userMessage, List<Message> context) async {
    final apiKey = PreferenceService.getGeminiApiKey();
    
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
      
      // Build conversation history
      final contents = _buildGeminiContents(userMessage, context, learningContext, prefs);
      
      // Call Gemini API with timeout
      final response = await http.post(
        Uri.parse('$geminiEndpoint?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
          },
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
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          return "⚠️ Received invalid response from AI. Please try again.";
        }
        
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Learn from this interaction
        await _learnFromInteraction(userMessage, aiResponse, context);
        
        return aiResponse;
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        return "⚠️ Invalid request: ${data['error']?['message'] ?? 'Please check your input'}";
      } else if (response.statusCode == 403) {
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
  
  static List<Map<String, dynamic>> _buildGeminiContents(
    String userMessage,
    List<Message> context,
    String learningContext,
    UserPreference prefs,
  ) {
    final contents = <Map<String, dynamic>>[];
    
    // System instruction as first user message (Gemini doesn't have system role)
    final systemPrompt = '''You are an AI assistant embedded in a mobile chat app. Act like ChatGPT optimized for daily life, learning, and education.

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

Remember: Each chat is fresh, but you know this user from past interactions. Adapt your teaching style accordingly.''';
    
    // Add recent context (last 6 messages)
    final recentMessages = context.length > 6 ? context.sublist(context.length - 6) : context;
    
    // If it's the first message, include system prompt
    if (recentMessages.isEmpty) {
      contents.add({
        'role': 'user',
        'parts': [{'text': systemPrompt}]
      });
      contents.add({
        'role': 'model',
        'parts': [{'text': 'I understand. I\'ll act as your personalized AI assistant, adapting to your learning style and preferences. How can I help you today?'}]
      });
    }
    
    // Add conversation history
    for (var msg in recentMessages) {
      contents.add({
        'role': msg.isUser ? 'user' : 'model',
        'parts': [{'text': msg.text}]
      });
    }
    
    // Add current message
    contents.add({
      'role': 'user',
      'parts': [{'text': userMessage}]
    });
    
    return contents;
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

  // Demo mode with intelligent responses (no API key needed)
  static String _getMockResponse(String message) {
    final msg = message.toLowerCase();
    
    // Greetings
    if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey')) {
      return "👋 **Hello! I'm running in DEMO Mode**\n\nI can still help you with basic questions! Try asking me about:\n• General knowledge (\"What is photosynthesis?\")\n• Simple math (\"What's 15% of 80?\")\n• Coding basics (\"What is a variable?\")\n• Study tips\n• And more!\n\n💡 **Want unlimited AI power?**\nTap ⚙️ Settings → Add FREE Gemini API key → Start chatting smarter!";
    }
    
    // Math questions
    if (msg.contains('what is') || msg.contains('what\'s') || msg.contains('calculate')) {
      // Percentage calculations
      final percentMatch = RegExp(r'(\d+)%\s*of\s*(\d+)').firstMatch(msg);
      if (percentMatch != null) {
        final percent = int.parse(percentMatch.group(1)!);
        final number = int.parse(percentMatch.group(2)!);
        final result = (percent * number / 100).toStringAsFixed(2);
        return "$percent% of $number = **$result**\n\n📊 Calculation: ($percent ÷ 100) × $number = $result";
      }
      
      // Basic arithmetic
      final addMatch = RegExp(r'(\d+)\s*\+\s*(\d+)').firstMatch(msg);
      if (addMatch != null) {
        final a = int.parse(addMatch.group(1)!);
        final b = int.parse(addMatch.group(2)!);
        return "$a + $b = **${a + b}**";
      }
      
      final multiplyMatch = RegExp(r'(\d+)\s*[x×*]\s*(\d+)').firstMatch(msg);
      if (multiplyMatch != null) {
        final a = int.parse(multiplyMatch.group(1)!);
        final b = int.parse(multiplyMatch.group(2)!);
        return "$a × $b = **${a * b}**";
      }
    }
    
    // Science questions
    if (msg.contains('photosynthesis')) {
      return "🌿 **Photosynthesis** is how plants make their food!\n\n**Simple:** Plants use sunlight to turn water and CO₂ into glucose (sugar) and oxygen.\n\n**Formula:** 6CO₂ + 6H₂O + Light → C₆H₁₂O₆ + 6O₂\n\n**Why it matters:** Plants produce the oxygen we breathe!";
    }
    
    if (msg.contains('gravity')) {
      return "🌍 **Gravity** is the force that pulls objects toward each other.\n\n• Earth's gravity keeps us on the ground\n• The Moon orbits Earth due to gravity\n• Gravity = 9.8 m/s² on Earth\n\n**Fun fact:** You'd weigh less on the Moon (1/6th of Earth gravity)!";
    }
    
    // Programming questions
    if (msg.contains('variable') || msg.contains('programming')) {
      return "💻 **Variable** = A container that stores data in programming\n\n**Example (Python):**\n```python\nname = \"Alice\"  # String variable\nage = 25       # Number variable\n```\n\n**Think of it as:** A labeled box where you can store and retrieve information!";
    }
    
    if (msg.contains('loop') || msg.contains('for loop')) {
      return "🔄 **Loop** = Repeats code multiple times\n\n**Example (Python):**\n```python\nfor i in range(5):\n    print(i)  # Prints: 0, 1, 2, 3, 4\n```\n\n**Why useful?** Automate repetitive tasks instead of copy-pasting code!";
    }
    
    // Study tips
    if (msg.contains('study') || msg.contains('learn') || msg.contains('exam')) {
      return "📚 **Effective Study Tips:**\n\n1. **Pomodoro:** 25 min focus + 5 min break\n2. **Active recall:** Test yourself, don't just re-read\n3. **Spaced repetition:** Review after 1 day, 3 days, 1 week\n4. **Teach someone:** Best way to master a topic\n5. **Sleep:** 7-8 hours = better memory\n\n🎯 Quality > Quantity!";
    }
    
    // Motivation
    if (msg.contains('motivate') || msg.contains('inspire') || msg.contains('give up')) {
      return "💪 **You've got this!**\n\n\"Success is not final, failure is not fatal. It's the courage to continue that counts.\"\n\n🌟 **Remember:**\n• Every expert was once a beginner\n• Progress > Perfection\n• Small steps lead to big wins\n\n**Keep pushing forward!** 🚀";
    }
    
    // Time/productivity
    if (msg.contains('time') && (msg.contains('manage') || msg.contains('productive'))) {
      return "⏰ **Time Management Tips:**\n\n1. **Prioritize:** Do important tasks when you're most alert\n2. **Block distractions:** Phone away, notifications off\n3. **Break tasks:** Big task → smaller chunks\n4. **2-minute rule:** If it takes <2 min, do it now\n5. **Say NO:** Don't overcommit\n\n⚡ Work smarter, not harder!";
    }
    
    // Health
    if (msg.contains('health') || msg.contains('exercise') || msg.contains('fit')) {
      return "🏃 **Health Basics:**\n\n**Exercise:** 30 min/day (walk, run, yoga)\n**Hydration:** 8 glasses of water daily\n**Sleep:** 7-8 hours for recovery\n**Nutrition:** Balanced meals (protein, veggies, carbs)\n\n💡 *Your body is your most valuable asset!*";
    }
    
    // Default helpful response
    return "🤖 **Demo Mode Active**\n\nI can answer basic questions, but for unlimited intelligent responses:\n\n**🎯 Quick Setup (2 minutes):**\n1. Visit: https://makersuite.google.com/app/apikey\n2. Sign in with Google → Create API key\n3. Copy key → Paste in ⚙️ Settings\n4. Select \"Google Gemini\" as provider\n5. Tap \"Save Settings\"\n\n✅ **100% FREE** - No credit card needed!\n\nTry asking me about: math, science, coding, study tips, or anything else!";
  }
}
