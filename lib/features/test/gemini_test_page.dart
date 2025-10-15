import 'package:flutter/material.dart';
import '../../core/services/gemini_test_service.dart';

class GeminiTestPage extends StatefulWidget {
  const GeminiTestPage({Key? key}) : super(key: key);

  @override
  State<GeminiTestPage> createState() => _GeminiTestPageState();
}

class _GeminiTestPageState extends State<GeminiTestPage> {
  String _testResult = 'Press the button to test Gemini AI';
  bool _isLoading = false;

  Future<void> _testGeminiAPI() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing Gemini AI...';
    });

    try {
      // Test basic functionality
      final response = await GeminiTestService.testQuickResponse(
        'Say "Gemini AI is working!" to confirm you are online.'
      );
      
      setState(() {
        _testResult = 'Response: $response';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini AI Test'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Gemini AI Connection Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _testResult,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGeminiAPI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Testing...'),
                      ],
                    )
                  : const Text(
                      'Test Gemini AI',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This will test if the Gemini AI API is responding correctly.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}