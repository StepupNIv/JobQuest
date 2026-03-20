import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/achievement.dart';
import '../../widgets/stat_chip.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(guestUserProvider);
    final achievements = ref.watch(achievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Avatar + name
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _showEditProfile(context, ref, user.name, user.avatar),
                        child: Stack(
                          children: [
                            Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Text(user.avatar, style: const TextStyle(fontSize: 48)),
                              ),
                            ),
                            Positioned(
                              right: 0, bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.surface, shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: AppColors.primary, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(user.name,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Level ${user.level}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        if (user.isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.premiumGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('👑 Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ]),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(),
                const SizedBox(height: 24),
                // XP progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('XP Progress', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text('${user.xp} / ${user.xpForNextLevel} XP',
                          style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: user.xpProgress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Stats
                Row(
                  children: [
                    Expanded(child: StatChip(label: 'XP', value: '${user.xp}', emoji: '⭐', color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: StatChip(label: 'Coins', value: '${user.coins}', emoji: '🪙', color: AppColors.secondary)),
                    const SizedBox(width: 10),
                    Expanded(child: StatChip(label: 'Streak', value: '${user.streak}🔥', emoji: '', color: AppColors.danger)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: StatChip(label: 'Quizzes', value: '${user.quizzesPlayed}', emoji: '📚', color: AppColors.accent)),
                    const SizedBox(width: 10),
                    Expanded(child: StatChip(label: 'Accuracy', value: '${user.overallAccuracy.toStringAsFixed(0)}%', emoji: '🎯', color: AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: StatChip(label: 'Correct', value: '${user.totalCorrect}', emoji: '✅', color: AppColors.success)),
                  ],
                ),
                const SizedBox(height: 28),
                // Category Progress
                if (user.categoryProgress.isNotEmpty) ...[
                  const Text('Category Progress', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...user.categoryProgress.map((cp) => _CategoryProgressTile(cp: cp)),
                  const SizedBox(height: 20),
                ],
                // Achievements
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Achievements', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${achievements.where((a)=>a.isUnlocked).length}/${achievements.length}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (_, i) => _AchievementCard(achievement: achievements[i]),
                ),
                const SizedBox(height: 20),
                if (!user.isPremium)
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/premium'),
                    icon: const Text('👑'),
                    label: const Text('Upgrade to Premium'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, String name, String avatar) {
    final nameController = TextEditingController(text: name);
    String selectedAvatar = avatar;
    final avatars = ['🎯','🏆','🧠','⚡','🔥','🌟','💡','💪','👑','🚀','🎓','📚'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Your name', labelText: 'Display Name'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: avatars.map((a) => GestureDetector(
                  onTap: () => setS(() => selectedAvatar = a),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: a == selectedAvatar ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: a == selectedAvatar ? AppColors.primary : Colors.transparent),
                    ),
                    child: Text(a, style: const TextStyle(fontSize: 24)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(guestUserProvider.notifier).updateProfile(
                    name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                    avatar: selectedAvatar,
                  );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryProgressTile extends StatelessWidget {
  final dynamic cp;
  const _CategoryProgressTile({required this.cp});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(cp.category as String);
    final acc = cp.accuracy as double;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Text(
            cp.category == 'Aptitude' ? '🔢' : cp.category == 'Reasoning' ? '🧩' : cp.category == 'English' ? '📝' : '🌍',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(cp.category as String, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text('${acc.toStringAsFixed(0)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (acc / 100).clamp(0.0, 1.0),
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? AppColors.primary.withOpacity(0.12) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: unlocked ? AppColors.primary.withOpacity(0.4) : AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(unlocked ? achievement.emoji : '🔒',
                style: TextStyle(fontSize: 28, color: unlocked ? null : AppColors.textMuted.withOpacity(0.5))),
            const SizedBox(height: 6),
            Text(
              achievement.title,
              style: TextStyle(
                  color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
