import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'services/preference_service.dart';
import 'services/chat_history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await PreferenceService.init();
  await ChatHistoryService.init(prefs);
  runApp(const AIAssistantApp());
}

class AIAssistantApp extends StatelessWidget {
  const AIAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF000000),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        cardColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF000000)),
          bodyMedium: TextStyle(color: Color(0xFF000000)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF000000),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      themeMode: ThemeMode.light,
      home: const ChatScreen(),
    );
  }
}
