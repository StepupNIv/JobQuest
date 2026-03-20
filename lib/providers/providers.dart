import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/guest_user.dart';
import '../models/question.dart';
import '../models/leaderboard_entry.dart';
import '../models/achievement.dart';
import '../repositories/question_repository.dart';
import '../repositories/leaderboard_repository.dart';
import '../services/guest_user_service.dart';
import '../services/gamification_service.dart';
import '../services/storage_service.dart';
import '../services/premium_service.dart';
import '../config/app_config.dart';

// ── Guest User ─────────────────────────────────────────────────────────────

class GuestUserNotifier extends StateNotifier<GuestUser?> {
  GuestUserNotifier() : super(null);

  Future<void> init() async {
    final user = await GuestUserService.initUser();
    state = user;
  }

  Future<void> addXP(int xp) async {
    await GuestUserService.addXP(xp);
    state = GuestUserService.currentUser;
  }

  Future<void> addCoins(int coins) async {
    await GuestUserService.addCoins(coins);
    state = GuestUserService.currentUser;
  }

  Future<void> recordQuizResult({
    required String category,
    required int correct,
    required int total,
    required int xpEarned,
    required int coinsEarned,
  }) async {
    await GuestUserService.recordQuizResult(
      category: category, correct: correct, total: total,
      xpEarned: xpEarned, coinsEarned: coinsEarned,
    );
    state = GuestUserService.currentUser;
  }

  Future<void> updateProfile({String? name, String? avatar}) async {
    await GuestUserService.updateProfile(name: name, avatar: avatar);
    state = GuestUserService.currentUser;
  }

  Future<void> activatePremium() async {
    await GuestUserService.activatePremium();
    state = GuestUserService.currentUser;
  }

  Future<void> reset() async {
    await GuestUserService.resetProgress();
    state = GuestUserService.currentUser;
  }
}

final guestUserProvider =
    StateNotifierProvider<GuestUserNotifier, GuestUser?>((ref) => GuestUserNotifier());

// ── Onboarding ────────────────────────────────────────────────────────────

final onboardingDoneProvider = StateProvider<bool>((ref) {
  return StorageService.getBool(AppConfig.keyOnboardingDone) ?? false;
});

// ── Premium ───────────────────────────────────────────────────────────────

final premiumProvider = Provider<bool>((ref) {
  final user = ref.watch(guestUserProvider);
  return user?.isPremium ?? false;
});

// ── Quiz Session ──────────────────────────────────────────────────────────

class QuizSession {
  final List<Question> questions;
  final Map<int, int> answers; // index -> selected
  final int currentIndex;
  final bool isComplete;
  final DateTime startTime;

  const QuizSession({
    required this.questions,
    this.answers = const {},
    this.currentIndex = 0,
    this.isComplete = false,
    required this.startTime,
  });

  int get correctCount {
    int c = 0;
    for (final entry in answers.entries) {
      final q = questions[entry.key];
      if (q.correctAnswer == entry.value) c++;
    }
    return c;
  }

  QuizSession copyWith({
    Map<int, int>? answers,
    int? currentIndex,
    bool? isComplete,
  }) =>
      QuizSession(
        questions: questions,
        answers: answers ?? this.answers,
        currentIndex: currentIndex ?? this.currentIndex,
        isComplete: isComplete ?? this.isComplete,
        startTime: startTime,
      );
}

class QuizSessionNotifier extends StateNotifier<QuizSession?> {
  QuizSessionNotifier() : super(null);

  void startQuiz(List<Question> questions) {
    state = QuizSession(questions: questions, startTime: DateTime.now());
  }

  void submitAnswer(int questionIndex, int answerIndex) {
    if (state == null) return;
    final newAnswers = Map<int, int>.from(state!.answers)
      ..[questionIndex] = answerIndex;
    state = state!.copyWith(answers: newAnswers, currentIndex: questionIndex + 1);
  }

  void complete() {
    if (state == null) return;
    state = state!.copyWith(isComplete: true);
  }

  void reset() => state = null;
}

final quizSessionProvider =
    StateNotifierProvider<QuizSessionNotifier, QuizSession?>((ref) => QuizSessionNotifier());

// ── Leaderboard ───────────────────────────────────────────────────────────

final selectedLeaderboardPeriodProvider =
    StateProvider<LeaderboardPeriod>((ref) => LeaderboardPeriod.weekly);

final leaderboardProvider = Provider.family<List<LeaderboardEntry>, LeaderboardPeriod>(
  (ref, period) {
    final user = ref.watch(guestUserProvider);
    if (user == null) return [];
    return LeaderboardRepository().generateLeaderboard(user, period);
  },
);

// ── Achievements ──────────────────────────────────────────────────────────

final achievementsProvider = Provider<List<Achievement>>((ref) {
  final user = ref.watch(guestUserProvider);
  final all = Achievement.allAchievements();
  if (user == null) return all;
  for (final a in all) {
    a.isUnlocked = user.unlockedAchievements.contains(a.id);
  }
  return all;
});

// ── Settings ──────────────────────────────────────────────────────────────

final notificationsEnabledProvider = StateProvider<bool>((ref) {
  return StorageService.getBool(AppConfig.keyNotificationsEnabled) ?? true;
});

final soundEnabledProvider = StateProvider<bool>((ref) {
  return StorageService.getBool(AppConfig.keySoundEnabled) ?? true;
});
