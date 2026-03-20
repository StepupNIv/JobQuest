import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/storage_service.dart';
import '../../config/app_config.dart';
import '../../config/app_strings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifEnabled = ref.watch(notificationsEnabledProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.settings), backgroundColor: AppColors.background),
      body: ListView(
        children: [
          _SectionHeader('Preferences'),
          _ToggleTile(
            icon: '🔔', title: AppStrings.notifications,
            subtitle: 'Daily challenge and streak reminders',
            value: notifEnabled,
            onChanged: (v) async {
              ref.read(notificationsEnabledProvider.notifier).state = v;
              await StorageService.setBool(AppConfig.keyNotificationsEnabled, v);
            },
          ),
          _ToggleTile(
            icon: '🔊', title: 'Sound Effects',
            subtitle: 'Play sounds during quiz',
            value: soundEnabled,
            onChanged: (v) async {
              ref.read(soundEnabledProvider.notifier).state = v;
              await StorageService.setBool(AppConfig.keySoundEnabled, v);
            },
          ),
          _SectionHeader('Account'),
          _Tile(icon: '👑', title: 'Premium', subtitle: 'Upgrade to no-ads plan',
              onTap: () => Navigator.pushNamed(context, '/premium')),
          _Tile(icon: '👤', title: 'Edit Profile', subtitle: 'Change name and avatar',
              onTap: () => Navigator.pushNamed(context, '/profile')),
          _SectionHeader('Legal & Support'),
          _Tile(icon: '🔒', title: AppStrings.privacyPolicy, subtitle: 'How we handle your data',
              onTap: () => _launchUrl(context, AppConfig.privacyPolicyUrl)),
          _Tile(icon: '📄', title: AppStrings.termsConditions, subtitle: 'Terms of use',
              onTap: () => _launchUrl(context, AppConfig.termsUrl)),
          _Tile(icon: '💬', title: AppStrings.contactSupport, subtitle: AppConfig.supportEmail,
              onTap: () {}),
          _SectionHeader('Danger Zone'),
          _Tile(
            icon: '🗑️', title: AppStrings.resetProgress,
            subtitle: 'Erase all progress — cannot be undone',
            color: AppColors.danger,
            onTap: () => _confirmReset(context, ref),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '${AppConfig.appName} v${AppConfig.appVersion}\nMade with ❤️ in India\n\n'
              'Coins and XP are virtual rewards with no real-world monetary value.\n'
              'This app is not affiliated with any government examination body.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: $url\n(Web browser integration coming soon)')),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Reset Progress?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(AppStrings.resetConfirm, style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(guestUserProvider.notifier).reset();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset. Fresh start! 🔄')),
              );
            },
            child: const Text(AppStrings.confirm, style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }
}

class _Tile extends StatelessWidget {
  final String icon, title, subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
      onTap: onTap,
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String icon, title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon, required this.title,
    required this.subtitle, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}
