class LeaderboardEntry {
  final String userId;
  final String name;
  final String avatar;
  final int score;
  final int level;
  final int quizzesPlayed;
  final bool isPremium;
  int rank;

  LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.score,
    required this.level,
    required this.quizzesPlayed,
    this.isPremium = false,
    this.rank = 0,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'avatar': avatar,
        'score': score,
        'level': level,
        'quizzesPlayed': quizzesPlayed,
        'isPremium': isPremium,
        'rank': rank,
      };

  factory LeaderboardEntry.fromMap(Map<String, dynamic> m) => LeaderboardEntry(
        userId: m['userId'] as String,
        name: m['name'] as String,
        avatar: m['avatar'] as String? ?? '🎯',
        score: m['score'] as int? ?? 0,
        level: m['level'] as int? ?? 1,
        quizzesPlayed: m['quizzesPlayed'] as int? ?? 0,
        isPremium: m['isPremium'] as bool? ?? false,
        rank: m['rank'] as int? ?? 0,
      );
}
