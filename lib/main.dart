import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/chat_screen.dart';
import 'services/preference_service.dart';
import 'services/chat_history_service.dart';
import 'l10n/app_localizations.dart';

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
  late ValueNotifier<double> _fontScale;
  late ValueNotifier<String> _languageCode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = ValueNotifier(PreferenceService.getDarkMode());
    _fontScale = ValueNotifier(PreferenceService.getFontSize());
    _languageCode = ValueNotifier(PreferenceService.getLanguage());
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    PreferenceService.setDarkMode(_isDarkMode.value);
  }
ValueListenableBuilder<double>(
          valueListenable: _fontScale,
          builder: (context, fontScale, child) {
            return ValueListenableBuilder<String>(
              valueListenable: _languageCode,
              builder: (context, languageCode, child) {
                return MaterialApp(
                  title: 'Chat AI',
                  debugShowCheckedModeBanner: false,
                  locale: Locale(languageCode),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(fontScale)),
                      child: child!,
                    );
                  },
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
                  home: ChatScreen(
                    onToggleTheme: toggleTheme,
                    onUpdateFontSize: updateFontSize,
                    onUpdateLanguage: updateLanguage,
                  ),
    _fontScale.dispose();
    _languageCode.dispose();
                );
              },
            );
          }
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
