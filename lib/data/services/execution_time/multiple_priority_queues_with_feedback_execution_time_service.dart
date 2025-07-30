import 'package:quiz_app/core/constants/execution_time_constants.dart';
import 'package:quiz_app/data/services/execution_time/base_execution_time_service.dart';
import 'package:quiz_app/domain/models/machine.dart';

import '../../../domain/models/core_processor.dart';
import '../../../domain/models/hardware_component.dart';
import '../../../domain/models/hardware_state.dart';
import '../../../domain/models/maso/regular_process.dart';

/// Execution time service implementing the Multiple Priority Queues with Feedback scheduling algorithm.
///
/// This algorithm starts all processes in the highest priority queue (priority level 0),
/// and demotes processes to lower priority queues if they consume their entire time quantum without finishing.
/// Each priority queue has its own time quantum, and processes are scheduled in a round-robin manner among CPUs.
/// The scheduling continues until all processes are completed.
/// Supports only regular (non-burst) processes.
class MultiplePriorityQueuesWithFeedbackExecutionTimeService
    extends BaseExecutionTimeService {
  /// Constructs the service with the given list of processes and execution setup.
  MultiplePriorityQueuesWithFeedbackExecutionTimeService(
    super.processes,
    super.executionSetup,
  );

  /// Calculates the machine execution timeline for regular processes using
  /// the Multiple Priority Queues with Feedback scheduling algorithm.
  ///
  /// - Processes are initially placed in the highest priority queue.
  /// - Each queue has an associated time quantum.
  /// - If a process does not finish within its quantum, it is moved to the next lower priority queue.
  /// - CPUs are assigned in round-robin fashion.
  /// - Idle times and context switching are accounted for.
  /// - Returns a `Machine` instance representing the schedule.
  @override
  Machine calculateMachineWithRegularProcesses() {
    final allProcesses = processes.whereType<RegularProcess>().toList();
    final numberOfCPUs = executionSetup.settings.cpuCount;
    final contextSwitchTime = executionSetup.settings.contextSwitchTime;

    // Time quantum per priority level; can be configured or adjusted
    final List<int> timeQuanta = [4, 6, 8];

    // Initialize the priority queues; one queue per priority level
    final List<List<RegularProcess>> queues = List.generate(
      timeQuanta.length,
      (_) => [],
    );

    // All processes start in the highest priority queue (level 0),
    // sorted by arrival time
    final processQueue = [...allProcesses]
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    queues[0].addAll(processQueue);

    // Initialize CPUs and their current times
    final cpus = List.generate(numberOfCPUs, (_) => CoreProcessor.empty());
    final cpuTimes = List.filled(numberOfCPUs, 0);
    int currentCPU = 0;

    // While there are processes in any queue
    while (queues.any((q) => q.isNotEmpty)) {
      for (int level = 0; level < queues.length; level++) {
        final queue = queues[level];

        int index = 0;
        // Iterate through all processes in this priority queue
        while (index < queue.length) {
          final process = queue[index];

          final cpuTime = cpuTimes[currentCPU];
          final startTime = cpuTime < process.arrivalTime
              ? process.arrivalTime
              : cpuTime;

          final core = cpus[currentCPU].core;

          // Add idle time if CPU is free before process starts
          if (startTime > cpuTime) {
            final idle = RegularProcess(
              id: ExecutionTimeConstants.freeProcessId,
              arrivalTime: cpuTime,
              serviceTime: startTime - cpuTime,
              enabled: true,
            );
            core.add(HardwareComponent(HardwareState.free, idle));
          }

          // Determine quantum and execution time for this process slice
          final quantum = timeQuanta[level];
          final remaining = process.serviceTime;
          final executedTime = remaining > quantum ? quantum : remaining;

          // Create a copy of the process with updated arrival time and service time
          final running = process.copy()
            ..arrivalTime = startTime
            ..serviceTime = executedTime;

          // Mark CPU as busy executing this process slice
          core.add(HardwareComponent(HardwareState.busy, running));
          cpuTimes[currentCPU] = startTime + executedTime;

          // Add context switching time if configured
          if (contextSwitchTime > 0) {
            final switching = RegularProcess(
              id: ExecutionTimeConstants.switchContextProcessId,
              arrivalTime: cpuTimes[currentCPU],
              serviceTime: contextSwitchTime,
              enabled: true,
            );
            core.add(
              HardwareComponent(HardwareState.switchingContext, switching),
            );
            cpuTimes[currentCPU] += contextSwitchTime;
          }

          // If process did not finish, move leftover to next lower priority queue
          if (remaining > quantum && level + 1 < queues.length) {
            final leftover = process.copy()
              ..arrivalTime = cpuTimes[currentCPU]
              ..serviceTime = remaining - quantum;

            queues[level + 1].add(leftover);
          }

          // Remove the process from the current queue
          queue.removeAt(index);

          // Round-robin CPU assignment
          currentCPU = (currentCPU + 1) % numberOfCPUs;
        }
      }
    }

    return Machine(cpus: cpus, ioChannels: []);
  }

  /// Burst process calculation is not supported and throws an error.
  @override
  Machine calculateMachineWithBurstProcesses() {
    throw UnimplementedError();
  }
}
