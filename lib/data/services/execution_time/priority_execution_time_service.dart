import 'package:quiz_app/core/constants/execution_time_constants.dart';
import 'package:quiz_app/data/services/execution_time/base_execution_time_service.dart';
import 'package:quiz_app/domain/models/machine.dart';
import 'package:quiz_app/domain/models/maso/i_process.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';

/// Execution time service for the Priority-Based scheduling algorithm.
///
/// This class implements the `BaseExecutionTimeService` interface,
/// supporting only regular (non-burst) processes.
/// It assigns processes to CPUs based on their priority (lower value = higher priority),
/// then cycles through CPUs, handling idle times and context switches if configured.
class PriorityExecutionTimeService extends BaseExecutionTimeService {
  /// Constructs a Priority execution time service with the provided process list and setup.
  PriorityExecutionTimeService(super.processes, super.executionSetup);

  /// Calculates the execution machine for regular processes using Priority scheduling.
  ///
  /// - Processes are filtered by their `enabled` flag.
  /// - They are sorted by `priority`, then by `arrivalTime` as tiebreaker.
  /// - Processes are assigned to CPUs in a round-robin fashion.
  /// - Idle periods are marked with `HardwareState.free`.
  /// - Context switch time is handled if defined in the setup.
  @override
  Machine calculateMachineWithRegularProcesses() {
    final filteredProcesses = processes.whereType<RegularProcess>().toList()
      ..sort((a, b) {
        final byPriority = a.priority.compareTo(b.priority);
        return byPriority != 0
            ? byPriority
            : a.arrivalTime.compareTo(b.arrivalTime);
      });

    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    // Initialize empty CPU cores
    List<CoreProcessor> cpus = List.generate(
      numberOfCPUs,
      (_) => CoreProcessor.empty(),
    );

    // Track the current execution time per CPU
    List<int> cpuTimes = List.filled(numberOfCPUs, 0);
    int currentCPU = 0;

    for (var i = 0; i < filteredProcesses.length; i++) {
      final process = filteredProcesses[i];
      final core = cpus[currentCPU].core;

      final currentCpuTime = cpuTimes[currentCPU];

      // Determine the start time: either the process arrival or when the CPU is free
      final startTime = currentCpuTime < process.arrivalTime
          ? process.arrivalTime
          : currentCpuTime;

      // Add a 'free' block if there is idle time
      if (startTime > currentCpuTime) {
        final idleProcess = RegularProcess(
          id: ExecutionTimeConstants.freeProcessId,
          arrivalTime: currentCpuTime,
          serviceTime: startTime - currentCpuTime,
          enabled: true,
        );

        core.add(HardwareComponent(HardwareState.free, idleProcess));
      }

      // Copy and adjust the process start time
      IProcess processCopied = process.copy();
      processCopied.arrivalTime = startTime;

      // Add the process as a busy component
      core.add(HardwareComponent(HardwareState.busy, processCopied));

      cpuTimes[currentCPU] = startTime + process.serviceTime;

      // Add context switch if this CPU will be reused
      final willThisCPUBeUsedAgain =
          i + numberOfCPUs < filteredProcesses.length;

      if (contextSwitchTime > 0 && willThisCPUBeUsedAgain) {
        final switchProcess = RegularProcess(
          id: ExecutionTimeConstants.switchContextProcessId,
          arrivalTime: cpuTimes[currentCPU],
          serviceTime: contextSwitchTime,
          enabled: true,
        );

        core.add(
          HardwareComponent(HardwareState.switchingContext, switchProcess),
        );

        cpuTimes[currentCPU] += contextSwitchTime;
      }

      // Move to the next CPU (round-robin)
      currentCPU = (currentCPU + 1) % numberOfCPUs;
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Not implemented for priority scheduling, since burst processes are not supported.
  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
