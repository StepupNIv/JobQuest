import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionRepository {
  static final QuestionRepository _instance = QuestionRepository._();
  QuestionRepository._();
  factory QuestionRepository() => _instance;

  final Map<String, List<Question>> _cache = {};
  bool _loaded = false;

  static const _files = [
    'aptitude_easy', 'aptitude_medium', 'aptitude_hard',
    'reasoning_easy', 'reasoning_medium', 'reasoning_hard',
    'english_easy', 'english_medium', 'english_hard',
    'gk_easy', 'gk_medium', 'gk_hard',
  ];

  Future<void> loadAll() async {
    if (_loaded) return;
    for (final name in _files) {
      try {
        final raw = await rootBundle.loadString('assets/questions/$name.json');
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((e) => Question.fromMap(e as Map<String, dynamic>))
            .where((q) => q.isValid)
            .toList();
        _cache[name] = list;
      } catch (e) {
        _cache[name] = []; // Skip malformed file safely
        assert(() { print('[QuestionRepo] Failed to load $name: $e'); return true; }());
      }
    }
    _loaded = true;
  }

  List<Question> getQuestions({
    required String category,
    String? difficulty,
    String? topic,
    int? limit,
  }) {
    final cat = category.toLowerCase();
    List<Question> result = [];

    for (final key in _cache.keys) {
      if (!key.startsWith(cat)) continue;
      if (difficulty != null && !key.endsWith(difficulty.toLowerCase())) continue;
      result.addAll(_cache[key] ?? []);
    }

    if (topic != null) {
      result = result.where((q) => q.topic.toLowerCase() == topic.toLowerCase()).toList();
    }

    result.shuffle();
    if (limit != null && result.length > limit) {
      return result.sublist(0, limit);
    }
    return result;
  }

  List<Question> getDailyChallenge({int count = 15}) {
    // Mix of all categories, medium difficulty
    final categories = ['aptitude', 'reasoning', 'english', 'gk'];
    final result = <Question>[];
    final perCat = (count / categories.length).ceil();
    for (final cat in categories) {
      final qs = getQuestions(category: cat, limit: perCat);
      result.addAll(qs);
    }
    result.shuffle();
    return result.length > count ? result.sublist(0, count) : result;
  }

  List<Question> getRandomQuiz({int count = 10, String? category}) {
    if (category != null) {
      return getQuestions(category: category, limit: count);
    }
    final cats = ['aptitude', 'reasoning', 'english', 'gk'];
    cats.shuffle();
    final result = <Question>[];
    for (final cat in cats) {
      final qs = getQuestions(category: cat, limit: (count / 4).ceil());
      result.addAll(qs);
    }
    result.shuffle();
    return result.length > count ? result.sublist(0, count) : result;
  }

  int get totalCount => _cache.values.fold(0, (sum, l) => sum + l.length);
  List<String> get categories => ['Aptitude', 'Reasoning', 'English', 'GK'];
}
