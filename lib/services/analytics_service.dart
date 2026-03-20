// Analytics wrapper — fails safely if Firebase not configured
// TODO: Uncomment Firebase imports and calls after configuring Firebase

class AnalyticsService {
  static bool _initialized = false;

  static Future<void> init() async {
    // TODO: Initialize Firebase Analytics here
    // try {
    //   await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    //   _initialized = true;
    // } catch (_) {}
    _initialized = true;
  }

  static Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    if (!_initialized) return;
    try {
      // TODO: await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
      assert(() { print('[Analytics] $name ${params ?? ''}'); return true; }());
    } catch (_) {}
  }

  static Future<void> logAppOpen() => logEvent('app_open');
  static Future<void> logOnboardingComplete() => logEvent('onboarding_complete');
  static Future<void> logQuizStarted(String category, String difficulty) =>
      logEvent('quiz_started', {'category': category, 'difficulty': difficulty});
  static Future<void> logQuizCompleted(String category, int score, int total) =>
      logEvent('quiz_completed', {'category': category, 'score': score, 'total': total});
  static Future<void> logCategoryOpen(String category) =>
      logEvent('category_open', {'category': category});
  static Future<void> logRewardClaimed(int coins, int xp) =>
      logEvent('reward_claimed', {'coins': coins, 'xp': xp});
  static Future<void> logPremiumScreenOpened() => logEvent('premium_screen_opened');
  static Future<void> logMockPurchaseAttempted() => logEvent('mock_purchase_attempted');
  static Future<void> logAdRewardClaimed() => logEvent('ad_reward_claimed');
}
