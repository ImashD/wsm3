import 'package:flutter/material.dart';
import '../../../../core/services/language_service.dart';

class LanguageSelectorWidget extends StatefulWidget {
  final Function(String) onLanguageChanged;
  final String currentLanguage;

  const LanguageSelectorWidget({
    super.key,
    required this.onLanguageChanged,
    this.currentLanguage = 'en',
  });

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.currentLanguage,
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  widget.onLanguageChanged(newLanguage);
                }
              },
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.orange.shade700,
              ),
              items: LanguageService.supportedLanguages.entries
                  .map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getLanguageFlag(entry.key),
                      const SizedBox(width: 6),
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return const Text('🇬🇧', style: TextStyle(fontSize: 16));
      case 'si':
        return const Text('🇱🇰', style: TextStyle(fontSize: 16));
      case 'ta':
        return const Text('🇱🇰', style: TextStyle(fontSize: 16));
      default:
        return const Text('🌐', style: TextStyle(fontSize: 16));
    }
  }
}

class MultilingualWelcomeMessage extends StatelessWidget {
  final String language;

  const MultilingualWelcomeMessage({
    super.key,
    this.language = 'en',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.orange.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getWelcomeTitle(language),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getWelcomeMessage(language),
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getExampleQuestions(language),
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getWelcomeTitle(String lang) {
    switch (lang) {
      case 'si':
        return 'රියදුරු AI සහායකයා 🚗';
      case 'ta':
        return 'ஓட்டுநர் AI உதவியாளர் 🚗';
      default:
        return 'Driver AI Assistant 🚗';
    }
  }

  String _getWelcomeMessage(String lang) {
    switch (lang) {
      case 'si':
        return 'ආයුබෝවන්! මම ඔබේ AI රියදුරු සහායකයා. රියදුරු, ගමන් කිරීම, වාහන නඩත්තු, හෝ සාමාන්‍ය ප්‍රශ්න ගැන ඕනෑම දෙයක් අසන්න!';
      case 'ta':
        return 'வணக்கம்! நான் உங்கள் AI ஓட்டுநர் உதவியாளர். ஓட்டுதல், பயணம், வாகன பராமரிப்பு அல்லது பொதுவான கேள்விகள் - எதையும் கேளுங்கள்!';
      default:
        return 'Hello! I\'m your AI Driver Assistant. Ask me anything about driving, transportation, vehicle maintenance, or general questions!';
    }
  }

  String _getExampleQuestions(String lang) {
    switch (lang) {
      case 'si':
        return 'උදා: "කාලගුණය ගැන", "ගමන් පාර", "වාහන නඩත්තු"';
      case 'ta':
        return 'உதா: "வானிலை பற்றி", "பயண வழி", "வாகன பராமரிப்பு"';
      default:
        return 'e.g., "weather info", "route help", "vehicle maintenance"';
    }
  }
}