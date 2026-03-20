import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/question.dart';
import '../../repositories/question_repository.dart';
import '../../config/app_config.dart';
import '../../services/analytics_service.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String category;
  final String? difficulty;
  final bool isDaily;

  const QuizScreen({
    super.key,
    required this.category,
    this.difficulty,
    this.isDaily = false,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  List<Question> _questions = [];
  int _current = 0;
  int? _selected;
  bool _answered = false;
  bool _showExplanation = false;
  int _timeLeft = AppConfig.defaultTimeLimitSeconds;
  Timer? _timer;
  final Map<int, int> _answers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final repo = QuestionRepository();
    List<Question> qs;
    if (widget.isDaily) {
      qs = repo.getDailyChallenge();
    } else {
      qs = repo.getQuestions(
        category: widget.category,
        difficulty: widget.difficulty,
        limit: AppConfig.defaultQuizSize,
      );
    }
    if (!mounted) return;
    setState(() {
      _questions = qs;
      _loading = false;
    });
    if (qs.isNotEmpty) {
      _startTimer();
      AnalyticsService.logQuizStarted(widget.category, widget.difficulty ?? 'mixed');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final q = _questions[_current];
    _timeLeft = q.timeLimit.clamp(10, 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_timeLeft <= 0) {
        t.cancel();
        _onTimeUp();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _onTimeUp() {
    if (_answered) return;
    setState(() { _answered = true; _selected = -1; });
  }

  void _selectAnswer(int idx) {
    if (_answered) return;
    _timer?.cancel();
    setState(() { _selected = idx; _answered = true; });
    _answers[_current] = idx;
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
        _showExplanation = false;
      });
      _startTimer();
    } else {
      _finish();
    }
  }

  void _finish() {
    _timer?.cancel();
    ref.read(quizSessionProvider.notifier).complete();
    final session = ref.read(quizSessionProvider);
    Navigator.pushReplacementNamed(context, '/result', arguments: {
      'questions': _questions,
      'answers': _answers,
      'category': widget.category,
      'difficulty': widget.difficulty ?? 'mixed',
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🧠', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text('Loading questions...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(widget.category)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😬', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text('No questions found', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
              const SizedBox(height: 8),
              const Text('Try a different category', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    final q = _questions[_current];
    final progress = (_current + 1) / _questions.length;
    final isCorrect = _answered && _selected == q.correctAnswer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('${widget.isDaily ? "Daily Challenge" : widget.category} • Q${_current + 1}/${_questions.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.cardBg,
                title: const Text('Quit Quiz?', style: TextStyle(color: AppColors.textPrimary)),
                content: const Text('Progress will be lost.', style: TextStyle(color: AppColors.textSecondary)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                    child: const Text('Quit', style: TextStyle(color: AppColors.danger)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
          // Timer
          _TimerBar(timeLeft: _timeLeft, total: q.timeLimit),
          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.categoryColor(q.category).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(q.topic,
                        style: TextStyle(
                            color: AppColors.categoryColor(q.category),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),
                  // Question text
                  Text(
                    q.question,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 17, height: 1.5),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 24),
                  // Options
                  ...List.generate(q.options.length, (i) => _OptionTile(
                    label: q.options[i],
                    index: i,
                    selected: _selected == i,
                    answered: _answered,
                    isCorrect: i == q.correctAnswer,
                    onTap: () => _selectAnswer(i),
                  )),
                  // Explanation
                  if (_answered) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => setState(() => _showExplanation = !_showExplanation),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (isCorrect ? AppColors.success : AppColors.danger).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: (isCorrect ? AppColors.success : AppColors.danger).withOpacity(0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(isCorrect ? '✅ Correct!' : (_selected == -1 ? '⏰ Time\'s Up!' : '❌ Wrong'),
                                    style: TextStyle(
                                        color: isCorrect ? AppColors.success : AppColors.danger,
                                        fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text(_showExplanation ? 'Hide ↑' : 'Explain ↓',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              ],
                            ),
                            if (_showExplanation) ...[
                              const SizedBox(height: 10),
                              Text('Correct: ${q.options[q.correctAnswer]}',
                                  style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text(q.explanation,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Next button
          if (_answered)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_current < _questions.length - 1 ? 'Next Question →' : 'See Results 🎊'),
                ),
              ),
            ).animate().slideY(begin: 1, end: 0, duration: 300.ms),
        ],
      ),
    );
  }
}

class _TimerBar extends StatelessWidget {
  final int timeLeft, total;
  const _TimerBar({required this.timeLeft, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? timeLeft / total : 0.0;
    final color = ratio > 0.5 ? AppColors.success : ratio > 0.25 ? AppColors.warning : AppColors.danger;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Text('⏱', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${timeLeft}s',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final int index;
  final bool selected, answered, isCorrect;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label, required this.index,
    required this.selected, required this.answered,
    required this.isCorrect, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.divider;
    Color bgColor = AppColors.cardBg;
    Color textColor = AppColors.textPrimary;

    if (answered) {
      if (isCorrect) {
        borderColor = AppColors.success;
        bgColor = AppColors.success.withOpacity(0.12);
        textColor = AppColors.success;
      } else if (selected && !isCorrect) {
        borderColor = AppColors.danger;
        bgColor = AppColors.danger.withOpacity(0.12);
        textColor = AppColors.danger;
      }
    } else if (selected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withOpacity(0.12);
    }

    final labels = ['A', 'B', 'C', 'D'];
    return GestureDetector(
      onTap: answered ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(labels[index],
                    style: TextStyle(color: borderColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(color: textColor, fontSize: 14))),
            if (answered && isCorrect)
              const Text('✅', style: TextStyle(fontSize: 16))
            else if (answered && selected && !isCorrect)
              const Text('❌', style: TextStyle(fontSize: 16)),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 60)).slideX(begin: 0.1, end: 0),
    );
  }
}
