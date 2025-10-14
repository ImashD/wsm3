import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();
  
  // Replace with your NEW Gemini API key from https://aistudio.google.com/
  static const String _geminiApiKey = 'AIzaSyDw6VguIZgfb6wsaC1NTD5jQo7tc3T_5xo';  // ✅ UPDATED!
  late final GenerativeModel _model;

  void initialize() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',  // Correct model name
      apiKey: _geminiApiKey,
    );
  }

  /// Get farmer's data from database for context
  Future<Map<String, dynamic>> _getFarmerContext() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};

    try {
      // Get farmer data
      final farmerDoc = await _firestore.collection('farmers').doc(uid).get();
      final userData = await _firestore.collection('users').doc(uid).get();
      
      Map<String, dynamic> context = {};
      
      if (farmerDoc.exists) {
        context['farmer'] = farmerDoc.data() ?? {};
      }
      
      if (userData.exists) {
        context['user'] = userData.data() ?? {};
      }

      // Get recent activities (if you have them)
      final recentActivities = await _firestore
          .collection('farmer_activities')
          .where('farmerId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();
      
      context['recent_activities'] = recentActivities.docs
          .map((doc) => doc.data())
          .toList();

      return context;
    } catch (e) {
      print('Error getting farmer context: $e');
      return {};
    }
  }

  /// Generate AI response with farmer context
  Future<String> generateResponse(String userMessage) async {
    try {
      final context = await _getFarmerContext();
      
      // Create a comprehensive prompt with farmer data
      final prompt = _buildPrompt(userMessage, context);
      
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Sorry, I couldn\'t generate a response.';
    } catch (e) {
      print('Error generating AI response: $e');
      return 'Sorry, I\'m having trouble right now. Please try again later.';
    }
  }

  /// Build context-aware prompt for the AI
  String _buildPrompt(String userMessage, Map<String, dynamic> context) {
    final farmerData = context['farmer'] as Map<String, dynamic>? ?? {};
    final userData = context['user'] as Map<String, dynamic>? ?? {};
    final activities = context['recent_activities'] as List? ?? [];

    return '''
You are an AI assistant for a farmer management app. You help farmers with agricultural advice, crop management, and platform features.

FARMER CONTEXT:
- Name: ${farmerData['name'] ?? 'Unknown'}
- Farm Location: ${farmerData['farmLocation'] ?? 'Not specified'}
- Crop Type: ${farmerData['cropType'] ?? 'Not specified'}
- Farm Size: ${farmerData['farmSize'] ?? 'Not specified'}
- Phone: ${farmerData['phone'] ?? 'Not provided'}

RECENT ACTIVITIES:
${activities.isEmpty ? 'No recent activities' : activities.map((a) => '- ${a.toString()}').join('\n')}

GUIDELINES:
1. Provide helpful, accurate agricultural advice
2. Reference the farmer's specific crops and location when relevant
3. Suggest platform features that might help them
4. Keep responses concise but informative
5. If you don't know something specific, suggest they consult local agricultural experts
6. Be friendly and encouraging

USER QUESTION: $userMessage

Please provide a helpful response:
''';
  }

  /// Save chat message to Firestore
  Future<void> saveChatMessage({
    required String message,
    required String response,
    required bool isUser,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('chat_history')
          .doc(uid)
          .collection('messages')
          .add({
        'id': _uuid.v4(),
        'message': isUser ? message : response,
        'isUser': isUser,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving chat message: $e');
    }
  }

  /// Get chat history for farmer
  Stream<List<ChatMessage>> getChatHistory() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('chat_history')
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }
}

/// Chat message model
class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: data['id'] ?? '',
      message: data['message'] ?? '',
      isUser: data['isUser'] ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}