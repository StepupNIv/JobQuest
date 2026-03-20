class AppConfig {
  AppConfig._();

  static const appName = 'JobQuest';
  static const appVersion = '1.0.0';
  static const buildNumber = 1;

  // Feature flags
  static const enableFirebase = false;
  static const enableRealPayments = false;
  static const enablePushNotifications = false;
  static const enableCrashlytics = false;

  // Mock flags
  static const mockPremiumSuccessDelay = Duration(seconds: 2);
  static const useTestAdIds = true; // Set false before Play Store submission

  // Gamification
  static const xpPerCorrect = 10;
  static const xpPerWrongPenalty = 0; // no penalty for MVP
  static const coinsPerQuiz = 5;
  static const coinsPerPerfect = 25;
  static const baseXpPerLevel = 200;
  static const maxDailyQuizCount = 20;

  // Quiz
  static const defaultQuizSize = 10;
  static const dailyChallengeSize = 15;
  static const defaultTimeLimitSeconds = 30;

  // Streaks
  static const streakRewardCoins = 10;
  static const maxStreakBonus = 50;

  // Leaderboard
  static const leaderboardTopN = 50;
  static const mockCompetitorCount = 30;

  // Premium
  static const premiumPriceDisplay = '₹49';
  static const premiumPlanId = 'jobquest_premium_monthly';

  // Storage keys — centralized here
  static const keyGuestUser = 'guest_user_v2';
  static const keyOnboardingDone = 'onboarding_done';
  static const keyLastActive = 'last_active';
  static const keyAdFrequencyData = 'ad_freq_data';
  static const keyLeaderboardCache = 'leaderboard_cache';
  static const keyAchievements = 'achievements_v1';
  static const keyDailyChallenge = 'daily_challenge';
  static const keyNotificationsEnabled = 'notif_enabled';
  static const keyHapticEnabled = 'haptic_enabled';
  static const keySoundEnabled = 'sound_enabled';

  // Play Store / Legal (placeholder URLs)
  static const privacyPolicyUrl = 'https://jobquest.app/privacy';
  static const termsUrl = 'https://jobquest.app/terms';
  static const supportEmail = 'support@jobquest.app';
  static const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.jobquest.app';
}
