import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color? color;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.emoji,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: c, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
