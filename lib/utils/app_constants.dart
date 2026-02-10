import 'package:flutter/material.dart';

/// Application-wide constants for consistent styling and configuration.
/// 
/// This file contains all reusable constants including colors, dimensions,
/// durations, and text styles to maintain consistency across the app.
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // ============ COLORS ============
  
  /// User message bubble colors
  static const Color userBubbleDark = Color(0xFF2B2B2B);
  static const Color userBubbleLight = Color(0xFF000000);
  static const Color userBubbleBorderDark = Color(0xFF404040);
  static const Color userBubbleBorderLight = Colors.black;
  
  /// AI message bubble colors
  static const Color aiBubbleDark = Color(0xFF1E1E1E);
  static const Color aiBubbleLight = Color(0xFFF5F5F5);
  static const Color aiBubbleBorderDark = Color(0xFF303030);
  static const Color aiBubbleBorderLight = Color(0xFFE0E0E0);
  
  /// Text colors
  static const Color textUserMessage = Color(0xFFFFFFFF);
  static const Color textAIMessageDark = Color(0xFFE0E0E0);
  static const Color textAIMessageLight = Colors.black;
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textSecondaryLight = Color(0xFF666666);
  
  /// Code block colors
  static const Color codeBackgroundDark = Color(0xFF1A1A1A);
  static const Color codeBackgroundLight = Color(0xFFF6F8FA);
  static const Color codeTextDark = Color(0xFFE06C75);
  static const Color codeTextLight = Color(0xFFD73A49);
  static const Color codeBorderDark = Color(0xFF2D2D2D);
  static const Color codeBorderLight = Color(0xFFE1E4E8);
  
  /// Attachment container colors
  static const Color attachmentUserDark = Color(0xFF3A3A3A);
  static const Color attachmentUserLight = Color(0xFF2B2B2B);
  static const Color attachmentAIDark = Color(0xFF2A2A2A);
  static const Color attachmentAILight = Color(0xFFE8E8E8);
  
  /// AI assistant icon colors
  static const Color aiIconBackgroundDark = Colors.white;
  static const Color aiIconBackgroundLight = Colors.black;
  static const Color aiIconDark = Colors.black;
  static const Color aiIconLight = Colors.white;
  
  // ============ DIMENSIONS ============
  
  /// Message bubble dimensions
  static const double messageBubblePaddingHorizontal = 18.0;
  static const double messageBubblePaddingVertical = 14.0;
  static const double messageBubbleRadius = 20.0;
  static const double messageBubbleBorderWidth = 1.0;
  static const double messageBubbleBottomMargin = 20.0;
  
  /// AI assistant icon dimensions
  static const double aiIconSize = 36.0;
  static const double aiIconRadius = 10.0;
  static const double aiIconSpacing = 12.0;
  
  /// Attachment dimensions
  static const double attachmentPadding = 12.0;
  static const double attachmentRadius = 12.0;
  static const double attachmentIconSize = 24.0;
  static const double attachmentSpacing = 8.0;
  
  /// Code block dimensions
  static const double codeBlockPadding = 12.0;
  static const double codeBlockRadius = 8.0;
  
  // ============ TEXT STYLES ============
  
  /// Message text size and formatting
  static const double messageTextSize = 15.0;
  static const double messageTextHeight = 1.6;
  static const double messageTextLetterSpacing = 0.2;
  
  /// Code text size
  static const double codeTextSize = 14.0;
  static const String codeTextFamily = 'monospace';
  
  /// Timestamp text size
  static const double timestampTextSize = 11.0;
  
  /// Attachment text sizes
  static const double attachmentNameTextSize = 13.0;
  static const double attachmentSizeTextSize = 11.0;
  
  /// Heading text sizes
  static const double headingH1Size = 24.0;
  static const double headingH2Size = 20.0;
  static const double headingH3Size = 18.0;
  
  /// Copy icon size
  static const double copyIconSize = 16.0;
  static const double errorIconSize = 14.0;
  
  // ============ DURATIONS ============
  
  /// Animation and snackbar durations
  static const Duration snackbarDuration = Duration(seconds: 2);
  static const Duration typingIndicatorDuration = Duration(milliseconds: 1500);
  
  // ============ SHADOWS ============
  
  /// Message bubble shadow
  static BoxShadow messageBubbleShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 3),
  );
  
  /// AI icon shadow
  static BoxShadow aiIconShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  
  // ============ MARKDOWN STYLES ============
  
  /// Get markdown text style based on theme and message sender
  static TextStyle getMarkdownTextStyle({
    required bool isDark,
    required bool isUser,
    double? fontSize,
  }) {
    return TextStyle(
      color: isUser
          ? textUserMessage
          : (isDark ? textAIMessageDark : textAIMessageLight),
      fontSize: fontSize ?? messageTextSize,
      height: messageTextHeight,
      letterSpacing: messageTextLetterSpacing,
    );
  }
  
  /// Get code text style based on theme
  static TextStyle getCodeTextStyle(bool isDark) {
    return TextStyle(
      backgroundColor: isDark ? codeBackgroundDark : codeBackgroundLight,
      color: isDark ? codeTextDark : codeTextLight,
      fontFamily: codeTextFamily,
      fontSize: codeTextSize,
    );
  }
  
  /// Get code block decoration based on theme
  static BoxDecoration getCodeBlockDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? codeBackgroundDark : codeBackgroundLight,
      borderRadius: BorderRadius.circular(codeBlockRadius),
      border: Border.all(
        color: isDark ? codeBorderDark : codeBorderLight,
      ),
    );
  }
}
