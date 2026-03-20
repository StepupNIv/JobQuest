// Ad configuration
// TODO: Replace TEST IDs with real AdMob IDs before Play Store submission
// Get real IDs from: https://apps.admob.com

class AdConfig {
  AdConfig._();

  static const bool useTestIds = true; // ← Change to false in production

  // ── TEST IDs (Google-provided, safe to commit) ──────────────────────────
  static const _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // ── PRODUCTION IDs (fill in before release) ─────────────────────────────
  // TODO: Replace empty strings with your real ad unit IDs
  static const _prodBannerId = ''; // e.g. ca-app-pub-XXXX/YYYY
  static const _prodInterstitialId = '';
  static const _prodRewardedId = '';

  // ── Active IDs ───────────────────────────────────────────────────────────
  static String get bannerId => useTestIds ? _testBannerId : _prodBannerId;
  static String get interstitialId => useTestIds ? _testInterstitialId : _prodInterstitialId;
  static String get rewardedId => useTestIds ? _testRewardedId : _prodRewardedId;

  // Frequency caps (number of quizzes between interstitials)
  static const interstitialEveryNQuizzes = 3;
  static const maxBannerFailRetries = 2;

  // Google Play compliance
  // ✓ No interstitials during quiz answering
  // ✓ Rewarded ads are always optional
  // ✓ Banners placed away from primary action buttons
}
