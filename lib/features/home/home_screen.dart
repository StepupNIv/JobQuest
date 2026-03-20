import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../config/app_strings.dart';
import '../../repositories/question_repository.dart';
import '../../widgets/stat_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(guestUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(user: user)),
            SliverToBoxAdapter(child: _StatsRow(user: user)),
            SliverToBoxAdapter(child: _DailyChallengeBanner()),
            SliverToBoxAdapter(child: _CategoriesGrid()),
            SliverToBoxAdapter(child: _LeaderboardPreview()),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _Header extends StatelessWidget {
  final dynamic user;
  const _Header({this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'Challenger';
    final level = user?.level ?? 1;
    final streak = user?.streak ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hey $name! 👋',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  streak > 0 ? '🔥 $streak day streak — keep it up!' : 'Start your streak today!',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(user?.avatar ?? '🎯', style: const TextStyle(fontSize: 24)),
                  Text('Lv $level',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic user;
  const _StatsRow({this.user});

  @override
  Widget build(BuildContext context) {
    final xp = user?.xp ?? 0;
    final coins = user?.coins ?? 0;
    final quizzes = user?.quizzesPlayed ?? 0;
    final acc = (user?.overallAccuracy ?? 0.0).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: StatChip(label: 'XP', value: '$xp', emoji: '⭐', color: AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: StatChip(label: 'Coins', value: '$coins', emoji: '🪙', color: AppColors.secondary)),
          const SizedBox(width: 10),
          Expanded(child: StatChip(label: 'Quizzes', value: '$quizzes', emoji: '📚', color: AppColors.accent)),
          const SizedBox(width: 10),
          Expanded(child: StatChip(label: 'Accuracy', value: '$acc%', emoji: '🎯', color: AppColors.success)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

class _DailyChallengeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/quiz', arguments: {'isDaily': true}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFFBE21)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFFFF6B6B).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Challenge', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('15 questions • Mixed categories\nDouble XP today!', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
              child: const Text('Play →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: -0.1, end: 0);
  }
}

class _CategoriesGrid extends StatelessWidget {
  final _cats = const [
    {'label': 'Aptitude', 'emoji': '🔢', 'sub': 'Maths & Reasoning'},
    {'label': 'Reasoning', 'emoji': '🧩', 'sub': 'Logic & Puzzles'},
    {'label': 'English', 'emoji': '📝', 'sub': 'Grammar & Vocab'},
    {'label': 'GK', 'emoji': '🌍', 'sub': 'India & World'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.categories,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _cats.length,
            itemBuilder: (context, i) => _CategoryCard(cat: _cats[i], index: i),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, String> cat;
  final int index;
  const _CategoryCard({required this.cat, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(cat['label']!);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/quiz', arguments: {'category': cat['label']}),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cat['emoji']!, style: const TextStyle(fontSize: 28)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat['label']!,
                      style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(cat['sub']!,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 350 + index * 80)).scale(begin: const Offset(0.9, 0.9));
  }
}

class _LeaderboardPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Top Scorers 🏆',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
                child: const Text(AppStrings.viewAll, style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('🏆 View full leaderboard →',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }
}

class _BottomNav extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: '🏠', label: 'Home', onTap: () {}),
          _NavItem(icon: '🏆', label: 'Ranks', onTap: () => Navigator.pushNamed(context, '/leaderboard')),
          _NavItem(icon: '🎁', label: 'Rewards', onTap: () => Navigator.pushNamed(context, '/rewards')),
          _NavItem(icon: '👤', label: 'Profile', onTap: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
