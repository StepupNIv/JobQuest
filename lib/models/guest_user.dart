import 'dart:convert';

class CategoryProgress {
  final String category;
  int quizzesPlayed;
  int totalCorrect;
  int totalQuestions;

  CategoryProgress({
    required this.category,
    this.quizzesPlayed = 0,
    this.totalCorrect = 0,
    this.totalQuestions = 0,
  });

  double get accuracy =>
      totalQuestions == 0 ? 0 : (totalCorrect / totalQuestions) * 100;

  Map<String, dynamic> toMap() => {
        'category': category,
        'quizzesPlayed': quizzesPlayed,
        'totalCorrect': totalCorrect,
        'totalQuestions': totalQuestions,
      };

  factory CategoryProgress.fromMap(Map<String, dynamic> m) => CategoryProgress(
        category: m['category'] as String,
        quizzesPlayed: m['quizzesPlayed'] as int? ?? 0,
        totalCorrect: m['totalCorrect'] as int? ?? 0,
        totalQuestions: m['totalQuestions'] as int? ?? 0,
      );
}

class GuestUser {
  final String guestId;
  String name;
  String avatar; // emoji string
  int level;
  int xp;
  int coins;
  int streak;
  int quizzesPlayed;
  int totalCorrect;
  int totalQuestions;
  bool isPremium;
  String premiumPlan;
  DateTime createdAt;
  DateTime? lastActiveAt;
  String language;
  List<CategoryProgress> categoryProgress;
  List<String> unlockedAchievements;

  GuestUser({
    required this.guestId,
    required this.name,
    this.avatar = '🎯',
    this.level = 1,
    this.xp = 0,
    this.coins = 0,
    this.streak = 0,
    this.quizzesPlayed = 0,
    this.totalCorrect = 0,
    this.totalQuestions = 0,
    this.isPremium = false,
    this.premiumPlan = '',
    required this.createdAt,
    this.lastActiveAt,
    this.language = 'en',
    List<CategoryProgress>? categoryProgress,
    List<String>? unlockedAchievements,
  })  : categoryProgress = categoryProgress ?? [],
        unlockedAchievements = unlockedAchievements ?? [];

  double get overallAccuracy =>
      totalQuestions == 0 ? 0 : (totalCorrect / totalQuestions) * 100;

  int get xpForNextLevel => 200 * level;
  double get xpProgress => (xp % xpForNextLevel) / xpForNextLevel;

  Map<String, dynamic> toMap() => {
        'guestId': guestId,
        'name': name,
        'avatar': avatar,
        'level': level,
        'xp': xp,
        'coins': coins,
        'streak': streak,
        'quizzesPlayed': quizzesPlayed,
        'totalCorrect': totalCorrect,
        'totalQuestions': totalQuestions,
        'isPremium': isPremium,
        'premiumPlan': premiumPlan,
        'createdAt': createdAt.toIso8601String(),
        'lastActiveAt': lastActiveAt?.toIso8601String(),
        'language': language,
        'categoryProgress': categoryProgress.map((c) => c.toMap()).toList(),
        'unlockedAchievements': unlockedAchievements,
      };

  factory GuestUser.fromMap(Map<String, dynamic> m) => GuestUser(
        guestId: m['guestId'] as String,
        name: m['name'] as String? ?? 'Guest',
        avatar: m['avatar'] as String? ?? '🎯',
        level: m['level'] as int? ?? 1,
        xp: m['xp'] as int? ?? 0,
        coins: m['coins'] as int? ?? 0,
        streak: m['streak'] as int? ?? 0,
        quizzesPlayed: m['quizzesPlayed'] as int? ?? 0,
        totalCorrect: m['totalCorrect'] as int? ?? 0,
        totalQuestions: m['totalQuestions'] as int? ?? 0,
        isPremium: m['isPremium'] as bool? ?? false,
        premiumPlan: m['premiumPlan'] as String? ?? '',
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        lastActiveAt: m['lastActiveAt'] != null
            ? DateTime.tryParse(m['lastActiveAt'] as String)
            : null,
        language: m['language'] as String? ?? 'en',
        categoryProgress: (m['categoryProgress'] as List<dynamic>?)
                ?.map((e) => CategoryProgress.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        unlockedAchievements: List<String>.from(m['unlockedAchievements'] as List? ?? []),
      );

  String toJson() => jsonEncode(toMap());
  factory GuestUser.fromJson(String json) =>
      GuestUser.fromMap(jsonDecode(json) as Map<String, dynamic>);

  GuestUser copyWith({
    String? name,
    String? avatar,
    int? level,
    int? xp,
    int? coins,
    int? streak,
    int? quizzesPlayed,
    int? totalCorrect,
    int? totalQuestions,
    bool? isPremium,
    String? premiumPlan,
    DateTime? lastActiveAt,
    String? language,
    List<CategoryProgress>? categoryProgress,
    List<String>? unlockedAchievements,
  }) =>
      GuestUser(
        guestId: guestId,
        name: name ?? this.name,
        avatar: avatar ?? this.avatar,
        level: level ?? this.level,
        xp: xp ?? this.xp,
        coins: coins ?? this.coins,
        streak: streak ?? this.streak,
        quizzesPlayed: quizzesPlayed ?? this.quizzesPlayed,
        totalCorrect: totalCorrect ?? this.totalCorrect,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        isPremium: isPremium ?? this.isPremium,
        premiumPlan: premiumPlan ?? this.premiumPlan,
        createdAt: createdAt,
        lastActiveAt: lastActiveAt ?? this.lastActiveAt,
        language: language ?? this.language,
        categoryProgress: categoryProgress ?? this.categoryProgress,
        unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      );
}
