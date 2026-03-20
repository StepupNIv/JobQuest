import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'providers/providers.dart';
import 'services/storage_service.dart';
import 'config/app_config.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/quiz/result_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/premium/premium_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/rewards/rewards_screen.dart';

class JobQuestApp extends ConsumerWidget {
  const JobQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'JobQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      onGenerateRoute: _onGenerateRoute,
      home: const SplashScreen(),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/onboarding':
        page = const OnboardingScreen();
        break;
      case '/home':
        page = const HomeScreen();
        break;
      case '/quiz':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        page = QuizScreen(
          category: args['category'] as String? ?? 'Aptitude',
          difficulty: args['difficulty'] as String?,
          isDaily: args['isDaily'] as bool? ?? false,
        );
        break;
      case '/result':
        page = ResultScreen(session: settings.arguments as dynamic);
        break;
      case '/leaderboard':
        page = const LeaderboardScreen();
        break;
      case '/profile':
        page = const ProfileScreen();
        break;
      case '/premium':
        page = const PremiumScreen();
        break;
      case '/rewards':
        page = const RewardsScreen();
        break;
      case '/settings':
        page = const SettingsScreen();
        break;
      default:
        page = const SplashScreen();
    }
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
