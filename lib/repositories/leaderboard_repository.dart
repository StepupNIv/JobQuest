import 'dart:convert';
import 'dart:math';
import '../models/leaderboard_entry.dart';
import '../models/guest_user.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

enum LeaderboardPeriod { daily, weekly, monthly }

class LeaderboardRepository {
  static final _rng = Random();

  // Mock competitors for local demo leaderboard
  static final _mockNames = [
    'Arjun K', 'Priya S', 'Rahul M', 'Sneha R', 'Vikram T',
    'Meera N', 'Amit B', 'Kavya P', 'Suresh V', 'Divya A',
    'Rohan G', 'Pooja L', 'Kiran J', 'Anita C', 'Deepak F',
    'Lakshmi H', 'Sunil D', 'Rina K', 'Vijay M', 'Neha S',
    'Ravi P', 'Sunita J', 'Ganesh B', 'Anjali R', 'Mohan T',
    'Shreya N', 'Prakash V', 'Rekha A', 'Sanjay G', 'Poonam L',
  ];
  static const _mockAvatars = ['🎯','🏆','⭐','💪','🧠','🔥','⚡','🌟','👑','💎'];

  List<LeaderboardEntry> generateLeaderboard(
    GuestUser currentUser,
    LeaderboardPeriod period,
  ) {
    final cached = _loadFromCache(period);
    if (cached != null) return _insertCurrentUser(cached, currentUser);

    final mock = List.generate(AppConfig.mockCompetitorCount, (i) {
      final maxScore = _scoreRangeForPeriod(period);
      return LeaderboardEntry(
        userId: 'mock_$i',
        name: _mockNames[i % _mockNames.length],
        avatar: _mockAvatars[i % _mockAvatars.length],
        score: _rng.nextInt(maxScore) + (maxScore ~/ 4),
        level: _rng.nextInt(10) + 1,
        quizzesPlayed: _rng.nextInt(50) + 1,
        isPremium: _rng.nextBool() && _rng.nextBool(),
      );
    });

    _saveToCache(mock, period);
    return _insertCurrentUser(mock, currentUser);
  }

  List<LeaderboardEntry> _insertCurrentUser(
    List<LeaderboardEntry> list,
    GuestUser user,
  ) {
    final all = List<LeaderboardEntry>.from(list);
    final myEntry = LeaderboardEntry(
      userId: user.guestId,
      name: user.name,
      avatar: user.avatar,
      score: user.totalCorrect * 10,
      level: user.level,
      quizzesPlayed: user.quizzesPlayed,
      isPremium: user.isPremium,
    );
    all.removeWhere((e) => e.userId == user.guestId);
    all.add(myEntry);
    all.sort((a, b) => b.score.compareTo(a.score));
    for (var i = 0; i < all.length; i++) {
      all[i].rank = i + 1;
    }
    return all.take(AppConfig.leaderboardTopN).toList();
  }

  int _scoreRangeForPeriod(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.daily: return 500;
      case LeaderboardPeriod.weekly: return 2000;
      case LeaderboardPeriod.monthly: return 8000;
    }
  }

  List<LeaderboardEntry>? _loadFromCache(LeaderboardPeriod period) {
    final key = '${AppConfig.keyLeaderboardCache}_${period.name}';
    final json = StorageService.getString(key);
    if (json == null) return null;
    try {
      final list = (jsonDecode(json) as List)
          .map((e) => LeaderboardEntry.fromMap(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      return null;
    }
  }

  void _saveToCache(List<LeaderboardEntry> entries, LeaderboardPeriod period) {
    final key = '${AppConfig.keyLeaderboardCache}_${period.name}';
    final json = jsonEncode(entries.map((e) => e.toMap()).toList());
    StorageService.setString(key, json);
  }
}
