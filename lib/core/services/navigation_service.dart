import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/role/presentation/pages/role_selection_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/farmer_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/driver_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/labour_dashboard_page.dart';
import '../../features/role/presentation/pages/role_registration_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  late final GoRouter router;

  factory NavigationService() {
    return _instance;
  }

  NavigationService._internal() {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/signin',
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/role-selection',
          builder: (context, state) => const RoleSelectionPage(),
        ),
        GoRoute(
          path: '/role-registration/:role',
          builder: (context, state) {
            final role = state.pathParameters['role']!;
            return RoleRegistrationPage(role: role);
          },
        ),
        GoRoute(
          path: '/dashboard/farmer',
          builder: (context, state) => const FarmerDashboardPage(),
        ),
        GoRoute(
          path: '/dashboard/driver',
          builder: (context, state) => const DriverDashboardPage(),
        ),
        GoRoute(
          path: '/dashboard/labour',
          builder: (context, state) => const LabourDashboardPage(),
        ),
      ],
    );
  }
}
