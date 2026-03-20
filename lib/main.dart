import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'services/analytics_service.dart';
import 'services/ad_service.dart';
import 'repositories/question_repository.dart';

Future<void> main() async {
  await runZonedGuarded(_boot, _onError);
}

Future<void> _boot() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crash handlers
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // TODO: FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    // TODO: FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // System UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Sequential safe init
  await StorageService.init();
  await AnalyticsService.init();
  await AdService.init();
  await QuestionRepository().loadAll();

  await AnalyticsService.logAppOpen();

  runApp(const ProviderScope(child: JobQuestApp()));
}

void _onError(Object error, StackTrace stack) {
  // TODO: FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  debugPrint('[JobQuest] Unhandled error: $error\n$stack');
}
