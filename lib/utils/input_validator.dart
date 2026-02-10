/// Utility class for validating user input in the chat application.
/// 
/// Provides methods to validate messages, check for spam patterns,
/// and ensure input meets quality standards before processing.
class InputValidator {
  // Prevent instantiation
  InputValidator._();

  /// Maximum allowed message length in characters
  static const int maxMessageLength = 4000;
  
  /// Minimum message length to be considered valid
  static const int minMessageLength = 1;
  
  /// Maximum consecutive whitespace characters allowed
  static const int maxConsecutiveSpaces = 5;

  /// Validates a chat message before sending.
  /// 
  /// Returns a [ValidationResult] containing:
  /// - `isValid`: true if the message passes all validation checks
  /// - `errorMessage`: descriptive error message if validation fails
  /// 
  /// Validation checks:
  /// - Not empty or only whitespace
  /// - Within length limits
  /// - No excessive consecutive spaces
  /// - Contains at least one alphanumeric character
  static ValidationResult validateMessage(String message) {
    // Check if empty or only whitespace
    if (message.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a message',
      );
    }

    // Check minimum length
    final trimmed = message.trim();
    if (trimmed.length < minMessageLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Message is too short',
      );
    }

    // Check maximum length
    if (trimmed.length > maxMessageLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Message is too long (max $maxMessageLength characters)',
      );
    }

    // Check for excessive consecutive spaces
    if (_hasExcessiveSpaces(message)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Message contains too many consecutive spaces',
      );
    }

    // Check if message contains at least one meaningful character
    if (!_hasAlphanumericContent(trimmed)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Message must contain at least one letter or number',
      );
    }

    // All validations passed
    return ValidationResult(isValid: true);
  }

  /// Checks if the message has excessive consecutive spaces
  static bool _hasExcessiveSpaces(String message) {
    final pattern = RegExp(' {$maxConsecutiveSpaces,}');
    return pattern.hasMatch(message);
  }

  /// Checks if the message contains at least one alphanumeric character
  static bool _hasAlphanumericContent(String message) {
    return RegExp(r'[a-zA-Z0-9]').hasMatch(message);
  }

  /// Sanitizes input by trimming whitespace and normalizing spaces
  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' '); // Replace multiple spaces with single space
  }

  /// Checks if a message might be spam (repeated characters or patterns)
  static bool isPotentialSpam(String message) {
    // Check for repeated characters (e.g., "aaaaaaa", "!!!!!!!")
    final repeatedChars = RegExp(r'(.)\1{9,}'); // 10+ same characters in a row
    if (repeatedChars.hasMatch(message)) {
      return true;
    }

    // Check for repeated short patterns (e.g., "lolololo")
    final repeatedPattern = RegExp(r'(.{2,4})\1{4,}'); // Same 2-4 chars repeated 5+ times
    if (repeatedPattern.hasMatch(message)) {
      return true;
    }

    return false;
  }

  /// Validates API key format (basic check for OpenAI keys)
  static ValidationResult validateApiKey(String apiKey) {
    final trimmed = apiKey.trim();

    if (trimmed.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'API key cannot be empty',
      );
    }

    // OpenAI keys usually start with 'sk-' and are longer than 20 chars
    if (!trimmed.startsWith('sk-') || trimmed.length < 20) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Invalid API key format. OpenAI keys start with "sk-"',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Gets a user-friendly character count message
  static String getCharacterCountMessage(int count) {
    if (count >= maxMessageLength) {
      return 'Maximum length reached';
    } else if (count >= maxMessageLength * 0.9) {
      final remaining = maxMessageLength - count;
      return '$remaining characters remaining';
    }
    return '';
  }
}

/// Result of an input validation check
class ValidationResult {
  /// Whether the validation passed
  final bool isValid;
  
  /// Error message if validation failed, null otherwise
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
