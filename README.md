# AI Chat Assistant

A modern Flutter-based AI Chat application with a beautiful UI, chat history, and multi-language support.

## Features

- 🤖 AI-powered conversational assistant
- 💬 Chat history management with session summaries
- 🌓 Dark and light mode support
- 🌍 Multi-language localization support
- 📝 Markdown rendering with code syntax highlighting
- 📎 File attachment support
- 💾 Persistent chat storage
- ⚙️ Customizable settings (font size, theme, language)

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- An IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd flutter\ chatApp
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── chat_session.dart
│   ├── message.dart
│   └── user_preference.dart
├── screens/                  # UI screens
│   ├── chat_screen.dart
│   ├── chat_history_screen.dart
│   └── settings_screen.dart
├── services/                 # Business logic
│   ├── ai_service.dart
│   ├── chat_history_service.dart
│   └── preference_service.dart
└── widgets/                  # Reusable widgets
    ├── message_bubble.dart
    └── typing_indicator.dart
```

## Technologies Used

- **Flutter** - UI framework
- **flutter_markdown** - Markdown rendering
- **flutter_highlight** - Code syntax highlighting
- **shared_preferences** - Local storage
- **intl** - Internationalization

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.
