import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:wsm3/core/services/auth_service.dart'; // ✅ Change 'your_app_name' to your actual package name

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoBounce;
  late Animation<double> _logoFade;

  late AnimationController _taglineController;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    // Start animations
    _startAnimations();

    // Wait until the first frame is rendered before checking auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  void _startAnimations() {
    // Logo bounce animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoBounce = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -30.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -30.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -15.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -15.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 25,
      ),
    ]).animate(_logoController);

    // Logo fade-in
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    _logoController.forward();

    // Tagline fade-in after logo animation
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _taglineFade = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeIn,
    );

    Future.delayed(const Duration(milliseconds: 2600), () {
      _taglineController.forward();
    });
  }

  Future<void> _checkAuthStatus() async {
    // Give splash time to display first
    await Future.delayed(const Duration(seconds: 1));

    final authService = AuthService();
    await authService.init();

    final isFirstTime = await authService.isFirstTime();
    final isAuthenticated = await authService.isAuthenticated();

    if (!mounted) return;

    // Wait for splash + animations (~6s total)
    await Future.delayed(const Duration(seconds: 5));

    if (isFirstTime) {
      context.go('/onboarding');
    } else if (!isAuthenticated) {
      context.go('/signin');
    } else {
      context.go('/role-selection');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1DD1A1), Color(0xFFE1FCF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo bounce and fade-in
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _logoBounce.value),
                      child: child,
                    ),
                  );
                },
                child: Image.asset("assets/logo.png", height: 100),
              ),
              const SizedBox(height: 24),

              // App title typing animation
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontFamily: 'NotoSerifSinhala',
                  letterSpacing: 1.2,
                ),
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  totalRepeatCount: 1,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      "වී සවිය",
                      speed: Duration(milliseconds: 200),
                      cursor: '',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tagline fade-in
              FadeTransition(
                opacity: _taglineFade,
                child: const Text(
                  "From Field to Market\nYour Agri-Mart Solution!",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
