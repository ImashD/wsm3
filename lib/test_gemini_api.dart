import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  await listAvailableModels();
  await testGeminiConnection();
}

Future<void> listAvailableModels() async {
  print('🔍 Listing available Gemini models...');
  
  final apiKey = 'AIzaSyDw6VguIZgfb6wsaC1NTD5jQo7tc3T_5xo';
  
  try {
    // Try to list models (this might not work in all versions)
    print('📋 Attempting to fetch available models...');
    
    // Let's try the basic model first
    final model = GenerativeModel(
      model: 'models/gemini-pro',  // Try with models/ prefix
      apiKey: apiKey,
    );
    
    final response = await model.generateContent([Content.text('Test')]);
    print('✅ SUCCESS with models/gemini-pro');
    
  } catch (e) {
    print('❌ Models with prefix failed: $e');
    print('\n💡 Trying alternative approach...');
  }
}

Future<void> testGeminiConnection() async {
  print('\n🧪 Testing Gemini API Connection...');
  
  final apiKey = 'AIzaSyDw6VguIZgfb6wsaC1NTD5jQo7tc3T_5xo';
  
  // Test different model names including older versions
  final modelsToTest = [
    'models/gemini-1.5-flash',
    'models/gemini-1.5-pro', 
    'models/gemini-pro',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-pro',
    'text-bison-001',  // PaLM model fallback
  ];
  
  for (String modelName in modelsToTest) {
    try {
      print('\n📡 Testing model: $modelName');
      
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
      );
      
      final prompt = 'Hello! Can you respond with just "Working!" to test the connection?';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      print('✅ SUCCESS with $modelName');
      print('📝 Response: ${response.text}');
      print('🎯 This model works! Use this in your services.');
      return; // Stop on first success
      
    } catch (e) {
      print('❌ FAILED with $modelName: $e');
      continue;
    }
  }
  
  print('\n⚠️ All models failed. This might indicate:');
  print('1. API key might need time to activate (try again in 5-10 minutes)');
  print('2. Project billing needs to be enabled');
  print('3. API access might be restricted in your region');
}