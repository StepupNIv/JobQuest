import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/storage_service.dart';
import '../../config/app_config.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});
  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  bool _dailyClaimable = false;
  bool _justClaimed = false;

  @override
  void initState() {
    super.initState();
    _checkDailyClaim();
  }

  void _checkDailyClaim() {
    final lastClaimStr = StorageService.getString('daily_reward_claimed');
    if (lastClaimStr == null) {
      setState(() => _dailyClaimable = true);
      return;
    }
    final last = DateTime.tryParse(lastClaimStr);
    if (last == null) { setState(() => _dailyClaimable = true); return; }
    final diff = DateTime.now().difference(last).inHours;
    setState(() => _dailyClaimable = diff >= 24);
  }

  Future<void> _claimDaily() async {
    if (!_dailyClaimable) return;
    final isPremium = ref.read(premiumProvider);
    final coins = isPremium ? 30 : 15;
    final xp = isPremium ? 40 : 20;
    await ref.read(guestUserProvider.notifier).addCoins(coins);
    await ref.read(guestUserProvider.notifier).addXP(xp);
    await StorageService.setString('daily_reward_claimed', DateTime.now().toIso8601String());
    setState(() { _dailyClaimable = false; _justClaimed = true; });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(guestUserProvider);
    final isPremium = ref.watch(premiumProvider);
    final streak = user?.streak ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('🎁 Rewards'), backgroundColor: AppColors.background),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily reward
            _DailyRewardCard(
              claimable: _dailyClaimable,
              justClaimed: _justClaimed,
              isPremium: isPremium,
              onClaim: _claimDaily,
            ),
            const SizedBox(height: 24),
            // Streak bonus
            _StreakCard(streak: streak),
            const SizedBox(height: 24),
            // Rewarded Ad
            _WatchAdCard(),
            const SizedBox(height: 24),
            // Coins info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Text('ℹ️', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Coins and XP are virtual rewards for fun. They have no real-world monetary value.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyRewardCard extends StatelessWidget {
  final bool claimable, justClaimed, isPremium;
  final VoidCallback onClaim;

  const _DailyRewardCard({
    required this.claimable, required this.justClaimed,
    required this.isPremium, required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final coins = isPremium ? 30 : 15;
    final xp = isPremium ? 40 : 20;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B69), Color(0xFF11998E)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🎁', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Daily Reward ${isPremium ? '👑' : ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Come back every day!', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _RewardPill(emoji: '🪙', value: '+$coins Coins'),
            const SizedBox(width: 10),
            _RewardPill(emoji: '⭐', value: '+$xp XP'),
          ]),
          const SizedBox(height: 16),
          if (justClaimed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('✅ Claimed! See you tomorrow 👋', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
            )
          else
            ElevatedButton(
              onPressed: claimable ? onClaim : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: claimable ? Colors.white : Colors.white24,
                foregroundColor: const Color(0xFF2D1B69),
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                claimable ? 'Claim Daily Reward 🎉' : 'Already Claimed — Come Back Tomorrow!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale();
  }
}

class _RewardPill extends StatelessWidget {
  final String emoji, value;
  const _RewardPill({required this.emoji, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final milestones = [3, 7, 14, 30];
    final nextMilestone = milestones.firstWhere((m) => m > streak, orElse: () => 30);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$streak Day Streak',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Next milestone: $nextMilestone days → +${nextMilestone * 5} bonus coins',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (streak / nextMilestone).clamp(0.0, 1.0),
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.danger),
            minHeight: 8,
          ),
        ),
      ]),
    );
  }
}

class _WatchAdCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Text('📺', style: TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Watch Ad → Earn Coins', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          Text('Optional — totally up to you!', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ])),
        ElevatedButton(
          onPressed: () async {
            // TODO: call AdService().showRewarded() and grant coins if true
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ad not ready — try again shortly!')),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white),
          child: const Text('Watch'),
        ),
      ]),
    );
  }
}
