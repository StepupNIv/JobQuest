import '../config/app_config.dart';
import '../models/achievement.dart';
import '../models/guest_user.dart';
import 'guest_user_service.dart';

class GamificationService {
  static int calculateXP(int correct, int total, String difficulty) {
    final base = AppConfig.xpPerCorrect * correct;
    final multiplier = _difficultyMultiplier(difficulty);
    final perfect = correct == total ? 1.5 : 1.0;
    return (base * multiplier * perfect).round();
  }

  static int calculateCoins(int correct, int total) {
    if (correct == total) return AppConfig.coinsPerPerfect;
    return AppConfig.coinsPerQuiz + (correct > total ~/ 2 ? correct : 0);
  }

  static double _difficultyMultiplier(String d) {
    switch (d.toLowerCase()) {
      case 'hard': return 1.5;
      case 'medium': return 1.2;
      default: return 1.0;
    }
  }

  static Future<List<Achievement>> checkAchievements(GuestUser user) async {
    final all = Achievement.allAchievements();
    final newlyUnlocked = <Achievement>[];

    for (final ach in all) {
      if (user.unlockedAchievements.contains(ach.id)) continue;
      if (_shouldUnlock(ach.id, user)) {
        await GuestUserService.unlockAchievement(ach.id);
        ach.isUnlocked = true;
        ach.unlockedAt = DateTime.now();
        newlyUnlocked.add(ach);
      }
    }
    return newlyUnlocked;
  }

  static bool _shouldUnlock(String id, GuestUser u) {
    switch (id) {
      case 'first_quiz': return u.quizzesPlayed >= 1;
      case 'quiz_5': return u.quizzesPlayed >= 5;
      case 'quiz_25': return u.quizzesPlayed >= 25;
      case 'quiz_100': return u.quizzesPlayed >= 100;
      case 'streak_3': return u.streak >= 3;
      case 'streak_7': return u.streak >= 7;
      case 'streak_30': return u.streak >= 30;
      case 'level_5': return u.level >= 5;
      case 'level_10': return u.level >= 10;
      case 'accuracy_80': return u.overallAccuracy >= 80;
      case 'accuracy_90': return u.overallAccuracy >= 90;
      case 'coins_100': return u.coins >= 100;
      case 'premium': return u.isPremium;
      case 'night_owl': return DateTime.now().hour >= 23 || DateTime.now().hour < 2;
      default: return false;
    }
  }
}
