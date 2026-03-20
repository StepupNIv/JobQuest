import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../repositories/leaderboard_repository.dart';
import '../../models/leaderboard_entry.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedLeaderboardPeriodProvider);
    final entries = ref.watch(leaderboardProvider(period));
    final user = ref.watch(guestUserProvider);
    final myRank = entries.indexWhere((e) => e.userId == user?.guestId) + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🏆 Leaderboard'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Period tabs
          _PeriodTabs(selected: period),
          // My rank banner
          if (myRank > 0)
            _MyRankBanner(rank: myRank, user: user),
          // Podium
          if (entries.length >= 3)
            _Podium(entries: entries.take(3).toList()),
          // Full list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: entries.length,
              itemBuilder: (_, i) => _RankTile(entry: entries[i], isMe: entries[i].userId == user?.guestId),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabs extends ConsumerWidget {
  final LeaderboardPeriod selected;
  const _PeriodTabs({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periods = LeaderboardPeriod.values;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: periods.map((p) {
          final active = p == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(selectedLeaderboardPeriodProvider.notifier).state = p,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  p.name.substring(0,1).toUpperCase() + p.name.substring(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.textMuted,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MyRankBanner extends StatelessWidget {
  final int rank;
  final dynamic user;
  const _MyRankBanner({required this.rank, this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(user?.avatar ?? '🎯', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Rank: #$rank',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(user?.name ?? 'You',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          Text('#$rank',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    final medals = ['🥇', '🥈', '🥉'];
    final heights = [110.0, 80.0, 70.0];
    final order = [1, 0, 2]; // show 2nd, 1st, 3rd in podium visual

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: order.map((i) {
          final e = entries[i];
          return Column(
            children: [
              Text(e.avatar, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text(e.name.split(' ').first,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
                  overflow: TextOverflow.ellipsis),
              Text('${e.score}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
              const SizedBox(height: 4),
              Container(
                width: 80,
                height: heights[i],
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: i == 0
                        ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                        : i == 1
                            ? [const Color(0xFFC0C0C0), const Color(0xFF808080)]
                            : [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(medals[i], style: const TextStyle(fontSize: 22)),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0);
  }
}

class _RankTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isMe;
  const _RankTile({required this.entry, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withOpacity(0.12) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isMe ? AppColors.primary.withOpacity(0.4) : Colors.transparent),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('#${entry.rank}',
                style: TextStyle(
                    color: entry.rank <= 3 ? AppColors.secondary : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          Text(entry.avatar, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(entry.name,
                    style: TextStyle(
                        color: isMe ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14)),
                if (entry.isPremium) ...[
                  const SizedBox(width: 4),
                  const Text('👑', style: TextStyle(fontSize: 12)),
                ],
              ]),
              Text('Level ${entry.level} • ${entry.quizzesPlayed} quizzes',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ]),
          ),
          Text('${entry.score}',
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
