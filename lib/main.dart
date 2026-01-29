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
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFFFFF),
        scaffoldBackgroundColor: const Color(0xFF000000),
        cardColor: const Color(0xFF1A1A1A),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
          bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const ChatScreen(),
    );
  }
}
