import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../config/app_config.dart';
import '../../config/app_strings.dart';
import '../../widgets/gradient_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _ObPage(emoji:'🎯', title: AppStrings.ob1Title, desc: AppStrings.ob1Desc, gradient: [Color(0xFF6C63FF), Color(0xFF8B5CF6)]),
    _ObPage(emoji:'🏆', title: AppStrings.ob2Title, desc: AppStrings.ob2Desc, gradient: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
    _ObPage(emoji:'📈', title: AppStrings.ob3Title, desc: AppStrings.ob3Desc, gradient: [Color(0xFF4ECDC4), Color(0xFF2ECC71)]),
    _ObPage(emoji:'🔥', title: AppStrings.ob4Title, desc: AppStrings.ob4Desc, gradient: [Color(0xFFFFBE21), Color(0xFFFF6B6B)]),
    _ObPage(emoji:'🇮🇳', title: AppStrings.ob5Title, desc: AppStrings.ob5Desc, gradient: [Color(0xFF43B89C), Color(0xFF6C63FF)]),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await StorageService.setBool(AppConfig.keyOnboardingDone, true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip', style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _currentPage ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GradientButton(
                label: _currentPage == _pages.length - 1 ? "Let's Go! 🚀" : 'Next →',
                onPressed: _next,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ObPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final List<Color> gradient;

  const _ObPage({required this.emoji, required this.title, required this.desc, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.4), blurRadius: 30, spreadRadius: 2)],
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 72))),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            desc,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }
}
