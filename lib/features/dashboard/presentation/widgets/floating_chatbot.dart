import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbot_widget.dart';

class FloatingChatbot extends StatefulWidget {
  const FloatingChatbot({super.key});

  @override
  State<FloatingChatbot> createState() => _FloatingChatbotState();
}

class _FloatingChatbotState extends State<FloatingChatbot>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  void _toggleChatbot() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Chatbot Widget
        if (_isExpanded)
          Positioned(
            right: 20,
            bottom: 100,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: 350,
                height: 500,
                child: const ChatbotWidget(),
              ),
            ),
          ),

        // Floating Action Button
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: _toggleChatbot,
            backgroundColor: Colors.teal,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isExpanded ? Icons.close : Icons.chat,
                key: ValueKey(_isExpanded),
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Notification badge (optional)
        if (!_isExpanded)
          Positioned(
            right: 15,
            bottom: 55,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                '!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}