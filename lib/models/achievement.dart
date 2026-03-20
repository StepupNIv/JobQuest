class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String unlockCondition;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.unlockCondition,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  static List<Achievement> allAchievements() => [
    Achievement(id:'first_quiz', title:'First Steps', description:'Complete your first quiz', emoji:'🎯', unlockCondition:'quizzesPlayed >= 1'),
    Achievement(id:'quiz_5', title:'Getting Warmed Up', description:'Complete 5 quizzes', emoji:'🔥', unlockCondition:'quizzesPlayed >= 5'),
    Achievement(id:'quiz_25', title:'Quiz Addict', description:'Complete 25 quizzes', emoji:'📚', unlockCondition:'quizzesPlayed >= 25'),
    Achievement(id:'quiz_100', title:'Century!', description:'Complete 100 quizzes', emoji:'💯', unlockCondition:'quizzesPlayed >= 100'),
    Achievement(id:'perfect_score', title:'Perfectionist', description:'Get 100% in a quiz', emoji:'⭐', unlockCondition:'isPerfect'),
    Achievement(id:'streak_3', title:'On a Roll!', description:'3-day streak', emoji:'🔥', unlockCondition:'streak >= 3'),
    Achievement(id:'streak_7', title:'Week Warrior', description:'7-day streak', emoji:'⚡', unlockCondition:'streak >= 7'),
    Achievement(id:'streak_30', title:'Monthly Monster', description:'30-day streak', emoji:'🏆', unlockCondition:'streak >= 30'),
    Achievement(id:'level_5', title:'Level 5 Unlocked', description:'Reach Level 5', emoji:'🌟', unlockCondition:'level >= 5'),
    Achievement(id:'level_10', title:'Level 10 Legend', description:'Reach Level 10', emoji:'👑', unlockCondition:'level >= 10'),
    Achievement(id:'accuracy_80', title:'Sharpshooter', description:'80%+ accuracy overall', emoji:'🎯', unlockCondition:'accuracy >= 80'),
    Achievement(id:'accuracy_90', title:'Einstein Mode', description:'90%+ accuracy overall', emoji:'🧠', unlockCondition:'accuracy >= 90'),
    Achievement(id:'coins_100', title:'First Fortune', description:'Earn 100 coins', emoji:'🪙', unlockCondition:'coins >= 100'),
    Achievement(id:'premium', title:'Premium Patron', description:'Activated premium plan', emoji:'💎', unlockCondition:'isPremium'),
    Achievement(id:'night_owl', title:'Night Owl', description:'Play a quiz after 11 PM', emoji:'🦉', unlockCondition:'nightPlay'),
  ];
}
