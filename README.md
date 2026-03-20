# JobQuest 🎯 — Practice Smart, Level Up

> India-first gamified quiz app for exam prep and job seekers. No-auth MVP, ad-monetized, premium-ready.

---

## Architecture Overview

```
lib/
├── main.dart              # Crash-safe bootstrap with runZonedGuarded
├── app.dart               # MaterialApp + routing
├── config/
│   ├── app_config.dart    # Constants, feature flags, storage keys
│   ├── app_strings.dart   # Centralized UI strings (localization-ready)
│   └── ad_config.dart     # AdMob IDs (test/prod toggle)
├── theme/
│   └── app_theme.dart     # Dark theme, colors, gradients
├── models/                # Data classes (GuestUser, Question, etc.)
├── repositories/
│   ├── question_repository.dart   # Loads & caches JSON questions
│   └── leaderboard_repository.dart # Local leaderboard generation
├── services/
│   ├── storage_service.dart       # SharedPreferences wrapper (crash-safe)
│   ├── guest_user_service.dart    # User state, XP, streak, coins
│   ├── gamification_service.dart  # XP/coin calculation, achievement checks
│   ├── premium_service.dart       # Mock payment interface (Razorpay-ready)
│   ├── ad_service.dart            # Banner/Interstitial/Rewarded (crash-safe)
│   ├── reminder_service.dart      # Notification abstraction (FCM-ready)
│   └── analytics_service.dart     # Firebase Analytics wrapper (no-op safe)
├── providers/
│   └── providers.dart     # All Riverpod providers
├── features/
│   ├── splash/, onboarding/, home/
│   ├── quiz/, leaderboard/, profile/
│   ├── premium/, rewards/, settings/
└── widgets/               # StatChip, EmptyState, ShimmerBox, GradientButton
```

---

## Quick Start

```bash
# 1. Get dependencies
flutter pub get

# 2. Run on device/emulator
flutter run

# 3. Build release APK
flutter build apk --release
```

Requirements: Flutter ≥3.0.0 · Dart ≥3.0.0 · Android minSdk 21

---

## Guest Mode Flow

1. App launches → `SplashScreen` initializes `GuestUserService`
2. If first time → `OnboardingScreen` → marks `onboarding_done = true`
3. `GuestUser` auto-created with UUID, stored in `SharedPreferences`
4. All progress (XP, coins, streak, category stats) persisted locally
5. No login, no server, no auth — fully offline MVP

---

## Question Bank (632 Questions)

| File | Count |
|------|-------|
| aptitude_easy.json | 58 |
| aptitude_medium.json | 57 |
| aptitude_hard.json | 30 |
| reasoning_easy.json | 57 |
| reasoning_medium.json | 62 |
| reasoning_hard.json | 30 |
| english_easy.json | 67 |
| english_medium.json | 62 |
| english_hard.json | 35 |
| gk_easy.json | 75 |
| gk_medium.json | 69 |
| gk_hard.json | 30 |
| **TOTAL** | **632** |

Questions include: id, category, topic, difficulty, question, options[4], correctAnswer, explanation, timeLimit, language

---

## Ad Setup

### Replace Test IDs before Play Store submission

In `lib/config/ad_config.dart`:
```dart
static const bool useTestIds = false; // ← Change this

static const _prodBannerId = 'ca-app-pub-XXXX/YYYY';
static const _prodInterstitialId = 'ca-app-pub-XXXX/ZZZZ';
static const _prodRewardedId = 'ca-app-pub-XXXX/WWWW';
```

In `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Replace TEST App ID -->
<meta-data
  android:name="com.google.android.gms.ads.APPLICATION_ID"
  android:value="ca-app-pub-YOUR_REAL_APP_ID~XXXXXXXX"/>
```

### Google Play Compliance Rules (already implemented)
- ✅ No interstitials during quiz answering
- ✅ Rewarded ads are always optional
- ✅ Banners placed away from primary action buttons
- ✅ Ad failures never crash app flow

---

## Premium Mock Flow

Current: MockPaymentService simulates 2s delay then success.

To integrate Razorpay:
```dart
// In lib/services/premium_service.dart
// Replace MockPaymentService with:
class RazorpayPaymentService implements PaymentServiceInterface {
  @override
  Future<PremiumResult> purchase(String planId) async {
    // Initialize Razorpay SDK, open checkout
    // Handle success/failure callbacks
  }
}
```

To integrate Google Play Billing (in_app_purchase):
- Replace with `in_app_purchase` package
- Same interface: implement `PaymentServiceInterface`

---

## Firebase Optional Setup

All Firebase calls are wrapped and fail safely.

To enable:
1. Add `google-services.json` to `android/app/`
2. Uncomment in `pubspec.yaml`:
   ```yaml
   firebase_core: ^2.24.0
   firebase_analytics: ^10.7.0
   firebase_crashlytics: ^3.4.8
   ```
3. Uncomment init in `main.dart`:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```
4. Uncomment calls in `AnalyticsService` and error handlers

---

## AndroidManifest Changes Needed

```xml
<!-- Add your real AdMob App ID -->
<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"
  android:value="ca-app-pub-REAL_ID~REAL_ID"/>

<!-- Add if using notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Add privacy policy URL to app description on Play Store -->
```

---

## Before Play Store Release

- [ ] Replace test AdMob IDs with real production IDs
- [ ] Set `useTestIds = false` in `ad_config.dart`
- [ ] Set `enableFirebase = true` and configure Firebase
- [ ] Add real `google-services.json`
- [ ] Set `enableRealPayments = true` and integrate payment SDK
- [ ] Add Privacy Policy and Terms URLs
- [ ] Update `app_config.dart` support email
- [ ] Change package name from `com.jobquest.app` to your domain
- [ ] Generate upload keystore for signed release APK
- [ ] Complete Play Store listing (screenshots, description)
- [ ] Test on low-end Android device (3GB RAM, API 21)

---

## State Management

Uses **Riverpod** (`flutter_riverpod: ^2.4.9`):

| Provider | Type | Purpose |
|----------|------|---------|
| `guestUserProvider` | StateNotifier | Full user state |
| `onboardingDoneProvider` | StateProvider | Onboarding flag |
| `premiumProvider` | Provider | Premium gate (derived) |
| `quizSessionProvider` | StateNotifier | Active quiz session |
| `leaderboardProvider` | Provider.family | Leaderboard per period |
| `achievementsProvider` | Provider | Achievement list |
| `notificationsEnabledProvider` | StateProvider | Settings |
| `soundEnabledProvider` | StateProvider | Settings |

---

## Virtual Currency Notice (Google Play Compliance)

> Coins and XP are virtual rewards with no real-world monetary value.
> They cannot be exchanged for cash or any real-world benefit.
> Premium plan is a mock payment — no real billing is enabled in this MVP.

---

## Notes

- App is fully offline — no internet required for core functionality
- All services fail gracefully — no crash if storage/ads/Firebase fail
- India-first: INR pricing, GK India focus, relevant examples
- Dark theme optimized for mid-range Android devices
