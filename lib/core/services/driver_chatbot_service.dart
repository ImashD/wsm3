import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'language_service.dart';

class DriverChatbotService {
  static const String _apiKey = 'AIzaSyDw6VguIZgfb6wsaC1NTD5jQo7tc3T_5xo';  // ✅ UPDATED!
  late final GenerativeModel _model;
  final LanguageService _languageService = LanguageService();
  
  DriverChatbotService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',  // Correct model name
      apiKey: _apiKey,
    );
  }

  Future<String> generateResponse(String userMessage) async {
    // 🌍 Step 1: Detect user's language (outside try block)
    String userLanguage = 'en'; // Default to English
    
    try {
      userLanguage = await _languageService.detectLanguage(userMessage);
      print('🔍 Detected language: $userLanguage');
      
      // 🔄 Step 2: Translate user message to English for processing (if needed)
      String englishMessage = userMessage;
      if (userLanguage != 'en') {
        englishMessage = await _languageService.translateText(userMessage, 'en');
        print('🔄 Translated to English: $englishMessage');
      }
      
      // Get driver context for personalized responses
      final driverContext = await _getDriverContext();
      
      // Create a comprehensive multilingual prompt
      final prompt = '''
You are an intelligent AI assistant for a Sri Lankan Driver in a workforce management system. 

IMPORTANT: The user spoke in ${_languageService.getLanguageName(userLanguage)}.
You MUST respond in the SAME language the user used.

Driver Context:
$driverContext

User's Original Message (${_languageService.getLanguageName(userLanguage)}): $userMessage
English Translation: $englishMessage

Language Instructions:
- If user spoke in Sinhala (සිංහල): Respond in Sinhala
- If user spoke in Tamil (தமிழ்): Respond in Tamil  
- If user spoke in English: Respond in English
- Use appropriate cultural context for Sri Lankan drivers

Content Guidelines:
1. PRIMARY EXPERTISE: Transportation, logistics, vehicle maintenance, driving
2. SECONDARY CAPABILITIES: General knowledge, weather, calculations, advice
3. PERSONALITY: Friendly, professional, supportive
4. Be culturally sensitive to Sri Lankan context

ALWAYS respond in the user's original language: ${_languageService.getLanguageName(userLanguage)}
```

Instructions:
1. PRIMARY EXPERTISE: Transportation, logistics, vehicle maintenance, driving, and workforce management
2. SECONDARY CAPABILITIES: General knowledge, weather, current events, basic calculations, time, dates, general advice
3. PERSONALITY: Friendly, professional, supportive, and encouraging
4. RESPONSE STYLE: Conversational, practical, and helpful

Guidelines for responses:
- If the question is about driving/transportation: Provide expert, detailed advice
- If the question is general knowledge: Answer helpfully but briefly, then suggest how it might relate to driving
- If the question is about weather: Relate it to driving conditions and safety
- If the question is about time/dates: Help with scheduling and trip planning
- If the question is casual/personal: Be friendly and supportive
- If the question is about other work: Give general advice but highlight how driver skills transfer
- If the question is unclear: Ask for clarification politely

ALWAYS end transportation-related responses with a helpful driving tip.
For non-transportation topics, briefly answer then offer to help with driving-related questions.

Keep responses conversational (150-250 words), use emojis appropriately, and be encouraging.

Examples of good responses:
- Weather question: "Today's weather + how it affects driving + safety tip"
- Math question: "Answer + how this might help with fuel calculations"
- General advice: "Supportive response + relate to driver experience if possible"
- Random fact: "Interesting response + transition to driving topic"

Be smart, helpful, and always remember you're assisting a hardworking driver in Sri Lanka.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      String aiResponse = response.text ?? 'I apologize, but I could not generate a response at the moment.';
      
      // 🌍 Step 3: Translate AI response back to user's language (if needed)
      if (userLanguage != 'en') {
        print('🔄 Translating response to ${_languageService.getLanguageName(userLanguage)}');
        aiResponse = await _languageService.translateText(aiResponse, userLanguage);
      }
      
      // Save conversation to Firestore (save in user's original language)
      await _saveChatMessage(userMessage, aiResponse);
      
      return aiResponse;
    } catch (e) {
      print('Error generating response: $e');
      
      // 🔄 Provide multilingual fallback responses
      String fallbackResponse = await _getMultilingualFallbackResponse(userMessage, userLanguage);
      
      // Try to save the fallback response
      try {
        await _saveChatMessage(userMessage, fallbackResponse);
      } catch (saveError) {
        print('Error saving fallback message: $saveError');
      }
      
      return fallbackResponse;
    }
  }

  /// 🌍 Get fallback response in user's language
  Future<String> _getMultilingualFallbackResponse(String userMessage, String userLanguage) async {
    // First detect language if not provided
    if (userLanguage.isEmpty) {
      userLanguage = await _languageService.detectLanguage(userMessage);
    }
    
    // Get fallback response based on language
    switch (userLanguage) {
      case 'si': // Sinhala
        return _getSinhalaFallbackResponse(userMessage);
      case 'ta': // Tamil
        return _getTamilFallbackResponse(userMessage);
      default: // English
        return _getIntelligentFallbackResponse(userMessage);
    }
  }

  /// 🇱🇰 Sinhala fallback responses
  String _getSinhalaFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // Basic greetings
    if (message.contains('හලෝ') || message.contains('ආයුබෝවන්')) {
      return "🙏 ආයුබෝවන්! මම ඔබේ රියදුරු සහායකයා. මට ඔබට අවශ්‍ය ඕනෑම දෙයක් ගැන උදව් කළ හැක - රියදුරු, ගමන් කිරීම, හෝ සාමාන්‍ය ප්‍රශ්න. 🚗";
    }
    
    // Weather questions
    if (message.contains('කාලගුණය') || message.contains('වැස්ස') || message.contains('අව්ව')) {
      return "🌤️ කාලගුණ තත්වය ගැන සැබෑ කාලීන දත්ත මා සතුව නැත, නමුත් රියදුරුවන්ට වැදගත් කරුණු:\n\n• ගමන් කිරීමට පෙර කාලගුණය පරීක්ෂා කරන්න\n• වැස්සේදී වේගය අඩු කරන්න\n• අදුරේ ලයිට් භාවිතා කරන්න\n• ආරක්ෂිතව ගමන් කරන්න! 🚗";
    }
    
    // Time questions
    if (message.contains('වේලාව') || message.contains('කාලය')) {
      return "⏰ නිශ්චිත වේලාව මා සතුව නැත, නමුත් ගමන් සැලසුම් සඳහා:\n\n• සෑම ගමනකටම අමතර වේලාව තබා ගන්න\n• රථවාහන තදබදය සලකා බලන්න\n• විශ්‍රාම කිරීමට වේලාව තබන්න\nරැකවන්න! 🚗";
    }
    
    // Default response
    return "🤖 මම ඔබේ රියදුරු AI සහායකයා! මට උදව් කළ හැකි කරුණු:\n\n🚗 රියදුරු සහ ගමන් කිරීම\n🛠️ වාහන නඩත්තු\n🌤️ කාලගුණ සහ ආරක්ෂාව\n💭 සාමාන්‍ය උපදෙස්\n\nඅසන්න! 😊";
  }

  /// 🇱🇰 Tamil fallback responses  
  String _getTamilFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // Basic greetings
    if (message.contains('வணக்கம்') || message.contains('ஹலோ')) {
      return "🙏 வணக்கம்! நான் உங்கள் ஓட்டுநர் உதவியாளர். ஓட்டுதல், பயணம், அல்லது பொதுவான கேள்விகள் - எதையும் கேளுங்கள்! 🚗";
    }
    
    // Weather questions
    if (message.contains('வானிலை') || message.contains('மழை') || message.contains('வெயில்')) {
      return "🌤️ நேரடி வானிலை தகவல் என்னிடம் இல்லை, ஆனால் ஓட்டுநர்களுக்கு முக்கியமானவை:\n\n• பயணத்திற்கு முன் வானிலையை சரிபார்க்கவும்\n• மழையில் வேகத்தை குறைக்கவும்\n• இருட்டில் விளக்குகளை பயன்படுத்தவும்\n• பாதுகாப்பாக ஓட்டுங்கள்! 🚗";
    }
    
    // Time questions
    if (message.contains('நேரம்') || message.contains('கால்')) {
      return "⏰ சரியான நேரம் என்னிடம் இல்லை, ஆனால் பயண திட்டமிடலுக்கு:\n\n• ஒவ்வொரு பயணத்திற்கும் கூடுதல் நேரம் வைத்துக்கொள்ளுங்கள்\n• போக்குவரத்து நெரிசலை கருத்தில் கொள்ளுங்கள்\n• ஓய்வு எடுக்க நேரம் வைக்கவும்\nஎச்சரிக்கையாக இருங்கள்! 🚗";
    }
    
    // Default response
    return "🤖 நான் உங்கள் ஓட்டுநர் AI உதவியாளர்! என்னால் உதவ முடியும்:\n\n🚗 ஓட்டுதல் மற்றும் பயணம்\n🛠️ வாகன பராமரிப்பு\n🌤️ வானிலை மற்றும் பாதுகாப்பு\n💭 பொதுவான ஆலோசனை\n\nகேளுங்கள்! 😊";
  }

  String _getIntelligentFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // Weather-related questions
    if (message.contains('weather') || message.contains('rain') || message.contains('sunny') || message.contains('cloudy')) {
      return "🌤️ I don't have real-time weather data, but here's what's important for drivers:\n\n• Check weather before trips\n• Reduce speed in rain (30-40% slower)\n• Use headlights in heavy rain\n• Keep extra distance in wet conditions\n• Have emergency kit ready\n\nFor current weather, check your phone's weather app. Drive safely! 🚗";
    }
    
    // Time/Date questions
    if (message.contains('time') || message.contains('date') || message.contains('today') || message.contains('tomorrow')) {
      final now = DateTime.now();
      return "⏰ Current time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}\nToday: ${now.day}/${now.month}/${now.year}\n\n📅 Planning trips? Remember:\n• Avoid rush hours (7-9 AM, 5-7 PM)\n• Plan breaks every 2 hours\n• Check traffic before leaving\n• Schedule pickup/delivery times wisely\n\nNeed help planning your route schedule?";
    }
    
    // Math/Calculation questions
    if (message.contains('calculate') || message.contains('math') || message.contains('cost') || message.contains('distance')) {
      return "🧮 I can help with basic calculations!\n\nFor driving calculations:\n• Fuel cost = Distance ÷ Mileage × Fuel price\n• Trip time = Distance ÷ Speed + stops\n• Daily earnings = Trips × Rate - Fuel cost\n• Maintenance budget = 10-15% of earnings\n\nWhat specific calculation do you need help with? 📊";
    }
    
    // Personal/Motivational questions
    if (message.contains('how are you') || message.contains('hello') || message.contains('hi') || message.contains('good morning') || message.contains('good evening')) {
      return "👋 Hello there! I'm doing great, thank you for asking!\n\nI'm here to help you succeed as a driver. Whether you need:\n• Route planning advice\n• Vehicle maintenance tips\n• Fuel efficiency guidance\n• Safety reminders\n• Dashboard feature help\n\nI'm ready to assist! How's your driving day going? Any challenges I can help you tackle? 🚛💪";
    }
    
    // Business/Money questions
    if (message.contains('money') || message.contains('earn') || message.contains('income') || message.contains('business')) {
      return "💰 Great question about earnings!\n\nTo maximize your income as a driver:\n• Accept trips during peak hours\n• Maintain good customer ratings\n• Keep vehicle well-maintained\n• Plan efficient routes\n• Track expenses for tax purposes\n• Build regular customer relationships\n\nRemember: Professional service = better tips and repeat customers! Want specific tips for increasing your earnings? 📈";
    }
    
    // Technology questions
    if (message.contains('phone') || message.contains('app') || message.contains('technology') || message.contains('internet')) {
      return "📱 Technology is a driver's best friend!\n\nEssential apps for drivers:\n• GPS navigation (Google Maps/Waze)\n• Fuel price comparison apps\n• Weather apps\n• This workforce management app\n• Banking apps for payments\n\nTech tips:\n• Keep phone charged (car charger essential)\n• Use hands-free for calls\n• Download offline maps for backup\n\nNeed help with any specific app or tech issue? 🔧";
    }
    
    // General advice/life questions
    if (message.contains('advice') || message.contains('help') || message.contains('problem') || message.contains('stress')) {
      return "🤝 I'm here to help!\n\nAs a driver, you face unique challenges. Remember:\n• Take regular breaks to stay alert\n• Deep breathing helps with traffic stress\n• Maintain work-life balance\n• Your safety comes first, always\n• Every day is a chance to provide great service\n\nDriving builds patience, problem-solving skills, and independence - valuable life skills! What specific situation can I help you with? 💪😊";
    }
    
    // Food/Health questions
    if (message.contains('food') || message.contains('eat') || message.contains('health') || message.contains('tired')) {
      return "🍎 Health is crucial for safe driving!\n\nDriver wellness tips:\n• Stay hydrated (carry water bottle)\n• Avoid heavy meals before driving\n• Healthy snacks: fruits, nuts, energy bars\n• Stretch during breaks\n• Get adequate sleep (7-8 hours)\n• Regular eye checkups\n\nGood health = better focus = safer driving = more earnings! Need specific advice about staying healthy on the road? 🏥";
    }
    
    // Route and navigation (original)
    if (message.contains('route') || message.contains('navigation') || message.contains('direction')) {
      return "🗺️ For route planning in Sri Lanka:\n\n• Use Google Maps for real-time traffic\n• Plan routes to avoid rush hours (7-9 AM, 5-7 PM)\n• Consider toll roads for faster travel\n• Keep emergency contacts handy\n• Check road conditions before long trips\n\nPopular routes: Colombo-Kandy (A1), Colombo-Galle (A2), Colombo-Negombo (A3)\n\n💡 Pro tip: Always have a backup route planned!";
    }
    
    // Vehicle maintenance (enhanced)
    if (message.contains('maintenance') || message.contains('service') || message.contains('repair')) {
      return "🔧 Vehicle Maintenance Tips:\n\n• Check engine oil every 2 weeks\n• Monitor tire pressure monthly\n• Service every 5,000-10,000 km\n• Check brakes regularly\n• Clean air filter monthly\n• Inspect lights and indicators\n• Keep spare parts handy\n\nFind authorized service centers in your area for best results.\n\n💡 Remember: Prevention is cheaper than repair!";
    }
    
    // Learning/Education questions
    if (message.contains('learn') || message.contains('study') || message.contains('skill') || message.contains('improve')) {
      return "📚 Great attitude! Continuous learning makes better drivers.\n\nSkills to develop:\n• Defensive driving techniques\n• Customer service excellence\n• Basic vehicle troubleshooting\n• Efficient route planning\n• Digital literacy (apps, GPS)\n• First aid basics\n\nYour driving experience teaches valuable life skills: patience, responsibility, problem-solving! What would you like to learn more about? 🎓";
    }
    
    // Family/Personal life questions
    if (message.contains('family') || message.contains('wife') || message.contains('children') || message.contains('home')) {
      return "👨‍👩‍👧‍👦 Family is everything! Balancing work and family as a driver:\n\n• Set clear work hours when possible\n• Keep family updated on your location\n• Video call during breaks\n• Plan family time around work schedule\n• Save for family goals\n• Stay safe - they need you home\n\nYour hard work supports your loved ones. They're proud of you! Need tips on work-life balance? 💝";
    }
    
    // Fun/Entertainment questions
    if (message.contains('music') || message.contains('song') || message.contains('radio') || message.contains('entertainment')) {
      return "🎵 Music makes driving more enjoyable!\n\nSafe listening tips:\n• Keep volume at moderate level\n• Choose calming music for long trips\n• Upbeat songs for alertness\n• Avoid distracting content\n• News/talk radio for traffic updates\n• Podcasts for learning while driving\n\nMusic can reduce stress and make work more pleasant! What's your favorite driving playlist? 🎧";
    }
    
    // General conversation starters
    if (message.contains('tell me') || message.contains('what about') || message.contains('opinion') || message.contains('think')) {
      return "🤔 I'd love to share thoughts! I'm designed to help drivers succeed.\n\nInteresting driving facts:\n• Sri Lanka has beautiful scenic routes\n• Driving builds mental strength and independence\n• Professional drivers are essential for the economy\n• Every trip is a chance to provide excellent service\n• Technology is making driving safer and more efficient\n\nWhat specific topic interests you? I can share more insights! 🚗✨";
    }
    
    // Default intelligent response for any other question
    return "🤖 That's an interesting question! While I specialize in helping drivers succeed, I'm always eager to assist.\n\nI can help you with:\n• ✅ Transportation & logistics\n• ✅ Vehicle maintenance\n• ✅ Route planning\n• ✅ Safety tips\n• ✅ General advice\n• ✅ Calculations\n• ✅ Time management\n• ✅ Career guidance\n\nCould you tell me more about what you need help with? I'll do my best to give you a helpful answer! 😊🚛";
  }

  Future<String> _getDriverContext() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return 'Driver not currently logged in';

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        return 'New driver - please complete your profile in the dashboard';
      }

      final userData = userDoc.data()!;
      final driverDetails = userData['driverDetails'] as Map<String, dynamic>?;
      
      // Build context string with available information
      final context = StringBuffer();
      context.writeln('Driver Profile:');
      
      if (driverDetails != null) {
        context.writeln('- Name: ${driverDetails['fullName'] ?? 'Not set'}');
        context.writeln('- Vehicle Type: ${driverDetails['vehicleType'] ?? 'Not specified'}');
        context.writeln('- Vehicle Number: ${driverDetails['vehicleno'] ?? 'Not set'}');
        context.writeln('- License ID: ${driverDetails['license'] ?? 'Not provided'}');
        context.writeln('- Driving Experience: ${driverDetails['experience'] ?? 0} years');
        context.writeln('- Currently Available: ${driverDetails['available'] == true ? 'Yes' : 'No'}');
        context.writeln('- Phone: ${driverDetails['phone'] ?? 'Not provided'}');
        context.writeln('- NIC: ${driverDetails['nic'] ?? 'Not provided'}');
      } else {
        context.writeln('- Profile incomplete - please update your driver details');
      }

      // Try to get recent activity (more flexible approach)
      try {
        // Simple activity check without complex queries
        context.writeln('\nSystem Info:');
        context.writeln('- Account created and active');
        context.writeln('- Access to trip management features');
      } catch (activityError) {
        print('Activity data not available: $activityError');
      }

      // Add dashboard context
      context.writeln('\nDashboard Status:');
      context.writeln('- Role: Driver');
      context.writeln('- System: Workforce Management Platform');
      context.writeln('- Features: Trip requests, earnings tracking, profile management');

      return context.toString();
    } catch (e) {
      print('Error getting driver context: $e');
      return 'Driver context temporarily unavailable - basic assistance mode active';
    }
  }

  Future<void> _saveChatMessage(String userMessage, String aiResponse) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print('Cannot save chat message: User not logged in');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('driver_chat_history')
          .add({
        'userMessage': userMessage,
        'aiResponse': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
        'role': 'driver',
        'session': DateTime.now().millisecondsSinceEpoch,
      });
      
      print('Chat message saved successfully');
    } catch (e) {
      print('Error saving chat message: $e');
      // Don't throw error, just log it so chat continues to work
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print('Cannot get chat history: User not logged in');
        return [];
      }

      final chatQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('driver_chat_history')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      final history = chatQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'userMessage': data['userMessage'] ?? '',
          'aiResponse': data['aiResponse'] ?? '',
          'timestamp': data['timestamp'],
        };
      }).toList();
      
      print('Retrieved ${history.length} chat messages from history');
      return history.reversed.toList(); // Show oldest first
    } catch (e) {
      print('Error getting chat history: $e');
      return []; // Return empty list if error, don't crash the app
    }
  }
}