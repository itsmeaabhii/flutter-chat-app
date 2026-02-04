import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
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
                GestureDetector(
                  onLongPress: () => _copyMessage(context),
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
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser 
                            ? const Color(0xFFFFFFFF) 
                            : (isDark ? const Color(0xFFE0E0E0) : Colors.black),
                        fontSize: 15,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
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
          ),
          if (message.isUser) const SizedBox(width: 48),
        ],
      ),
    );
  }

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
}
