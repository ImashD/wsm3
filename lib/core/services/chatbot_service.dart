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
  static const String _geminiApiKey =
      'AIzaSyDw6VguIZgfb6wsaC1NTD5jQo7tc3T_5xo'; // ✅ UPDATED!

  GenerativeModel? _model;
  bool _isInitialized = false;
  static const List<String> _geminiModelCandidates = [
    'gemini-2.5-pro',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
  ];
  static const RequestOptions _apiV1 = RequestOptions(apiVersion: 'v1');
  String? _activeModelName;
  int _currentModelIndex = 0;

  void initialize() {
    if (_isInitialized && _model != null) return;

    final candidates = _orderedCandidateIndexes();
    if (candidates.isEmpty) {
      print('❌ No Gemini models configured.');
      return;
    }

    final initialIndex = candidates.first;
    _useModel(_geminiModelCandidates[initialIndex]);
    _currentModelIndex = initialIndex;
  }

  List<int> _orderedCandidateIndexes() {
    if (_geminiModelCandidates.isEmpty) {
      return const <int>[];
    }

    final indexes = <int>[];

    if (_currentModelIndex >= 0 &&
        _currentModelIndex < _geminiModelCandidates.length) {
      indexes.add(_currentModelIndex);
    }

    for (var i = 0; i < _geminiModelCandidates.length; i++) {
      if (i != _currentModelIndex) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  void _useModel(String modelName) {
    _model = GenerativeModel(
      model: modelName,
      apiKey: _geminiApiKey,
      requestOptions: _apiV1,
    );
    _isInitialized = true;
    _activeModelName = modelName;
    print('🔧 Using Gemini model: $modelName');
  }

  void _resetActiveModel() {
    _model = null;
    _isInitialized = false;
    _activeModelName = null;
  }

  /// Get farmer's data from database for context
  Future<Map<String, dynamic>> _getFarmerContext() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};

    try {
      // Get farmer data
      final farmerDoc = await _firestore.collection('farmers').doc(uid).get();
      final userDoc = await _firestore.collection('users').doc(uid).get();

      Map<String, dynamic> context = {};

      if (farmerDoc.exists) {
        context['farmer'] = farmerDoc.data() ?? {};
      }

      if (userDoc.exists) {
        context['user'] = userDoc.data() ?? {};
      }

      // Get recent activities (if you have them)
      try {
        final recentActivities = await _firestore
            .collection('farmer_activities')
            .where('farmerId', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();

        context['recent_activities'] = recentActivities.docs
            .map((doc) => doc.data())
            .toList();
      } on FirebaseException catch (e) {
        if (e.code == 'failed-precondition') {
          // Composite index not available. Fallback without order to avoid crash.
          final fallbackActivities = await _firestore
              .collection('farmer_activities')
              .where('farmerId', isEqualTo: uid)
              .limit(5)
              .get();

          context['recent_activities'] = fallbackActivities.docs
              .map((doc) => doc.data())
              .toList();

          context['index_warning'] = true;
        } else {
          print('Error getting farmer activities: ${e.message}');
        }
      }

      return context;
    } catch (e) {
      print('Error getting farmer context: $e');
      return {};
    }
  }

  /// Generate AI response with farmer context
  Future<String> generateResponse(String userMessage) async {
    Map<String, dynamic> context = const <String, dynamic>{};

    try {
      if ((_model == null || !_isInitialized) &&
          _geminiModelCandidates.isNotEmpty) {
        initialize();
      }

      context = await _getFarmerContext();
      print('📊 Retrieved farmer context: ${context.keys.toList()}');

      if (_geminiModelCandidates.isEmpty) {
        print('⚠️ No Gemini model candidates available.');
        return _buildFallbackResponse(userMessage, context);
      }

      final prompt = _buildPrompt(userMessage, context);
      final candidateIndexes = _orderedCandidateIndexes();

      for (final index in candidateIndexes) {
        final modelName = _geminiModelCandidates[index];

        if (_activeModelName != modelName || _model == null) {
          _useModel(modelName);
        }

        print('📝 Sending prompt to Gemini model $modelName...');

        try {
          final response = await _model!.generateContent([
            Content.text(prompt),
          ]);
          final aiText = response.text?.trim();

          if (aiText == null || aiText.isEmpty) {
            print('⚠️ Empty response from $modelName, trying next candidate');
            continue;
          }

          final previewLength = aiText.length > 80 ? 80 : aiText.length;
          print(
            '✅ Got AI response from $modelName: ${aiText.substring(0, previewLength)}...',
          );

          _currentModelIndex = index;
          return aiText;
        } on GenerativeAISdkException catch (e) {
          final message = e.message ?? e.toString();

          if (message.contains('not found') ||
              message.contains('unsupported') ||
              message.contains('permission') ||
              message.contains('Permission') ||
              message.contains('denied') ||
              message.contains('UNAVAILABLE') ||
              message.contains('overloaded') ||
              message.contains('503') ||
              message.contains('429') ||
              message.contains('quota')) {
            print(
              '⚠️ Model $modelName unavailable ($message). Trying next candidate.',
            );
            _resetActiveModel();
            _currentModelIndex = index + 1;
            continue;
          }

          print('❌ Gemini SDK error with $modelName: $message');
          return _buildFallbackResponse(userMessage, context);
        } catch (e) {
          print('❌ Unexpected error with $modelName: $e');
          return _buildFallbackResponse(userMessage, context);
        }
      }

      print('⚠️ All Gemini models unavailable, using fallback.');
      return _buildFallbackResponse(userMessage, context);
    } catch (e) {
      print('❌ Error generating AI response: $e');

      if (context.isNotEmpty) {
        return _buildFallbackResponse(userMessage, context);
      }

      try {
        final recoveryContext = await _getFarmerContext();
        return _buildFallbackResponse(userMessage, recoveryContext);
      } catch (fallbackError) {
        print('❌ Error in fallback: $fallbackError');
        return 'Sorry, I\'m having trouble right now. Please try again later.';
      }
    }
  }

  /// Fallback response when Gemini is unavailable
  String _buildFallbackResponse(
    String userMessage,
    Map<String, dynamic> context,
  ) {
    final farmerData = context['farmer'] as Map<String, dynamic>? ?? {};
    final userData = context['user'] as Map<String, dynamic>? ?? {};
    final activities =
        (context['recent_activities'] as List?)?.cast<Map<String, dynamic>>() ??
        const [];
    final buffer = StringBuffer();

    if (farmerData.isEmpty && userData.isEmpty) {
      buffer
        ..writeln("I'm still gathering information about your farm.")
        ..writeln('Please make sure your profile is complete and try again.');
      return buffer.toString();
    }

    buffer.writeln('Here\'s what I can share right now:');

    if (farmerData.isNotEmpty) {
      buffer.writeln(
        '- Name: ${farmerData['name'] ?? userData['name'] ?? 'Not available'}',
      );
      buffer.writeln(
        '- Location: ${farmerData['farmLocation'] ?? 'Not specified'}',
      );
      buffer.writeln(
        '- Crop focus: ${farmerData['cropType'] ?? 'Not specified'}',
      );
      buffer.writeln(
        '- Farm size: ${farmerData['farmSize'] ?? 'Not specified'}',
      );
    }

    if (activities.isNotEmpty) {
      buffer.writeln('\nRecent activities:');
      for (final activity in activities) {
        final title = activity['title'] ?? activity['type'] ?? 'Activity';
        final detail = activity['description'] ?? activity['notes'] ?? '';
        buffer.writeln('• $title ${detail.isEmpty ? '' : '- $detail'}');
      }
    }

    if (context['index_warning'] == true) {
      buffer
        ..writeln(
          '\n⚠️ Tip: To unlock full history sorting, add the Firestore composite index suggested in the console logs.',
        )
        ..writeln('I\'ll keep working with the latest entries meanwhile.');
    }

    buffer.writeln('\nNeed anything specific? You can ask me about:');
    buffer.writeln('• Crop care and fertilizer schedules');
    buffer.writeln('• Weather preparation tips');
    buffer.writeln('• Market price tracking inside the app');

    return buffer.toString();
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
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList(),
        );
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
