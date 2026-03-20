// Reminder service abstraction — ready for flutter_local_notifications / FCM
// Currently no-op; architecture is FCM-ready
import 'storage_service.dart';
import '../config/app_config.dart';

enum ReminderType { dailyChallenge, streak, comeback, reward }

class ReminderService {
  static final ReminderService _instance = ReminderService._();
  ReminderService._();
  factory ReminderService() => _instance;

  bool get notificationsEnabled =>
      StorageService.getBool(AppConfig.keyNotificationsEnabled) ?? true;

  Future<void> init() async {
    // TODO: Initialize flutter_local_notifications
    // final plugin = FlutterLocalNotificationsPlugin();
    // await plugin.initialize(InitializationSettings(...));
  }

  Future<void> scheduleReminder(ReminderType type) async {
    if (!notificationsEnabled) return;
    // TODO: Implement scheduling per type
    // Daily challenge: 9 AM every day
    // Streak: If user hasn't played today, remind at 8 PM
    // Comeback: If no play for 2 days, remind
    // Reward: When daily reward is ready
  }

  Future<void> cancelReminder(ReminderType type) async {
    // TODO: Cancel specific notification
  }

  Future<void> cancelAll() async {
    // TODO: Cancel all notifications
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await StorageService.setBool(AppConfig.keyNotificationsEnabled, enabled);
    if (!enabled) await cancelAll();
  }
}
