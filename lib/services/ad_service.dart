import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';
import 'premium_service.dart';
import 'storage_service.dart';
import '../config/app_config.dart';

class AdService {
  static final AdService _instance = AdService._();
  AdService._();
  factory AdService() => _instance;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _bannerLoaded = false;
  bool _interstitialLoaded = false;
  bool _rewardedLoaded = false;

  int _quizCountSinceLastInterstitial = 0;

  static Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      // Ad init failure must never crash app
      assert(() { print('[AdService] init failed: $e'); return true; }());
    }
  }

  bool get _adsEnabled => PremiumService().canShowAds();

  // ── Banner ────────────────────────────────────────────────────────────────
  BannerAd? get bannerAd => _bannerLoaded ? _bannerAd : null;

  void loadBanner() {
    if (!_adsEnabled || AdConfig.bannerId.isEmpty) return;
    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _bannerLoaded = true,
        onAdFailedToLoad: (_, __) => _bannerLoaded = false,
      ),
    )..load();
  }

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerLoaded = false;
  }

  // ── Interstitial ─────────────────────────────────────────────────────────
  void loadInterstitial() {
    if (!_adsEnabled || AdConfig.interstitialId.isEmpty) return;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) { _interstitialAd = ad; _interstitialLoaded = true; },
        onAdFailedToLoad: (_) { _interstitialLoaded = false; },
      ),
    );
  }

  // Only show after quiz completion, respecting frequency cap
  Future<void> maybeShowInterstitial() async {
    _quizCountSinceLastInterstitial++;
    if (_quizCountSinceLastInterstitial < AdConfig.interstitialEveryNQuizzes) return;
    if (!_interstitialLoaded || _interstitialAd == null) return;
    _quizCountSinceLastInterstitial = 0;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); _interstitialLoaded = false; loadInterstitial(); },
      onAdFailedToShowFullScreenContent: (ad, _) { ad.dispose(); _interstitialLoaded = false; },
    );
    try { await _interstitialAd!.show(); } catch (_) {}
  }

  // ── Rewarded ─────────────────────────────────────────────────────────────
  void loadRewarded() {
    if (AdConfig.rewardedId.isEmpty) return;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) { _rewardedAd = ad; _rewardedLoaded = true; },
        onAdFailedToLoad: (_) { _rewardedLoaded = false; },
      ),
    );
  }

  /// Returns true if reward was granted. Always optional for user.
  Future<bool> showRewarded() async {
    if (!_rewardedLoaded || _rewardedAd == null) return false;
    bool rewarded = false;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); _rewardedLoaded = false; loadRewarded(); },
      onAdFailedToShowFullScreenContent: (ad, _) { ad.dispose(); _rewardedLoaded = false; },
    );
    try {
      await _rewardedAd!.show(onUserEarnedReward: (_, __) { rewarded = true; });
    } catch (_) {}
    return rewarded;
  }

  bool get isRewardedReady => _rewardedLoaded;

  void preloadAll() {
    loadBanner();
    loadInterstitial();
    loadRewarded();
  }

  void dispose() {
    disposeBanner();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
