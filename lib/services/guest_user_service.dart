import 'package:uuid/uuid.dart';
import '../models/guest_user.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class GuestUserService {
  static GuestUser? _currentUser;
  static final _uuid = const Uuid();

  static GuestUser? get currentUser => _currentUser;

  static Future<GuestUser> initUser() async {
    final json = StorageService.getString(AppConfig.keyGuestUser);
    if (json != null && json.isNotEmpty) {
      try {
        _currentUser = GuestUser.fromJson(json);
        _updateStreak();
        return _currentUser!;
      } catch (_) {
        // Corrupt data – create fresh
      }
    }
    _currentUser = _createNewUser();
    await _save();
    return _currentUser!;
  }

  static GuestUser _createNewUser() => GuestUser(
        guestId: _uuid.v4(),
        name: 'Challenger',
        avatar: '🎯',
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

  static void _updateStreak() {
    final user = _currentUser;
    if (user == null) return;
    final now = DateTime.now();
    final lastActive = user.lastActiveAt;
    if (lastActive == null) {
      _currentUser = user.copyWith(streak: 1, lastActiveAt: now);
      return;
    }
    final diffDays = now.difference(lastActive).inDays;
    if (diffDays == 0) return; // Same day
    if (diffDays == 1) {
      _currentUser = user.copyWith(streak: user.streak + 1, lastActiveAt: now);
    } else {
      _currentUser = user.copyWith(streak: 0, lastActiveAt: now);
    }
  }

  static Future<void> addXP(int xp) async {
    final user = _currentUser;
    if (user == null) return;
    var newXp = user.xp + xp;
    var newLevel = user.level;
    final xpNeeded = AppConfig.baseXpPerLevel * newLevel;
    if (newXp >= xpNeeded) {
      newXp -= xpNeeded;
      newLevel++;
    }
    _currentUser = user.copyWith(xp: newXp, level: newLevel);
    await _save();
  }

  static Future<void> addCoins(int coins) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(coins: _currentUser!.coins + coins);
    await _save();
  }

  static Future<void> recordQuizResult({
    required String category,
    required int correct,
    required int total,
    required int xpEarned,
    required int coinsEarned,
  }) async {
    final user = _currentUser;
    if (user == null) return;

    // Update category progress
    final progs = List<CategoryProgress>.from(user.categoryProgress);
    final idx = progs.indexWhere((p) => p.category == category);
    if (idx >= 0) {
      progs[idx].quizzesPlayed++;
      progs[idx].totalCorrect += correct;
      progs[idx].totalQuestions += total;
    } else {
      progs.add(CategoryProgress(
        category: category,
        quizzesPlayed: 1,
        totalCorrect: correct,
        totalQuestions: total,
      ));
    }

    _currentUser = user.copyWith(
      quizzesPlayed: user.quizzesPlayed + 1,
      totalCorrect: user.totalCorrect + correct,
      totalQuestions: user.totalQuestions + total,
      categoryProgress: progs,
      lastActiveAt: DateTime.now(),
    );
    await addXP(xpEarned);
    await addCoins(coinsEarned);
  }

  static Future<void> updateProfile({String? name, String? avatar, String? language}) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(name: name, avatar: avatar, language: language);
    await _save();
  }

  static Future<void> activatePremium() async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(isPremium: true, premiumPlan: 'monthly');
    await _save();
  }

  static Future<void> unlockAchievement(String id) async {
    final user = _currentUser;
    if (user == null) return;
    if (user.unlockedAchievements.contains(id)) return;
    final list = List<String>.from(user.unlockedAchievements)..add(id);
    _currentUser = user.copyWith(unlockedAchievements: list);
    await _save();
  }

  static Future<void> resetProgress() async {
    _currentUser = _createNewUser();
    await _save();
  }

  static Future<void> _save() async {
    if (_currentUser == null) return;
    await StorageService.setString(AppConfig.keyGuestUser, _currentUser!.toJson());
  }
}
