import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/question.dart';
import '../../services/gamification_service.dart';
import '../../services/analytics_service.dart';
import '../../services/ad_service.dart';
import '../../config/app_config.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final dynamic session; // Map with questions/answers/category/difficulty
  const ResultScreen({super.key, required this.session});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late int _correct;
  late int _total;
  late int _xpEarned;
  late int _coinsEarned;
  late List<Question> _questions;
  late Map<int, int> _answers;
  late String _category, _difficulty;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final data = widget.session as Map<String, dynamic>;
    _questions = (data['questions'] as List).cast<Question>();
    _answers = (data['answers'] as Map).cast<int, int>();
    _category = data['category'] as String? ?? 'Quiz';
    _difficulty = data['difficulty'] as String? ?? 'mixed';
    _total = _questions.length;
    _correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctAnswer) _correct++;
    }
    _xpEarned = GamificationService.calculateXP(_correct, _total, _difficulty);
    _coinsEarned = GamificationService.calculateCoins(_correct, _total);
    _saveAndCheck();
  }

  Future<void> _saveAndCheck() async {
    if (_saved) return;
    _saved = true;
    await ref.read(guestUserProvider.notifier).recordQuizResult(
      category: _category,
      correct: _correct,
      total: _total,
      xpEarned: _xpEarned,
      coinsEarned: _coinsEarned,
    );
    AnalyticsService.logQuizCompleted(_category, _correct, _total);
    await AdService().maybeShowInterstitial();
  }

  double get _percentage => _total > 0 ? _correct / _total : 0;

  String get _grade {
    if (_percentage >= 0.9) return 'Brilliant! 🤩';
    if (_percentage >= 0.7) return 'Great Work! 🎉';
    if (_percentage >= 0.5) return 'Not Bad! 😊';
    return 'Keep Practising! 💪';
  }

  Color get _gradeColor {
    if (_percentage >= 0.9) return AppColors.success;
    if (_percentage >= 0.7) return AppColors.accent;
    if (_percentage >= 0.5) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Score ring
              _ScoreRing(percentage: _percentage, correct: _correct, total: _total),
              const SizedBox(height: 20),
              Text(_grade,
                  style: TextStyle(color: _gradeColor, fontSize: 24, fontWeight: FontWeight.bold))
                  .animate().fadeIn(delay: 600.ms).scale(),
              const SizedBox(height: 8),
              Text(_category,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 32),
              // Rewards row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RewardBadge(emoji: '⭐', label: '+$_xpEarned XP', color: AppColors.primary),
                  const SizedBox(width: 16),
                  _RewardBadge(emoji: '🪙', label: '+$_coinsEarned Coins', color: AppColors.secondary),
                ],
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 32),
              // Wrong answers review
              if (_answers.isNotEmpty)
                _WrongAnswersList(questions: _questions, answers: _answers),
              const SizedBox(height: 32),
              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context, '/quiz',
                    arguments: {'category': _category, 'difficulty': _difficulty},
                  ),
                  child: const Text('Play Again 🔄'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final double percentage;
  final int correct, total;
  const _ScoreRing({required this.percentage, required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160, height: 160,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: 12,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 0.7 ? AppColors.success : percentage >= 0.5 ? AppColors.warning : AppColors.danger,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$correct/$total',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
              Text('${(percentage * 100).round()}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ],
      ),
    ).animate().scale(duration: 700.ms, curve: Curves.elasticOut);
  }
}

class _RewardBadge extends StatelessWidget {
  final String emoji, label;
  final Color color;
  const _RewardBadge({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}

class _WrongAnswersList extends StatelessWidget {
  final List<Question> questions;
  final Map<int, int> answers;
  const _WrongAnswersList({required this.questions, required this.answers});

  @override
  Widget build(BuildContext context) {
    final wrongs = <int>[];
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] != questions[i].correctAnswer) wrongs.add(i);
    }
    if (wrongs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review ${wrongs.length} wrong answer${wrongs.length > 1 ? 's' : ''} 📖',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...wrongs.take(5).map((i) {
          final q = questions[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.danger.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.question, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('✅ ${q.options[q.correctAnswer]}',
                    style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                if (answers[i] != null && answers[i]! >= 0)
                  Text('❌ ${q.options[answers[i]!]}',
                      style: const TextStyle(color: AppColors.danger, fontSize: 12)),
              ],
            ),
          );
        }),
        if (wrongs.length > 5)
          Text('…and ${wrongs.length - 5} more',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}
