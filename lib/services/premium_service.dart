import 'guest_user_service.dart';
import '../config/app_config.dart';

// Payment service interface — ready for Razorpay/Google Play Billing
abstract class PaymentServiceInterface {
  Future<PremiumResult> purchase(String planId);
  Future<PremiumResult> restore();
}

enum PremiumStatus { success, failure, cancelled, pending }

class PremiumResult {
  final PremiumStatus status;
  final String? message;
  const PremiumResult(this.status, [this.message]);
}

// Mock implementation — replace with real Razorpay/IAP integration
class MockPaymentService implements PaymentServiceInterface {
  @override
  Future<PremiumResult> purchase(String planId) async {
    // TODO: Replace with Razorpay or Google Play Billing
    await Future.delayed(AppConfig.mockPremiumSuccessDelay);
    return const PremiumResult(PremiumStatus.success, 'Mock payment successful');
  }

  @override
  Future<PremiumResult> restore() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = GuestUserService.currentUser;
    if (user?.isPremium == true) {
      return const PremiumResult(PremiumStatus.success, 'Premium restored');
    }
    return const PremiumResult(PremiumStatus.failure, 'No active subscription found');
  }
}

class PremiumService {
  static final PremiumService _instance = PremiumService._();
  PremiumService._();
  factory PremiumService() => _instance;

  final PaymentServiceInterface _paymentService = MockPaymentService();

  bool get isPremium => GuestUserService.currentUser?.isPremium ?? false;

  Future<PremiumResult> purchase() async {
    if (isPremium) return const PremiumResult(PremiumStatus.success, 'Already premium');
    final result = await _paymentService.purchase(AppConfig.premiumPlanId);
    if (result.status == PremiumStatus.success) {
      await GuestUserService.activatePremium();
    }
    return result;
  }

  Future<PremiumResult> restore() => _paymentService.restore();

  // Feature gates
  bool canShowAds() => !isPremium;
  bool canAccessPremiumTests() => isPremium;
  bool canGetExtraRewards() => isPremium;
}
