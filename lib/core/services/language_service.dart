import 'package:translator/translator.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  final GoogleTranslator _translator = GoogleTranslator();

  // Supported languages for Sri Lankan users
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'si': 'සිංහල', // Sinhala
    'ta': 'தமிழ்', // Tamil
  };

  /// Detect the language of input text
  Future<String> detectLanguage(String text) async {
    try {
      final translation = await _translator.translate(text, to: 'en');
      String detectedLang = translation.sourceLanguage.code;
      
      // Map common language codes to our supported ones
      if (detectedLang == 'si' || detectedLang == 'sin') return 'si'; // Sinhala
      if (detectedLang == 'ta' || detectedLang == 'tam') return 'ta'; // Tamil
      
      // Default to English for unsupported languages
      return supportedLanguages.containsKey(detectedLang) ? detectedLang : 'en';
    } catch (e) {
      print('Language detection error: $e');
      return 'en'; // Default to English if detection fails
    }
  }

  /// Translate text between languages
  Future<String> translateText(String text, String targetLanguage) async {
    try {
      final translation = await _translator.translate(text, to: targetLanguage);
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text; // Return original text if translation fails
    }
  }

  /// Check if text contains Sinhala characters
  bool isSinhala(String text) {
    // Sinhala Unicode range: U+0D80-U+0DFF
    return RegExp(r'[\u0D80-\u0DFF]').hasMatch(text);
  }

  /// Check if text contains Tamil characters
  bool isTamil(String text) {
    // Tamil Unicode range: U+0B80-U+0BFF
    return RegExp(r'[\u0B80-\u0BFF]').hasMatch(text);
  }

  /// Get language name in native script
  String getLanguageName(String languageCode) {
    return supportedLanguages[languageCode] ?? 'English';
  }

  /// Get agricultural terms in different languages
  Map<String, String> getAgriculturalTerms(String language) {
    switch (language) {
      case 'si': // Sinhala
        return {
          'rice': 'කුඹුරු',
          'farming': 'ගොවිතැන',
          'harvest': 'අස්වනු',
          'fertilizer': 'පොහොර',
          'pest': 'පළිබෝධ',
          'weather': 'කාලගුණය',
          'crop': 'වගාව',
          'planting': 'වගා කිරීම',
          'irrigation': 'වාරිමාර්ග',
          'yield': 'අස්වනු',
        };
      case 'ta': // Tamil
        return {
          'rice': 'நெல்',
          'farming': 'விவசாயம்',
          'harvest': 'அறுவடை',
          'fertilizer': 'உரம்',
          'pest': 'பூச்சி',
          'weather': 'வானிலை',
          'crop': 'பயிர்',
          'planting': 'நடவு',
          'irrigation': 'நீர்பாசனம்',
          'yield': 'விளைச்சல்',
        };
      default: // English
        return {
          'rice': 'rice',
          'farming': 'farming',
          'harvest': 'harvest',
          'fertilizer': 'fertilizer',
          'pest': 'pest',
          'weather': 'weather',
          'crop': 'crop',
          'planting': 'planting',
          'irrigation': 'irrigation',
          'yield': 'yield',
        };
    }
  }
}