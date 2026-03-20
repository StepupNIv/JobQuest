class QuizAttempt {
  final String id;
  final String category;
  final String difficulty;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTakenSeconds;
  final DateTime attemptedAt;
  final Map<String, int> userAnswers; // questionId -> selectedIndex
  final int xpEarned;
  final int coinsEarned;

  const QuizAttempt({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTakenSeconds,
    required this.attemptedAt,
    required this.userAnswers,
    required this.xpEarned,
    required this.coinsEarned,
  });

  double get accuracy => totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;
  int get score => ((correctAnswers / totalQuestions) * 100).round();
  bool get isPerfect => correctAnswers == totalQuestions;

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'difficulty': difficulty,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'timeTakenSeconds': timeTakenSeconds,
        'attemptedAt': attemptedAt.toIso8601String(),
        'userAnswers': userAnswers,
        'xpEarned': xpEarned,
        'coinsEarned': coinsEarned,
      };
}
