import 'package:quiz_app/domain/models/core_processor.dart';

/// Represents a machine composed of multiple CPUs and I/O channels,
/// where each CPU and I/O channel is a list of `HardwareComponent` objects.
class Machine {
  /// List of CPU cores, where each core is represented as a list of `HardwareComponent`.
  final List<CoreProcessor> cpus;

  /// List of I/O channels, where each channel is represented as a list of `HardwareComponent`.
  final List<CoreProcessor> ioChannels;

  /// Constructs a `Machine` with the given CPUs and I/O channels.
  Machine({required this.cpus, required this.ioChannels});

  bool isRegularProcessInside() =>
      cpus.isNotEmpty && cpus.first.isRegularProcessInside();

  bool isBurstProcessInside() =>
      cpus.isNotEmpty && cpus.first.isBurstProcessInside();

  /// Returns a string representation of the Machine object, similar to Java's `toString` method.
  @override
  String toString() {
    final cpuStr = cpus
        .asMap()
        .entries
        .map(
          (e) =>
              "\t- CPU ${e.key + 1}: ${e.value.core.map((c) => c.toString()).join(', ')}",
        )
        .join('\n');
    final ioStr = ioChannels
        .asMap()
        .entries
        .map(
          (e) =>
              "\t- I/O Channel ${e.key + 1}: ${e.value.core.map((c) => c.toString()).join(', ')}",
        )
        .join('\n');
    return "Machine Structure:\n* CPUs:\n$cpuStr\n* I/O Channels:\n$ioStr";
  }
}
