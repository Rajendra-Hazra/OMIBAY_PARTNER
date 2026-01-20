import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> get _initialMessages => [
    {
      'isMe': false,
      'text': AppLocalizations.of(context)!.chatWelcome,
      'time': '10:00 AM',
    },
  ];

  late List<Map<String, dynamic>> _messages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messages = _initialMessages;
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isMe': true,
        'text': _messageController.text.trim(),
        'time': '10:05 AM', // In a real app, this would be dynamic
      });
      _messageController.clear();
    });

    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate bot response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'isMe': false,
            'text': AppLocalizations.of(context)!.chatResponse,
            'time': '10:06 AM',
          });
        });
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive values
    final horizontalPadding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final headingFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(14.0, 16.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 13.0);
    final iconSize = (screenWidth * 0.06).clamp(24.0, 32.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, headingFontSize, smallFontSize, iconSize),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(horizontalPadding),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(
                    message,
                    bodyFontSize,
                    smallFontSize,
                  );
                },
              ),
            ),
            _buildMessageInput(bodyFontSize, iconSize),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double headingFontSize,
    double smallFontSize,
    double iconSize,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: iconSize * 0.7),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Container(
            width: (iconSize * 1.5).clamp(36.0, 48.0),
            height: (iconSize * 1.5).clamp(36.0, 48.0),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'images/logo.png',
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.business_center,
                size: iconSize * 0.7,
                color: AppColors.primaryOrangeStart,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.omibaySupport,
                  style: TextStyle(
                    fontSize: headingFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E), // Green dot
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.online,
                      style: TextStyle(
                        fontSize: smallFontSize,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    double bodyFontSize,
    double smallFontSize,
  ) {
    final bool isMe = message['isMe'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primaryOrangeStart
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
            ),
            child: Text(
              message['text'],
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: bodyFontSize,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message['time'],
            style: TextStyle(
              fontSize: smallFontSize - 2,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(double bodyFontSize, double iconSize) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(fontSize: bodyFontSize),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.typeYourMessage,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: bodyFontSize,
                    color: Colors.grey,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primaryOrangeStart,
            radius: (iconSize * 0.8).clamp(20.0, 24.0),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: iconSize * 0.7),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
