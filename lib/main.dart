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

class AIAssistantApp extends StatefulWidget {
  const AIAssistantApp({super.key});

  @override
  State<AIAssistantApp> createState() => _AIAssistantAppState();
}

class _AIAssistantAppState extends State<AIAssistantApp> {
  late ValueNotifier<bool> _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = ValueNotifier(PreferenceService.getDarkMode());
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    PreferenceService.setDarkMode(_isDarkMode.value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isDarkMode,
      builder: (context, isDark, child) {
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
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.white,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            useMaterial3: true,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
              bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Color(0xFFFFFFFF),
              elevation: 0,
              centerTitle: true,
            ),
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: ChatScreen(onToggleTheme: toggleTheme),
        );
      },
    );
  }

  @override
  void dispose() {
    _isDarkMode.dispose();
    super.dispose();
  }
}
