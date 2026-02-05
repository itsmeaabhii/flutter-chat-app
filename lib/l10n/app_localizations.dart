import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
    Locale('hi'), // Hindi
    Locale('zh'), // Chinese
    Locale('ar'), // Arabic
    Locale('ja'), // Japanese
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Chat AI',
      'chat_history': 'Chat History',
      'settings': 'Settings',
      'new_chat': 'New Chat',
      'clear_chat': 'Clear Chat',
      'export_text': 'Export as Text',
      'export_pdf': 'Export as PDF',
      'ask_anything': 'Ask anything...',
      'api_configuration': 'API Configuration',
      'openai_api_key': 'OpenAI API Key',
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'font_size': 'Font Size',
      'language': 'Language',
      'learning_preferences': 'Learning Preferences',
      'explanation_style': 'Explanation Style',
      'concise': 'Concise',
      'balanced': 'Balanced',
      'detailed': 'Detailed',
      'include_examples': 'Include Examples',
      'step_by_step': 'Step-by-Step',
      'save_settings': 'Save Settings',
      'settings_saved': 'Settings saved successfully!',
      'message_copied': 'Message copied to clipboard',
      'no_messages': 'No messages to export',
      'exported_success': 'Conversation exported successfully',
      'pdf_exported': 'PDF exported successfully',
      'small': 'Small',
      'medium': 'Medium',
      'large': 'Large',
      'extra_large': 'Extra Large',
      'switch_theme': 'Switch between light and dark theme',
      'adjust_font': 'Adjust text size for better readability',
      'select_language': 'Choose your preferred language',
    },
    'es': {
      'app_title': 'Chat IA',
      'chat_history': 'Historial de Chat',
      'settings': 'Configuración',
      'new_chat': 'Nuevo Chat',
      'clear_chat': 'Limpiar Chat',
      'export_text': 'Exportar como Texto',
      'export_pdf': 'Exportar como PDF',
      'ask_anything': 'Pregunta lo que quieras...',
      'api_configuration': 'Configuración API',
      'openai_api_key': 'Clave API de OpenAI',
      'appearance': 'Apariencia',
      'dark_mode': 'Modo Oscuro',
      'font_size': 'Tamaño de Fuente',
      'language': 'Idioma',
      'learning_preferences': 'Preferencias de Aprendizaje',
      'explanation_style': 'Estilo de Explicación',
      'concise': 'Conciso',
      'balanced': 'Equilibrado',
      'detailed': 'Detallado',
      'include_examples': 'Incluir Ejemplos',
      'step_by_step': 'Paso a Paso',
      'save_settings': 'Guardar Configuración',
      'settings_saved': '¡Configuración guardada con éxito!',
      'message_copied': 'Mensaje copiado al portapapeles',
      'no_messages': 'No hay mensajes para exportar',
      'exported_success': 'Conversación exportada con éxito',
      'pdf_exported': 'PDF exportado con éxito',
      'small': 'Pequeño',
      'medium': 'Mediano',
      'large': 'Grande',
      'extra_large': 'Extra Grande',
      'switch_theme': 'Cambiar entre tema claro y oscuro',
      'adjust_font': 'Ajustar tamaño de texto para mejor legibilidad',
      'select_language': 'Elige tu idioma preferido',
    },
    'fr': {
      'app_title': 'Chat IA',
      'chat_history': 'Historique des Discussions',
      'settings': 'Paramètres',
      'new_chat': 'Nouvelle Discussion',
      'clear_chat': 'Effacer la Discussion',
      'export_text': 'Exporter en Texte',
      'export_pdf': 'Exporter en PDF',
      'ask_anything': 'Demandez n\'importe quoi...',
      'api_configuration': 'Configuration API',
      'openai_api_key': 'Clé API OpenAI',
      'appearance': 'Apparence',
      'dark_mode': 'Mode Sombre',
      'font_size': 'Taille de Police',
      'language': 'Langue',
      'learning_preferences': 'Préférences d\'Apprentissage',
      'explanation_style': 'Style d\'Explication',
      'concise': 'Concis',
      'balanced': 'Équilibré',
      'detailed': 'Détaillé',
      'include_examples': 'Inclure des Exemples',
      'step_by_step': 'Étape par Étape',
      'save_settings': 'Enregistrer les Paramètres',
      'settings_saved': 'Paramètres enregistrés avec succès!',
      'message_copied': 'Message copié dans le presse-papiers',
      'no_messages': 'Aucun message à exporter',
      'exported_success': 'Conversation exportée avec succès',
      'pdf_exported': 'PDF exporté avec succès',
      'small': 'Petit',
      'medium': 'Moyen',
      'large': 'Grand',
      'extra_large': 'Très Grand',
      'switch_theme': 'Basculer entre thème clair et sombre',
      'adjust_font': 'Ajuster la taille du texte pour une meilleure lisibilité',
      'select_language': 'Choisissez votre langue préférée',
    },
    'hi': {
      'app_title': 'चैट एआई',
      'chat_history': 'चैट इतिहास',
      'settings': 'सेटिंग्स',
      'new_chat': 'नई चैट',
      'clear_chat': 'चैट साफ़ करें',
      'export_text': 'टेक्स्ट के रूप में निर्यात करें',
      'export_pdf': 'PDF के रूप में निर्यात करें',
      'ask_anything': 'कुछ भी पूछें...',
      'api_configuration': 'एपीआई कॉन्फ़िगरेशन',
      'openai_api_key': 'ओपनएआई एपीआई कुंजी',
      'appearance': 'दिखावट',
      'dark_mode': 'डार्क मोड',
      'font_size': 'फ़ॉन्ट आकार',
      'language': 'भाषा',
      'learning_preferences': 'सीखने की प्राथमिकताएं',
      'explanation_style': 'व्याख्या शैली',
      'concise': 'संक्षिप्त',
      'balanced': 'संतुलित',
      'detailed': 'विस्तृत',
      'include_examples': 'उदाहरण शामिल करें',
      'step_by_step': 'चरण-दर-चरण',
      'save_settings': 'सेटिंग्स सहेजें',
      'settings_saved': 'सेटिंग्स सफलतापूर्वक सहेजी गईं!',
      'message_copied': 'संदेश क्लिपबोर्ड पर कॉपी किया गया',
      'no_messages': 'निर्यात करने के लिए कोई संदेश नहीं',
      'exported_success': 'वार्तालाप सफलतापूर्वक निर्यात किया गया',
      'pdf_exported': 'PDF सफलतापूर्वक निर्यात किया गया',
      'small': 'छोटा',
      'medium': 'मध्यम',
      'large': 'बड़ा',
      'extra_large': 'बहुत बड़ा',
      'switch_theme': 'हल्की और गहरी थीम के बीच स्विच करें',
      'adjust_font': 'बेहतर पठनीयता के लिए टेक्स्ट आकार समायोजित करें',
      'select_language': 'अपनी पसंदीदा भाषा चुनें',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for commonly used strings
  String get appTitle => translate('app_title');
  String get chatHistory => translate('chat_history');
  String get settings => translate('settings');
  String get newChat => translate('new_chat');
  String get clearChat => translate('clear_chat');
  String get exportText => translate('export_text');
  String get exportPdf => translate('export_pdf');
  String get askAnything => translate('ask_anything');
  String get apiConfiguration => translate('api_configuration');
  String get openaiApiKey => translate('openai_api_key');
  String get appearance => translate('appearance');
  String get darkMode => translate('dark_mode');
  String get fontSize => translate('font_size');
  String get language => translate('language');
  String get learningPreferences => translate('learning_preferences');
  String get explanationStyle => translate('explanation_style');
  String get concise => translate('concise');
  String get balanced => translate('balanced');
  String get detailed => translate('detailed');
  String get includeExamples => translate('include_examples');
  String get stepByStep => translate('step_by_step');
  String get saveSettings => translate('save_settings');
  String get settingsSaved => translate('settings_saved');
  String get messageCopied => translate('message_copied');
  String get noMessages => translate('no_messages');
  String get exportedSuccess => translate('exported_success');
  String get pdfExported => translate('pdf_exported');
  String get small => translate('small');
  String get medium => translate('medium');
  String get large => translate('large');
  String get extraLarge => translate('extra_large');
  String get switchTheme => translate('switch_theme');
  String get adjustFont => translate('adjust_font');
  String get selectLanguage => translate('select_language');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
