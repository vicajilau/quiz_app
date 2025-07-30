import 'package:quiz_app/core/constants/settings.dart';
import 'package:quiz_app/core/deep_copy_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'maso/process_mode.dart';

/// Constants for SharedPreferences keys
class SettingsKeys {
  static const String contextSwitchTime = 'contextSwitchTime';
  static const String ioChannels = 'ioChannels';
  static const String cpuCount = 'cpuCount';
  static const String quantum = 'quantum';
  static const String queueQuanta = 'queueQuanta';
  static const String timeLimit = 'timeLimit';
}

/// Class to manage MASO settings, including persistence and default values
class SettingsMaso with DeepCopy<SettingsMaso> {
  /// The mode of processes, not persisted
  ProcessesMode processesMode;

  /// Time for context switching, persisted
  int contextSwitchTime;

  /// Number of IO channels, persisted
  int ioChannels;

  /// Number of CPUs, persisted
  int cpuCount;

  /// Quantum for Round Robin, persisted
  int quantum;

  /// List of queueQuanta per queue in multi-level feedback queue
  List<int> queueQuanta;

  /// Time limit for Time Limit
  int timeLimit;

  /// Constructor with default values
  SettingsMaso({
    this.processesMode = ProcessesMode.regular,
    this.contextSwitchTime = Settings.defaultContextSwitchTime,
    this.ioChannels = Settings.defaultIoChannels,
    this.cpuCount = Settings.defaultCpuCount,
    this.quantum = Settings.defaultQuantum,
    this.queueQuanta = Settings.defaultQueueQuanta,
    this.timeLimit = Settings.defaultTimeLimit,
  });

  /// Loads settings from SharedPreferences, falling back to defaults
  static Future<SettingsMaso> loadFromPreferences(ProcessesMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final listStr = prefs.getStringList(SettingsKeys.queueQuanta);
    return SettingsMaso(
      processesMode: mode,
      contextSwitchTime:
          prefs.getInt(SettingsKeys.contextSwitchTime) ??
          Settings.defaultContextSwitchTime,
      ioChannels:
          prefs.getInt(SettingsKeys.ioChannels) ?? Settings.defaultIoChannels,
      cpuCount: prefs.getInt(SettingsKeys.cpuCount) ?? Settings.defaultCpuCount,
      quantum: prefs.getInt(SettingsKeys.quantum) ?? Settings.defaultQuantum,
      queueQuanta:
          listStr?.map(int.parse).toList() ?? Settings.defaultQueueQuanta,
      timeLimit:
          prefs.getInt(SettingsKeys.timeLimit) ?? Settings.defaultTimeLimit,
    );
  }

  /// Saves settings to SharedPreferences
  Future<void> saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SettingsKeys.contextSwitchTime, contextSwitchTime);
    await prefs.setInt(SettingsKeys.ioChannels, ioChannels);
    await prefs.setInt(SettingsKeys.cpuCount, cpuCount);
    await prefs.setInt(SettingsKeys.quantum, quantum);
    await prefs.setStringList(
      SettingsKeys.queueQuanta,
      queueQuanta.map((e) => e.toString()).toList(),
    );
    await prefs.setInt(SettingsKeys.timeLimit, timeLimit);
  }

  /// Creates a deep copy of the settings
  @override
  SettingsMaso copy() {
    return SettingsMaso(
      processesMode: processesMode,
      contextSwitchTime: contextSwitchTime,
      ioChannels: ioChannels,
      cpuCount: cpuCount,
      quantum: quantum,
      timeLimit: timeLimit,
    );
  }
}
