import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/role/presentation/pages/role_selection_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/farmer_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/driver_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/labour_dashboard_page.dart';
import '../../features/role/presentation/pages/farmer_registration_page.dart';
import '../../features/role/presentation/pages/labour_registration_page.dart';
import '../../features/role/presentation/pages/driver_registration_page.dart';
import 'package:wsm3/features/dashboard/presentation/pages/drawer/contact.dart';
import 'package:wsm3/features/dashboard/presentation/pages/drawer/learn.dart';
import 'package:wsm3/features/dashboard/presentation/pages/drawer/products.dart';
import 'package:wsm3/features/dashboard/presentation/pages/drawer/reports.dart';
import 'package:wsm3/features/dashboard/presentation/pages/drawer/promotions.dart';
import 'package:wsm3/features/dashboard/presentation/pages/featurecard/cultivation.dart';
import 'package:wsm3/features/dashboard/presentation/pages/featurecard/drivers.dart';
import 'package:wsm3/features/dashboard/presentation/pages/featurecard/labors.dart';
import 'package:wsm3/features/dashboard/presentation/pages/featurecard/market.dart';
import 'package:wsm3/features/dashboard/presentation/pages/featurecard/stores.dart';
import 'package:wsm3/features/dashboard/presentation/pages/featurecard/weather.dart';

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
          path: '/role-registration/farmer/step1',
          builder: (context, state) => const FarmerRegistrationPage(),
        ),

        GoRoute(
          path: '/role-registration/driver',
          builder: (context, state) => const DriverRegistrationPage(),
        ),
        GoRoute(
          path: '/role-registration/labour',
          builder: (context, state) => const LabourRegistrationPage(),
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
        GoRoute(
          path: '/contact',
          builder: (context, state) => const ContactScreen(),
        ),
        GoRoute(
          path: '/learn',
          builder: (context, state) => const LearnScreen(),
        ),
        GoRoute(
          path: '/cultivation',
          builder: (context, state) => const CultivationScreen(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsScreen(),
        ),
        GoRoute(
          path: '/promotions',
          builder: (context, state) => const PromotionsScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),

        GoRoute(
          path: '/labors',
          builder: (context, state) => const LaborsScreen(),
        ),
        GoRoute(
          path: '/drivers',
          builder: (context, state) => const DriversScreen(),
        ),

        GoRoute(
          path: '/market',
          builder: (context, state) => const MarketScreen(),
        ),

        GoRoute(
          path: '/stores',
          builder: (context, state) => const StoresScreen(),
        ),
        GoRoute(
          path: '/weather',
          builder: (context, state) => const WeatherScreen(),
        ),
      ],
    );
  }
}
