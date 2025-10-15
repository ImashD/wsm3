import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  const apiKey = 'AIzaSyDw6VguIZgfb6wsaC1NTD5jQo7tc3T_5xo';

  const models = <String>[
    'gemini-2.5-pro',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
  ];

  for (final modelName in models) {
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      requestOptions: const RequestOptions(apiVersion: 'v1'),
    );

    try {
      final response = await model.generateContent(
        [Content.text('Say hello in one short sentence.')],
      );
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        print('⚠️ $modelName returned an empty response');
      } else {
        print('✅ $modelName responded: $text');
      }
    } catch (e) {
      print('❌ $modelName failed: $e');
    }
  }
}
