import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/premium_service.dart';
import '../../services/analytics_service.dart';
import '../../config/app_strings.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});
  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _loading = false;

  Future<void> _purchase() async {
    if (_loading) return;
    setState(() => _loading = true);
    AnalyticsService.logMockPurchaseAttempted();
    final result = await PremiumService().purchase();
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.status == PremiumStatus.success) {
      await ref.read(guestUserProvider.notifier).activatePremium();
      if (!mounted) return;
      _showSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Purchase failed. Try again.'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('🎉 Welcome to Premium!', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('You now have full access — no ads, premium tests, and extra rewards!',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('Let\'s Go! 🚀'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Premium'), backgroundColor: AppColors.background),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.4), blurRadius: 24)],
                    ),
                    child: const Center(child: Text('👑', style: TextStyle(fontSize: 40))),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  const Text(AppStrings.premiumTitle,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(AppStrings.premiumTagline,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(AppStrings.premiumPrice,
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            // Features
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _FeatureTile(emoji: '🚫', title: AppStrings.noAds, desc: 'Clean, distraction-free experience'),
                  _FeatureTile(emoji: '📋', title: AppStrings.premiumTests, desc: 'Full-length mock tests like real exams'),
                  _FeatureTile(emoji: '🎁', title: AppStrings.extraRewards, desc: '2× daily coins and XP bonuses'),
                  _FeatureTile(emoji: '👑', title: AppStrings.premiumBadge, desc: 'Stand out on the leaderboard'),
                  const SizedBox(height: 8),
                  const Text(AppStrings.virtualCurrencyNotice,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  if (isPremium)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.premiumGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('👑', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text('Premium Active', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                    )
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _purchase,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text(AppStrings.getPremium, style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        final r = await PremiumService().restore();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(r.message ?? 'No active subscription found')),
                        );
                      },
                      child: const Text('Restore Purchase', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text(AppStrings.premiumDisclaimer,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String emoji, title, desc;
  const _FeatureTile({required this.emoji, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ),
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }
}
