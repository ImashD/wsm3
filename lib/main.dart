import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/auth_service.dart';
import 'core/services/navigation_service.dart'; // Import NavigationService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize AuthService
  final authService = AuthService();
  await authService.init();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    // Use the centralized router from NavigationService
    return MaterialApp.router(
      title: 'WorkForce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: NavigationService().router, // <-- updated here
    );
  }
}
