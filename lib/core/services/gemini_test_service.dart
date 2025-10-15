import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiTestService {
  static const String _apiKey = 'AIzaSyDw6VguIZgfb6wsaC1NTD5jQo7tc3T_5xo';  // ✅ UPDATED!
  
  static Future<void> testGeminiAPI() async {
    print('🧪 Testing Gemini AI API...');
    print('🔑 API Key: ${_apiKey.substring(0, 20)}...');
    
    try {
      // Test different model names in order of preference
      final modelsToTest = [
        'models/gemini-1.5-flash',
        'models/gemini-1.5-pro', 
        'models/gemini-pro',
        'gemini-1.5-flash',
        'gemini-1.5-pro',
        'gemini-pro',
        'text-bison-001',
        'text-bison',
      ];
      
      bool foundWorking = false;
      
      for (String modelName in modelsToTest) {
        print('\n📡 Testing model: $modelName');
        
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: _apiKey,
          );
          
          final content = [Content.text('Respond with exactly: "API_TEST_SUCCESS"')];
          final response = await model.generateContent(content);
          
          final responseText = response.text?.trim() ?? '';
          print('✅ SUCCESS with $modelName: $responseText');
          foundWorking = true;
          break; // Exit loop on first success
          
        } catch (e) {
          print('❌ FAILED with $modelName: $e');
        }
      }
      
      if (!foundWorking) {
        print('\n❌ No working models found. Possible issues:');
        print('1. API key might be invalid or expired');
        print('2. API billing might not be enabled');
        print('3. Regional restrictions');
        print('4. Service temporarily unavailable');
      }
      
    } catch (e) {
      print('❌ General error: $e');
    }
  }
  
  static Future<String> testQuickResponse(String testMessage) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',  // Try the newer model first
        apiKey: _apiKey,
      );
      
      final content = [Content.text(testMessage)];
      final response = await model.generateContent(content);
      
      return response.text ?? 'No response received';
    } catch (e) {
      return 'Error: $e';
    }
  }
}