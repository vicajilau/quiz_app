import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:quiz_app/domain/models/history/quiz_mode.dart';
import 'package:quiz_app/domain/models/history/quiz_record.dart';

/// Handles Hive initialization and adapter registration.
class HiveInitializer {
  static bool _initialized = false;

  /// Initializes Hive with all required adapters.
  /// Safe to call multiple times - only initializes once.
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Hive for Flutter (handles path for all platforms including web)
    await Hive.initFlutter();

    // Register type adapters
    _registerAdapters();

    _initialized = true;
  }

  static void _registerAdapters() {
    // Register adapters only if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(QuizModeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(QuizRecordAdapter());
    }
  }

  /// Closes all open Hive boxes.
  static Future<void> closeAll() async {
    await Hive.close();
    _initialized = false;
  }

  /// Returns whether Hive has been initialized.
  static bool get isInitialized => _initialized;
}
