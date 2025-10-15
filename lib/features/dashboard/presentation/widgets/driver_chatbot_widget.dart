import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/driver_chatbot_service.dart';
import '../../../../core/services/language_service.dart';
import 'language_selector.dart';

class DriverChatbotWidget extends StatefulWidget {
  const DriverChatbotWidget({Key? key}) : super(key: key);

  @override
  State<DriverChatbotWidget> createState() => _DriverChatbotWidgetState();
}

class _DriverChatbotWidgetState extends State<DriverChatbotWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DriverChatbotService _chatbotService = DriverChatbotService();
  final LanguageService _languageService = LanguageService();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _selectedLanguage = 'en'; // Default to English

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: _getWelcomeMessage(_selectedLanguage),
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  String _getWelcomeMessage(String language) {
    switch (language) {
      case 'si': // Sinhala
        return "🚛 ආයුබෝවන්! මම ඔබේ බුද්ධිමත් රියදුරු සහායකයා!\n\n"
               "🎯 **මුල් විශේෂඥතාව:**\n"
               "• ගමන් මාර්ග සහ ගමන් කිරීම\n"
               "• වාහන නඩත්තු උපදෙස්\n"
               "• ඉන්ධන කාර්යක්ෂමතාව\n"
               "• ආරක්ෂක මාර්ගෝපදේශ\n"
               "• භාණ්ඩ කළමනාකරණය\n\n"
               "💬 **ඕනෑම දෙයක් අසන්න!** රියදුරු, ජීවිතය, හෝ සාමාන්‍ය කරුණු ගැන.";
      case 'ta': // Tamil
        return "🚛 வணக்கம்! நான் உங்கள் புத்திசாலி ஓட்டுநர் உதவியாளர்!\n\n"
               "🎯 **முதன்மை நிபுணத்துவம்:**\n"
               "• பயண வழிகள் மற்றும் வழிசெலுத்தல்\n"
               "• வாகன பராமரிப்பு ஆலோசனை\n"
               "• எரிபொருள் திறன்\n"
               "• பாதுகாப்பு வழிகாட்டுதல்கள்\n"
               "• சரக்கு நிர்வாகம்\n\n"
               "💬 **எதையும் கேளுங்கள்!** ஓட்டுதல், வாழ்க்கை அல்லது பொதுவான விஷயங்கள் பற்றி.";
      default: // English
        return "🚛 Hello! I'm your intelligent Driver Assistant!\n\n"
               "🎯 **PRIMARY EXPERTISE:**\n"
               "• Route optimization & navigation\n"
               "• Vehicle maintenance tips\n"
               "• Fuel efficiency advice\n"
               "• Safety guidelines & traffic rules\n"
               "• Load management & cargo handling\n\n"
               "🧠 **I CAN ALSO HELP WITH:**\n"
               "• General questions & advice\n"
               "• Weather-related driving tips\n"
               "• Career development\n\n"
               "💬 **ASK ME ANYTHING!** Try: 'What's the weather?' or 'Driving tips?'";
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await _chatbotService.getChatHistory();
      setState(() {
        _messages.addAll(history.map((chat) => ChatMessage(
          text: chat['userMessage'],
          isUser: true,
          timestamp: chat['timestamp']?.toDate() ?? DateTime.now(),
        )));
        _messages.addAll(history.map((chat) => ChatMessage(
          text: chat['aiResponse'],
          isUser: false,
          timestamp: chat['timestamp']?.toDate() ?? DateTime.now(),
        )));
      });
      _scrollToBottom();
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _chatbotService.generateResponse(userMessage);
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, I encountered an error. Please try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getInputHint(String language) {
    switch (language) {
      case 'si':
        return 'ඕනෑම දෙයක් අසන්න - රියදුරු, සාමාන්‍ය ප්‍රශ්න, උපදෙස්...';
      case 'ta':
        return 'எதையும் கேளுங்கள் - ஓட்டுதல், பொதுவான கேள்விகள், ஆலோசனை...';
      default:
        return 'Ask me anything - driving, general questions, advice...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFF9800),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Driver Assistant',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Language Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: LanguageSelectorWidget(
                    currentLanguage: _selectedLanguage,
                    onLanguageChanged: (newLanguage) {
                      setState(() {
                        _selectedLanguage = newLanguage;
                        // Update welcome message in new language
                        if (_messages.isNotEmpty && !_messages.first.isUser) {
                          _messages[0] = ChatMessage(
                            text: _getWelcomeMessage(_selectedLanguage),
                            isUser: false,
                            timestamp: _messages[0].timestamp,
                          );
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _getInputHint(_selectedLanguage),
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF9800),
                  child: IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: 
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFFFF9800),
              radius: 16,
              child: const Icon(Icons.local_shipping, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? const Color(0xFFFF9800)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 16,
              child: const Icon(Icons.person, color: Colors.black54, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFF9800),
            radius: 16,
            child: const Icon(Icons.local_shipping, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOut,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}