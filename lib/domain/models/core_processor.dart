import 'hardware_component.dart';
import 'maso/burst_process.dart';
import 'maso/regular_process.dart';

/// Represents a processor core composed of a list of hardware components.
/// Each hardware component can represent different parts of the CPU such as ALU, registers, etc.
class CoreProcessor {
  /// The list of hardware components contained in this core.
  List<HardwareComponent> core;

  /// Creates an empty CoreProcessor with no hardware components.
  CoreProcessor.empty() : this([]);

  /// Creates a CoreProcessor initialized with the given list of hardware components.
  CoreProcessor(this.core);

  /// Returns true if the first hardware component's process is a RegularProcess.
  bool isRegularProcessInside() =>
      (core.isNotEmpty && core.first.process is RegularProcess);

  /// Returns true if the first hardware component's process is a BurstProcess.
  bool isBurstProcessInside() =>
      (core.isNotEmpty && core.first.process is BurstProcess);
}
