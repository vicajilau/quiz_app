import 'package:quiz_app/core/constants/execution_time_constants.dart';
import 'package:quiz_app/data/services/execution_time/base_execution_time_service.dart';
import 'package:quiz_app/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';

/// Execution time service implementing the Multiple Priority Queues scheduling algorithm.
///
/// This algorithm organizes processes into multiple priority queues,
/// where each queue corresponds to a priority level.
/// Processes in higher priority queues (lower numeric value) are executed first,
/// and within each queue processes are scheduled in FIFO order.
/// Processes are assigned to CPUs in a round-robin fashion.
/// Idle times and context switches are handled appropriately.
/// Supports only regular (non-burst) processes.
class MultiplePriorityQueuesExecutionTimeService
    extends BaseExecutionTimeService {
  /// Constructs the service with the provided list of processes and execution setup.
  MultiplePriorityQueuesExecutionTimeService(
    super.processes,
    super.executionSetup,
  );

  /// Calculates the machine execution timeline for regular processes using
  /// the Multiple Priority Queues scheduling algorithm.
  ///
  /// - Processes are grouped by their `priority` value.
  /// - Each queue is sorted by `arrivalTime` ascending.
  /// - Queues are processed from highest priority (lowest number) to lowest.
  /// - Processes are assigned to CPUs in round-robin order.
  /// - Idle times and context switch times are added as needed.
  /// - Returns a `Machine` object representing the schedule.
  @override
  Machine calculateMachineWithRegularProcesses() {
    final allProcesses = processes.whereType<RegularProcess>().toList();
    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    // Group processes by priority level
    final Map<int, List<RegularProcess>> priorityQueues = {};
    for (var process in allProcesses) {
      if (!process.enabled) continue;
      priorityQueues.putIfAbsent(process.priority, () => []).add(process);
    }

    // Sort priorities ascending (higher priority first)
    final sortedPriorities = priorityQueues.keys.toList()..sort();

    // Initialize empty CPU cores
    final List<CoreProcessor> cpus = List.generate(
      numberOfCPUs,
      (_) => CoreProcessor.empty(),
    );
    final List<int> cpuTimes = List.filled(numberOfCPUs, 0);
    int currentCPU = 0;

    // Process each priority queue in order
    for (final priority in sortedPriorities) {
      final queue = priorityQueues[priority]!
        ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

      for (var i = 0; i < queue.length; i++) {
        final process = queue[i];
        final core = cpus[currentCPU].core;
        final currentCpuTime = cpuTimes[currentCPU];

        // Determine the actual start time for the process on this CPU
        final startTime = currentCpuTime < process.arrivalTime
            ? process.arrivalTime
            : currentCpuTime;

        // Add idle time if CPU is free before this process starts
        if (startTime > currentCpuTime) {
          final idleProcess = RegularProcess(
            id: ExecutionTimeConstants.freeProcessId,
            arrivalTime: currentCpuTime,
            serviceTime: startTime - currentCpuTime,
            enabled: true,
          );
          core.add(HardwareComponent(HardwareState.free, idleProcess));
        }

        // Copy the process and adjust its arrival time for scheduling
        final processCopied = process.copy();
        processCopied.arrivalTime = startTime;

        // Add the process as a busy component in the CPU core timeline
        core.add(HardwareComponent(HardwareState.busy, processCopied));
        cpuTimes[currentCPU] = startTime + process.serviceTime;

        // Determine if a context switch should be added after this process
        // Conditions:
        // - There are more processes in the current queue after this one, OR
        // - There are lower priority queues to process afterward
        final willBeUsedAgain =
            i + numberOfCPUs < queue.length ||
            sortedPriorities.indexOf(priority) < sortedPriorities.length - 1;

        if (contextSwitchTime > 0 && willBeUsedAgain) {
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

        // Move to the next CPU for round-robin assignment
        currentCPU = (currentCPU + 1) % numberOfCPUs;
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Burst processes are not supported in this scheduling algorithm.
  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
