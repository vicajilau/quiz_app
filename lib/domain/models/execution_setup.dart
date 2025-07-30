import 'package:quiz_app/domain/models/scheduling_algorithm.dart';
import 'package:quiz_app/domain/models/settings_maso.dart';

class ExecutionSetup {
  SchedulingAlgorithm algorithm;
  SettingsMaso settings;

  ExecutionSetup({required this.algorithm, required this.settings});
}
