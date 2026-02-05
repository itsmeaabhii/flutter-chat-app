import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/message.dart';
import '../models/chat_session.dart';
import '../services/ai_service.dart';
import '../services/preference_service.dart';
import '../services/chat_history_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import 'settings_screen.dart';
import 'chat_history_screen.dart';

String _generateMessageId() => DateTime.now().millisecondsSinceEpoch.toString();

class ChatScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  
  const ChatScreen({super.key, this.onToggleTheme});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isTyping = false;
  String? _currentSessionId;
  List<MessageAttachment> _selectedAttachments = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {}); // Update UI when text changes
    });
    // Always start with a fresh chat - welcome message
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final hasApiKey = PreferenceService.hasApiKey();
    
    String welcomeText;
    if (hasApiKey) {
      welcomeText = "Ask me anything — GK, doubts, coding, daily life.";
    } else {
      welcomeText = "Ask me anything — GK, doubts, coding, daily life.\n\n💡 Add your OpenAI API key in settings to unlock AI responses.";
    }
    
    setSid: _generateMessageId(),
        tate(() {
      _messages.add(Message(
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    // Add user message
    setState(() {
      _mid: _generateMessageId(),
        essages.add(Message(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    // Get AI response
    try {
      String contextMessage = userMessage;
      if (attachments.isNotEmpty) {
        contextMessage += '\n[User attached ${attachments.length} file(s): ${attachments.map((a) => a.name).join(', ')}]';
      }
      
      final response = await AIService.sendMessage(contextMessage, _messages);

      setSid: _generateMessageId(),
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(Message(
          id: _generateMessageId(),
      setState(() {
        _messages.add(Message(
          text: "I'm sorry, I encountered an error. Could you try rephrasing your question?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    // Save conversation summary and history before clearing
    if (_messages.length >= 2) {
      AIService.saveConversationSummary(_messages);
      ChatHistoryService.saveSession(_messages);
    }
    
    setState(() {
      _messages.clear();
      _currentSessionId = null;
      _addWelcomeMessage();
    });
  }

  void _loadSession(ChatSession session) {
    setState(() {
      _messages.clear();
      _messages.addAll(session.messages);
      _currentSessionId = session.id;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.history, color: Colors.black, size: 24),
          onPressed: () async {
            final session = await Navigator.push<ChatSession>(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatHistoryScreen(),
              ),
            );
            if (session != null) {
              _loadSession(session);
            }
          },
          tooltip: 'Chat History',
        ),
        title: const Text(
          'Chat AI',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) async {
              if (value == 'new') {
                if (_messages.length >= 2) {
                  await ChatHistoryService.saveSession(_messages);
                }
                _clearChat();
              } else if (value == 'clear') {
                _clearChat();
              } else if (value == 'settings') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
                setState(() {
                  _messages.clear();
                  _addWelcomeMessage();
                });
              } else if (value == 'export_text') {
                _exportAsText();
              } else if (value == 'export_pdf') {
                _exportAsPDF();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 20),
                    SizedBox(width: 12),
                    Text('New Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Clear Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_text',
                child: Row(
                  children: [
                    Icon(Icons.text_snippet_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Export as Text'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Export as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return TypingIndicator();
                }
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          _buildInputArea(),
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        final newAttachments = result.files.map((file) {
          String fileType = 'other';
          final extension = file.extension?.toLowerCase() ?? '';
          
          if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
            fileType = 'image';
          } else if (['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'].contains(extension)) {
            filColumn(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasAttachments) _buildAttachmentPreview(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.attach_file,
                      color: Color(0xFF424242),
                      size: 22,
                    ),
                    onPressed: _pickFiles,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 12),
              } else if (['mp3', 'wav', 'aac', 'm4a'].contains(extension)) {
            fileType = 'audio';
          }

          return MessageAttachment(
            name: file.name,
            path: file.path ?? '',
            type: fileType,
            size: file.size,
          );
        }).toList();

        setState(() {
          _selectedAttachments.addAll(newAttachments);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Colors.red,
        ),
      );(hasText || hasAttachments) ? Colors.black : const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
                boxShadow: (hasText || hasAttachments)
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  color: (hasText || hasAttachments) ? Colors.white : const Color(0xFF9E9E9E),
                  size: 22,
                ),
                onPressed: _isTyping || (!hasText && !hasAttachments) ? null : _sendMessage,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedAttachments.length,
        itemBuilder: (context, index) {
          final attachment = _selectedAttachments[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getFileIcon(attachment.type),
                        size: 32,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          attachment.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeAttachment(index),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      case 'video':
        return Icons.video_file;
      case 'audio':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }      blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ask anything...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    hintStyle: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hasText ? Colors.black : const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
                boxShadow: hasText
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  color: hasText ? Colors.white : const Color(0xFF9E9E9E),
                  size: 22,
                ),
                onPressed: _isTyping || !hasText ? null : _sendMessage,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsText() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No messages to export')),
      );
      return;
    }

    try {
      final buffer = StringBuffer();
      buffer.writeln('Chat AI Conversation');
      buffer.writeln('Exported: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      for (var message in _messages) {
        final sender = message.isUser ? 'You' : 'AI';
        final time = DateFormat('HH:mm').format(message.timestamp);
        buffer.writeln('[$time] $sender:');
        buffer.writeln(message.text);
        
        if (message.attachments != null && message.attachments!.isNotEmpty) {
          buffer.writeln('Attachments: ${message.attachments!.map((a) => a.name).join(', ')}');
        }
        
        buffer.writeln();
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/chat_export_$timestamp.txt');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Chat AI Conversation',
        text: 'Exported conversation from Chat AI',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Conversation exported successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportAsPDF() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No messages to export')),
      );
      return;
    }

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Chat AI Conversation',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Text(
                  'Exported: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ),
              pw.Divider(),
              ..._messages.map((message) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: message.isUser 
                        ? pw.CrossAxisAlignment.end 
                        : pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: message.isUser 
                            ? pw.MainAxisAlignment.end 
                            : pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              color: message.isUser 
                                  ? PdfColors.black 
                                  : PdfColors.grey300,
                              borderRadius: pw.BorderRadius.circular(12),
                            ),
                            constraints: const pw.BoxConstraints(maxWidth: 400),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  message.isUser ? 'You' : 'AI',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: message.isUser 
                                        ? PdfColors.white 
                                        : PdfColors.grey700,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  message.text,
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    color: message.isUser 
                                        ? PdfColors.white 
                                        : PdfColors.black,
                                  ),
                                ),
                                if (message.attachments != null && message.attachments!.isNotEmpty)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 8),
                                    child: pw.Text(
                                      'Attachments: ${message.attachments!.map((a) => a.name).join(', ')}',
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        color: message.isUser 
                                            ? PdfColors.white70 
                                            : PdfColors.grey700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ];
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/chat_export_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Chat AI Conversation',
        text: 'Exported conversation from Chat AI',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('PDF exported successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
