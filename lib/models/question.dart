class Question {
  final String id;
  final String category;
  final String topic;
  final String difficulty;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final int timeLimit;
  final String language;

  const Question({
    required this.id,
    required this.category,
    required this.topic,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.timeLimit,
    this.language = 'en',
  });

  factory Question.fromMap(Map<String, dynamic> m) => Question(
        id: m['id'] as String? ?? '',
        category: m['category'] as String? ?? '',
        topic: m['topic'] as String? ?? '',
        difficulty: m['difficulty'] as String? ?? 'easy',
        question: m['question'] as String? ?? '',
        options: List<String>.from(m['options'] as List? ?? []),
        correctAnswer: m['correctAnswer'] as int? ?? 0,
        explanation: m['explanation'] as String? ?? '',
        timeLimit: m['timeLimit'] as int? ?? 30,
        language: m['language'] as String? ?? 'en',
      );

  bool get isValid =>
      id.isNotEmpty &&
      question.isNotEmpty &&
      options.length == 4 &&
      correctAnswer >= 0 &&
      correctAnswer < 4;
}
