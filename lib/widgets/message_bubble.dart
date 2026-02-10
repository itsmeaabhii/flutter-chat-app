import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/github-dark.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';

/// A customizable chat message bubble widget that displays messages with rich formatting.
/// 
/// This widget supports:
/// - Markdown rendering with syntax highlighting for code blocks
/// - User and AI message differentiation with distinct styling
/// - File attachments display
/// - Copy to clipboard functionality
/// - Retry mechanism for failed messages
/// - Responsive theme support (light/dark mode)
/// - Timestamp formatting with relative time display
class MessageBubble extends StatelessWidget {
  /// The message data to display
  final Message message;
  
  /// Optional callback function triggered when user double-taps a failed message
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key, 
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Detect current theme mode for adaptive styling
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.auto_awesome, color: isDark ? Colors.black : Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.attachments != null && message.attachments!.isNotEmpty)
                  _buildAttachments(isDark),
                GestureDetector(
                  onLongPress: () => _copyMessage(context),
                  onDoubleTap: message.status == MessageStatus.failed && onRetry != null
                      ? onRetry
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? (isDark ? const Color(0xFF2B2B2B) : const Color(0xFF000000))
                          : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: message.isUser 
                            ? (isDark ? const Color(0xFF404040) : Colors.black) 
                            : (isDark ? const Color(0xFF303030) : const Color(0xFFE0E0E0)),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          b_hasCodeBlock(message.text) 
                        ? MarkdownBody(
                            data: message.text,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: message.isUser 
                                    ? const Color(0xFFFFFFFF) 
                                    : (isDark ? const Color(0xFFE0E0E0) : Colors.black),
                                fontSize: 15,
                                height: 1.6,
                                letterSpacing: 0.2,
                              ),
                              code: TextStyle(
                                backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF6F8FA),
                                color: isDark ? const Color(0xFFE06C75) : const Color(0xFFD73A49),
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                              codeblockPadding: const EdgeInsets.all(12),
                              codeblockDecoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF6F8FA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE1E4E8),
                                ),
                              ),
                              blockquote: TextStyle(
                                color: message.isUser 
                                    ? const Color(0xFFCCCCCC) 
                                    : (isDark ? const Color(0xFFB0B0B0) : const Color(0xFF666666)),
                                fontSize: 15,
                              ),
                              h1: TextStyle(
                                color: message.isUser 
                                    ? const Color(0xFFFFFFFF) 
                                    : (isDark ? const Color(0xFFE0E0E0) : Colors.black),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              h2: TextStyle(
                                color: message.isUser 
                                    ? const Color(0xFFFFFFFF) 
                                    : (isDark ? const Color(0xFFE0E0E0) : Colors.black),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              h3: TextStyle(
                                color: message.isUser 
                                    ? const Color(0xFFFFFFFF) 
                                    : (isDark ? const Color(0xFFE0E0E0) : Colors.black),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              listBullet: TextStyle(
                                color: message.isUser 
                                    ? const Color(0xFFFFFFFF) 
                                    : (isDark ? const Color(0xFFE0E0E0) : Colors.black),
                              ),
                              strong: TextStyle(
                                color: message.isUser 
                                    ? const Color(0xFFFFFFFF) 
                                    : (isDark ? const Color(0xFFE0E0E0) : Colors.black),
                                fontWeight: FontWeight.bold,
                              ),
                              em: TextStyle(
                                color: message.isUser 
                                    ? const Color(0xFFFFFFFF) 
                                    : (isDark ? const Color(0xFFE0E0E0) : Colors.black),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            extensionSet: md.ExtensionSet(
                              md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                              [
                                md.EmojiSyntax(),
                                ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                              ],
                            ),
                          )
                        : Text(
                            message.text,
                            style: TextStyle(
                              color: message.isUser 
                                  ? const Color(0xFFFFFFFF) 
                                  : (isDark ? const Color(0xFFE0E0E0) : Colors.black),
                              fontSize: 15,
                              height: 1.6,
                              letterSpacing: 0.2,
                            ),
                                  : (isDark ? const Color(0xFFE0E0E0) : Colors.black),
                        fontSize: 15,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.status == MessageStatus.failed) ...[
                      Icon(
                        Icons.error_outline,
                        size: 14,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Failed',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '• Double tap to retry',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[600] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Text(
                        _formatTimestamp(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[600] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      onPressed: () => _copyMessage(context),
                      icon: const Icon(Icons.copy, size: 16),
                      color: isDark ? Colors.grey[600] : Colors.grey,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Copy message',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (message.isUser) const SizedBox(width: 48),
        ],
      ),
    );
  }

  /// Copies the message text to the system clipboard and shows a confirmation snackbar.
  /// 
  /// This method is triggered by long-pressing the message bubble or tapping the copy icon.
  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Message copied to clipboard'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green[700],
      ),
    );
  }

  /// Checks if the message text contains markdown formatting or code blocks.
  /// 
  /// Returns true if the text includes code blocks, inline code, bold/italic formatting,
  /// headers, or links. This determines whether to use MarkdownBody or plain Text widget.
  bool _hasCodeBlock(String text) {
    // Check if text contains markdown formatting
    return text.contains('```') || text.contains('`') || 
           text.contains('**') || text.contains('*') || 
           text.contains('#') || text.contains('[');
  }

  /// Builds the attachment preview widgets for messages with attached files.
  /// 
  /// Displays file name, type icon, and size for each attachment.
  /// Supports different file types (image, document, audio, etc.)
  Widget _buildAttachments(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: message.attachments!.map((attachment) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isUser
                  ? (isDark ? const Color(0xFF3A3A3A) : const Color(0xFF2B2B2B))
                  : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getFileIcon(attachment.type),
                  size: 24,
                  color: message.isUser 
                      ? Colors.white 
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      attachment.name,
                      style: TextStyle(
                        color: message.isUser 
                            ? Colors.white 
                            : (isDark ? Colors.grey[300] : Colors.black87),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${attachment.sizeInMB} MB',
                      style: TextStyle(
                        color: message.isUser 
                            ? Colors.white70 
                            : (isDark ? Colors.grey[500] : Colors.grey[600]),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Returns the appropriate icon for a given file type.
  /// 
  /// Supports: image, document, audio, and generic file types.
  IconData _getFileIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.video_file;
      case 'audio':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Formats the message timestamp into a human-readable relative time format.
  /// 
  /// Returns:
  /// - "Just now" for messages less than 60 seconds old
  /// - "Xm ago" for messages less than 60 minutes old
  /// - "Xh ago" for messages less than 24 hours old
  /// - "Xd ago" for messages less than 7 days old
  /// - "MMM d, y" formatted date for older messages
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }
}
