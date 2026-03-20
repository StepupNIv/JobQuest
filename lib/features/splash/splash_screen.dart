import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../services/storage_service.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;
  int _taglineIndex = 0;
  final _taglines = [
    'Crack Every Exam 🎯',
    'Level Up Daily 🔥',
    'Think Fast, Win More ⚡',
    'India\'s Smartest Quiz App 🇮🇳',
  ];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _startTaglineCycle();
    _navigate();
  }

  void _startTaglineCycle() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _taglineIndex = (_taglineIndex + 1) % _taglines.length);
      _startTaglineCycle();
    });
  }

  Future<void> _navigate() async {
    await ref.read(guestUserProvider.notifier).init();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final onboardingDone = StorageService.getBool(AppConfig.keyOnboardingDone) ?? false;
    if (!onboardingDone) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Floating particles
          ...List.generate(8, (i) => _Particle(index: i, controller: _particleController)),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
                    ],
                  ),
                  child: const Center(
                    child: Text('🎯', style: TextStyle(fontSize: 52)),
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                // App name
                const Text(
                  'JobQuest',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                // Rotating tagline
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                          .animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    _taglines[_taglineIndex],
                    key: ValueKey(_taglineIndex),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 60),
                // Loading dots
                _LoadingDots().animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
          // Bottom badge
          Positioned(
            bottom: 40,
            left: 0, right: 0,
            child: Column(
              children: [
                const Text(
                  'Practice Smart, Level Up',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ❤️ in India',
                  style: TextStyle(color: AppColors.textMuted.withOpacity(0.6), fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ).animate().fadeIn(delay: 1000.ms),
          ),
        ],
      ),
    );
  }
}

class _Particle extends StatelessWidget {
  final int index;
  final AnimationController controller;

  const _Particle({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final icons = ['⭐', '📚', '🏆', '💡', '🔥', '⚡', '🎯', '🪙'];
    final icon = icons[index % icons.length];
    final x = (index * 137.5) % 100;
    final y = (index * 89.3) % 100;
    final delay = index * 300;

    return Positioned(
      left: size.width * x / 100,
      top: size.height * y / 100,
      child: IgnorePointer(
        child: Text(icon, style: const TextStyle(fontSize: 20))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -20, duration: Duration(milliseconds: 2000 + delay))
            .fadeIn(duration: 500.ms)
            .then()
            .fadeOut(duration: 500.ms),
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Container(
          width: 8, height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(
            color: AppColors.primary, shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(
                begin: 0.5,
                end: 1.0,
                duration: 600.ms,
                delay: Duration(milliseconds: i * 200));
      }),
    );
  }
}
